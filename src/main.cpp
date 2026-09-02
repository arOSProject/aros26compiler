#include "authcontroller.h"
#include "notificationserver.h"
#include "systembridge.h"

#include <QCommandLineParser>
#include <QGuiApplication>
#include <QHash>
#include <QProcess>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QQuickStyle>
#include <QUrl>

int main(int argc, char *argv[])
{
    QGuiApplication::setApplicationName(QStringLiteral("AR OS"));
    QGuiApplication::setOrganizationName(QStringLiteral("AROS"));
    QGuiApplication::setOrganizationDomain(QStringLiteral("ar-os.local"));
    QGuiApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
    QGuiApplication app(argc, argv);

    QCommandLineParser parser;
    parser.setApplicationDescription(QStringLiteral("AR OS native shell and system applications"));
    parser.addHelpOption();
    QCommandLineOption component({QStringLiteral("c"), QStringLiteral("component")},
                                 QStringLiteral("Component to run"), QStringLiteral("name"),
                                 QStringLiteral("shell"));
    parser.addOption(component);
    parser.process(app);

    const QString mode = parser.value(component).toLower();
    if (mode == QStringLiteral("terminal")) {
        QProcess::startDetached(QStringLiteral("konsole"),
                                {QStringLiteral("--profile"), QStringLiteral("AR Terminal")});
        return 0;
    }

    QQuickStyle::setStyle(QStringLiteral("Basic"));
    SystemBridge system;
    NotificationServer notifications;
    AuthController auth;
    if (mode == QStringLiteral("shell"))
        notifications.registerOnSessionBus();

    QQmlApplicationEngine engine;
    engine.rootContext()->setContextProperty(QStringLiteral("ARSystem"), &system);
    engine.rootContext()->setContextProperty(QStringLiteral("ARNotifications"), &notifications);
    engine.rootContext()->setContextProperty(QStringLiteral("ARAuth"), &auth);
    engine.rootContext()->setContextProperty(QStringLiteral("ARMode"), mode);

    const QHash<QString, QString> sources = {
        {QStringLiteral("shell"), QStringLiteral("qml/shell/Shell.qml")},
        {QStringLiteral("files"), QStringLiteral("qml/apps/FilesApp.qml")},
        {QStringLiteral("settings"), QStringLiteral("qml/apps/SettingsApp.qml")},
        {QStringLiteral("software"), QStringLiteral("qml/apps/SoftwareApp.qml")},
        {QStringLiteral("updater"), QStringLiteral("qml/apps/UpdaterApp.qml")},
        {QStringLiteral("about"), QStringLiteral("qml/apps/AboutApp.qml")},
        {QStringLiteral("oobe"), QStringLiteral("qml/apps/OobeApp.qml")},
        {QStringLiteral("lock"), QStringLiteral("qml/apps/LockApp.qml")}
    };
    const QString source = sources.value(mode, sources.value(QStringLiteral("shell")));
    engine.load(QUrl(QStringLiteral("qrc:/qt/qml/AROS/") + source));
    if (engine.rootObjects().isEmpty())
        return 2;
    return app.exec();
}
