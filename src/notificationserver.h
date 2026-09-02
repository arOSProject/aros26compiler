#pragma once

#include <QObject>
#include <QVariantList>
#include <QVariantMap>

class NotificationServer final : public QObject
{
    Q_OBJECT
    Q_CLASSINFO("D-Bus Interface", "org.freedesktop.Notifications")
    Q_PROPERTY(QVariantList notifications READ notifications NOTIFY notificationsChanged)

public:
    explicit NotificationServer(QObject *parent = nullptr);
    QVariantList notifications() const { return m_notifications; }
    bool registerOnSessionBus();

public slots:
    uint Notify(const QString &appName, uint replacesId, const QString &appIcon,
                const QString &summary, const QString &body, const QStringList &actions,
                const QVariantMap &hints, int expireTimeout);
    void CloseNotification(uint id);
    QStringList GetCapabilities() const;
    void GetServerInformation(QString &name, QString &vendor, QString &version,
                              QString &specVersion) const;
    Q_INVOKABLE void clear();
    Q_INVOKABLE void invokeAction(uint id, const QString &actionKey);

signals:
    void NotificationClosed(uint id, uint reason);
    void ActionInvoked(uint id, const QString &actionKey);
    void notificationsChanged();

private:
    QVariantList m_notifications;
    uint m_nextId = 1;
};

