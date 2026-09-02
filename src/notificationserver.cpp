#include "notificationserver.h"

#include <QDBusConnection>
#include <QDateTime>

#include <utility>

NotificationServer::NotificationServer(QObject *parent)
    : QObject(parent)
{
}

bool NotificationServer::registerOnSessionBus()
{
    auto bus = QDBusConnection::sessionBus();
    if (!bus.registerService(QStringLiteral("org.freedesktop.Notifications")))
        return false;
    return bus.registerObject(QStringLiteral("/org/freedesktop/Notifications"), this,
                              QDBusConnection::ExportAllSlots | QDBusConnection::ExportAllSignals);
}

uint NotificationServer::Notify(const QString &appName, uint replacesId, const QString &appIcon,
                                const QString &summary, const QString &body,
                                const QStringList &actions, const QVariantMap &hints,
                                int expireTimeout)
{
    Q_UNUSED(hints)
    const uint id = replacesId > 0 ? replacesId : m_nextId++;
    QVariantMap notification{{QStringLiteral("id"), id},
                             {QStringLiteral("appName"), appName},
                             {QStringLiteral("icon"), appIcon},
                             {QStringLiteral("summary"), summary},
                             {QStringLiteral("body"), body},
                             {QStringLiteral("actions"), actions},
                             {QStringLiteral("expireTimeout"), expireTimeout},
                             {QStringLiteral("timestamp"), QDateTime::currentDateTime()}};
    bool replaced = false;
    for (int index = 0; index < m_notifications.size(); ++index) {
        if (m_notifications.at(index).toMap().value(QStringLiteral("id")).toUInt() == id) {
            m_notifications[index] = notification;
            replaced = true;
            break;
        }
    }
    if (!replaced)
        m_notifications.prepend(notification);
    while (m_notifications.size() > 50)
        m_notifications.removeLast();
    emit notificationsChanged();
    return id;
}

void NotificationServer::CloseNotification(uint id)
{
    for (int index = 0; index < m_notifications.size(); ++index) {
        if (m_notifications.at(index).toMap().value(QStringLiteral("id")).toUInt() == id) {
            m_notifications.removeAt(index);
            emit notificationsChanged();
            emit NotificationClosed(id, 3);
            return;
        }
    }
}

QStringList NotificationServer::GetCapabilities() const
{
    return {QStringLiteral("actions"), QStringLiteral("body"), QStringLiteral("body-markup"),
            QStringLiteral("icon-static"), QStringLiteral("persistence")};
}

void NotificationServer::GetServerInformation(QString &name, QString &vendor, QString &version,
                                              QString &specVersion) const
{
    name = QStringLiteral("AR Notifications");
    vendor = QStringLiteral("AR OS");
    version = QStringLiteral(AR_OS_VERSION);
    specVersion = QStringLiteral("1.2");
}

void NotificationServer::clear()
{
    for (const QVariant &item : std::as_const(m_notifications))
        emit NotificationClosed(item.toMap().value(QStringLiteral("id")).toUInt(), 3);
    m_notifications.clear();
    emit notificationsChanged();
}

void NotificationServer::invokeAction(uint id, const QString &actionKey)
{
    emit ActionInvoked(id, actionKey);
}
