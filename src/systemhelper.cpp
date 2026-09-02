#include <QCoreApplication>
#include <QFile>
#include <QJsonDocument>
#include <QJsonObject>
#include <QProcess>
#include <QRegularExpression>

#include <pwd.h>
#include <sys/types.h>
#include <unistd.h>

namespace {
bool run(const QString &program, const QStringList &arguments)
{
    return QProcess::execute(program, arguments) == 0;
}

QString validated(const QJsonObject &object, const QString &key,
                  const QRegularExpression &pattern)
{
    const QString value = object.value(key).toString();
    return pattern.match(value).hasMatch() ? value : QString();
}
}

int main(int argc, char *argv[])
{
    QCoreApplication app(argc, argv);
    const QStringList arguments = app.arguments();
    if (geteuid() != 0 || arguments.size() != 2
        || arguments.at(1) != QStringLiteral("apply-oobe"))
        return 64;

    bool uidOk = false;
    const uid_t sourceUid = qEnvironmentVariable("PKEXEC_UID").toUInt(&uidOk);
    if (!uidOk || sourceUid == 0)
        return 77;
    const passwd *account = getpwuid(sourceUid);
    if (!account || !account->pw_dir || !account->pw_name)
        return 77;

    const QString userName = QString::fromLocal8Bit(account->pw_name);
    const QString fileName = QString::fromLocal8Bit(account->pw_dir)
        + QStringLiteral("/.config/ar-os/oobe.json");
    QFile file(fileName);
    if (!file.open(QIODevice::ReadOnly))
        return 66;
    const QJsonDocument document = QJsonDocument::fromJson(file.readAll());
    if (!document.isObject() || !document.object().value(QStringLiteral("completed")).toBool())
        return 65;
    const QJsonObject values = document.object();

    bool ok = true;
    const QString timezone = validated(values, QStringLiteral("timezone"),
        QRegularExpression(QStringLiteral("^[A-Za-z0-9_+.-]+/[A-Za-z0-9_+.-]+$")));
    if (!timezone.isEmpty())
        ok = run(QStringLiteral("timedatectl"), {QStringLiteral("set-timezone"), timezone}) && ok;

    const QString locale = validated(values, QStringLiteral("locale"),
        QRegularExpression(QStringLiteral("^[A-Za-z_]+\\.UTF-8$")));
    if (!locale.isEmpty())
        ok = run(QStringLiteral("localectl"), {QStringLiteral("set-locale"),
                                                QStringLiteral("LANG=%1").arg(locale)}) && ok;

    const QString keyboard = validated(values, QStringLiteral("keyboard"),
        QRegularExpression(QStringLiteral("^[a-z0-9_-]{2,16}$")));
    if (!keyboard.isEmpty())
        ok = run(QStringLiteral("localectl"), {QStringLiteral("set-x11-keymap"), keyboard}) && ok;

    QString fullName = values.value(QStringLiteral("fullName")).toString().trimmed();
    fullName.remove(QRegularExpression(QStringLiteral("[\\r\\n:]")));
    if (!fullName.isEmpty() && fullName.size() <= 128)
        ok = run(QStringLiteral("usermod"), {QStringLiteral("--comment"), fullName, userName}) && ok;

    const bool updates = values.value(QStringLiteral("automaticUpdates")).toBool(true);
    ok = run(QStringLiteral("systemctl"),
             {updates ? QStringLiteral("enable") : QStringLiteral("disable"),
              QStringLiteral("--now"), QStringLiteral("apt-daily-upgrade.timer")}) && ok;
    return ok ? 0 : 1;
}

