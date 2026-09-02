#include "systembridge.h"
#include "searchprovider.h"

#include <QCoreApplication>
#include <QDateTime>
#include <QDesktopServices>
#include <QDir>
#include <QDirIterator>
#include <QFile>
#include <QFileInfo>
#include <QJsonDocument>
#include <QJsonObject>
#include <QLocale>
#include <QProcess>
#include <QRegularExpression>
#include <QSaveFile>
#include <QSettings>
#include <QSet>
#include <QStandardPaths>
#include <QStorageInfo>
#include <QSysInfo>
#include <QTimer>
#include <QUrl>

#include <algorithm>

namespace {
QString settingsFile()
{
    return QStandardPaths::writableLocation(QStandardPaths::ConfigLocation)
        + QStringLiteral("/ar-os/shell.ini");
}

QStringList desktopRoots()
{
    QStringList roots;
    roots << QStandardPaths::writableLocation(QStandardPaths::ApplicationsLocation);
    const auto generic = QStandardPaths::standardLocations(QStandardPaths::GenericDataLocation);
    for (const QString &root : generic)
        roots << root + QStringLiteral("/applications");
    roots.removeDuplicates();
    return roots;
}

QString humanSize(qint64 bytes)
{
    static const QStringList units = {QStringLiteral("B"), QStringLiteral("KB"),
                                      QStringLiteral("MB"), QStringLiteral("GB"),
                                      QStringLiteral("TB")};
    double value = static_cast<double>(bytes);
    int unit = 0;
    while (value >= 1024.0 && unit < units.size() - 1) {
        value /= 1024.0;
        ++unit;
    }
    return QStringLiteral("%1 %2")
        .arg(QString::number(value, 'f', unit == 0 ? 0 : 1), units.at(unit));
}

bool copyRecursively(const QString &sourcePath, const QString &targetPath)
{
    const QFileInfo source(sourcePath);
    if (source.isSymLink())
        return false;
    if (source.isFile())
        return !QFileInfo::exists(targetPath) && QFile::copy(sourcePath, targetPath);
    if (!source.isDir())
        return false;

    if (!QDir().mkpath(targetPath))
        return false;
    QDir directory(sourcePath);
    const QFileInfoList entries = directory.entryInfoList(
        QDir::AllEntries | QDir::NoDotAndDotDot | QDir::Hidden | QDir::System);
    for (const QFileInfo &entry : entries) {
        if (!copyRecursively(entry.absoluteFilePath(),
                             QDir(targetPath).filePath(entry.fileName())))
            return false;
    }
    return true;
}
}

SystemBridge::SystemBridge(QObject *parent)
    : QObject(parent)
    , m_searchRegistry(std::make_unique<SearchRegistry>())
{
    loadAppearance();
    refreshApplications();
    refresh();
    m_refreshTimer = new QTimer(this);
    m_refreshTimer->setInterval(5000);
    connect(m_refreshTimer, &QTimer::timeout, this, &SystemBridge::refresh);
    m_refreshTimer->start();
}

SystemBridge::~SystemBridge() = default;

QString SystemBridge::capture(const QString &program, const QStringList &arguments)
{
    QProcess process;
    process.start(program, arguments, QIODevice::ReadOnly);
    if (!process.waitForStarted(1200) || !process.waitForFinished(3500))
        return {};
    return QString::fromUtf8(process.readAllStandardOutput()).trimmed();
}

bool SystemBridge::start(const QString &program, const QStringList &arguments)
{
    return QProcess::startDetached(program, arguments);
}

QString SystemBridge::userName() const
{
    return qEnvironmentVariable("USER", QStringLiteral("user"));
}

QString SystemBridge::displayName() const
{
    const QString gecos = capture(QStringLiteral("getent"),
                                  {QStringLiteral("passwd"), userName()});
    const QStringList parts = gecos.split(QLatin1Char(':'));
    if (parts.size() > 4 && !parts.at(4).isEmpty())
        return parts.at(4).section(QLatin1Char(','), 0, 0);
    QString fallback = userName();
    if (!fallback.isEmpty())
        fallback[0] = fallback.at(0).toUpper();
    return fallback;
}

QString SystemBridge::appearance() const { return m_appearance; }
QString SystemBridge::wallpaper() const { return m_wallpaper; }

void SystemBridge::loadAppearance()
{
    QSettings settings(settingsFile(), QSettings::IniFormat);
    m_appearance = settings.value(QStringLiteral("appearance"), QStringLiteral("light")).toString();
    m_wallpaper = settings.value(QStringLiteral("wallpaper"), QStringLiteral("ribbon")).toString();
}

void SystemBridge::setAppearance(const QString &value)
{
    const QString normalized = value == QStringLiteral("dark") ? QStringLiteral("dark")
                                                                 : QStringLiteral("light");
    if (m_appearance == normalized)
        return;
    m_appearance = normalized;
    QSettings settings(settingsFile(), QSettings::IniFormat);
    settings.setValue(QStringLiteral("appearance"), normalized);
    emit appearanceChanged();
}

void SystemBridge::setWallpaper(const QString &value)
{
    const QString normalized = value == QStringLiteral("night") ? QStringLiteral("night")
                                                                 : QStringLiteral("ribbon");
    if (m_wallpaper == normalized)
        return;
    m_wallpaper = normalized;
    QSettings settings(settingsFile(), QSettings::IniFormat);
    settings.setValue(QStringLiteral("wallpaper"), normalized);
    emit appearanceChanged();
}

void SystemBridge::refresh()
{
    loadAppearance();
    const QString wifi = capture(QStringLiteral("nmcli"),
                                 {QStringLiteral("-t"), QStringLiteral("-f"),
                                  QStringLiteral("WIFI"), QStringLiteral("general")});
    if (!wifi.isEmpty())
        m_wifiEnabled = wifi.contains(QStringLiteral("enabled"), Qt::CaseInsensitive);

    const QString ssid = capture(QStringLiteral("nmcli"),
                                 {QStringLiteral("-t"), QStringLiteral("-f"),
                                  QStringLiteral("ACTIVE,SSID"), QStringLiteral("device"),
                                  QStringLiteral("wifi")});
    m_networkName.clear();
    for (const QString &line : ssid.split(QLatin1Char('\n'))) {
        if (line.startsWith(QStringLiteral("yes:"))) {
            m_networkName = line.section(QLatin1Char(':'), 1);
            break;
        }
    }

    const QString bluetooth = capture(QStringLiteral("bluetoothctl"), {QStringLiteral("show")});
    if (!bluetooth.isEmpty())
        m_bluetoothEnabled = bluetooth.contains(QStringLiteral("Powered: yes"));

    const QString volumeText = capture(QStringLiteral("wpctl"),
                                       {QStringLiteral("get-volume"),
                                        QStringLiteral("@DEFAULT_AUDIO_SINK@")});
    if (!volumeText.isEmpty()) {
        bool ok = false;
        const double parsed = volumeText.section(QLatin1Char(' '), 1, 1).toDouble(&ok);
        if (ok)
            m_volume = std::clamp(static_cast<int>(parsed * 100.0), 0, 150);
    }

    QDir power(QStringLiteral("/sys/class/power_supply"));
    const QStringList batteries = power.entryList({QStringLiteral("BAT*")}, QDir::Dirs);
    if (!batteries.isEmpty()) {
        QFile capacity(power.filePath(batteries.first() + QStringLiteral("/capacity")));
        if (capacity.open(QIODevice::ReadOnly))
            m_battery = QString::fromUtf8(capacity.readAll()).trimmed().toInt();
    }

    const QString backlight = capture(QStringLiteral("brightnessctl"),
                                      {QStringLiteral("-m")});
    if (!backlight.isEmpty()) {
        const QString percent = backlight.section(QLatin1Char(','), 3, 3);
        bool ok = false;
        const int parsed = QString(percent).remove(QLatin1Char('%')).toInt(&ok);
        if (ok)
            m_brightness = parsed;
    }
    emit stateChanged();
    emit appearanceChanged();
}

void SystemBridge::setWifiEnabled(bool enabled)
{
    if (start(QStringLiteral("nmcli"), {QStringLiteral("radio"), QStringLiteral("wifi"),
                                        enabled ? QStringLiteral("on") : QStringLiteral("off")})) {
        m_wifiEnabled = enabled;
        emit stateChanged();
    } else {
        emit operationFailed(QStringLiteral("NetworkManager could not change Wi-Fi state."));
    }
}

void SystemBridge::setBluetoothEnabled(bool enabled)
{
    if (start(QStringLiteral("bluetoothctl"),
              {QStringLiteral("power"), enabled ? QStringLiteral("on") : QStringLiteral("off")})) {
        m_bluetoothEnabled = enabled;
        emit stateChanged();
    } else {
        emit operationFailed(QStringLiteral("BlueZ could not change Bluetooth state."));
    }
}

void SystemBridge::setVolume(int value)
{
    value = std::clamp(value, 0, 150);
    if (start(QStringLiteral("wpctl"),
              {QStringLiteral("set-volume"), QStringLiteral("@DEFAULT_AUDIO_SINK@"),
               QStringLiteral("%1%").arg(value)})) {
        m_volume = value;
        emit stateChanged();
    }
}

void SystemBridge::setBrightness(int value)
{
    value = std::clamp(value, 1, 100);
    if (start(QStringLiteral("brightnessctl"),
              {QStringLiteral("set"), QStringLiteral("%1%").arg(value)})) {
        m_brightness = value;
        emit stateChanged();
    }
}

QString SystemBridge::desktopName(const QString &path)
{
    QSettings entry(path, QSettings::IniFormat);
    entry.beginGroup(QStringLiteral("Desktop Entry"));
    return entry.value(QStringLiteral("Name")).toString();
}

QString SystemBridge::desktopIcon(const QString &path)
{
    QSettings entry(path, QSettings::IniFormat);
    entry.beginGroup(QStringLiteral("Desktop Entry"));
    return entry.value(QStringLiteral("Icon"), QStringLiteral("application-x-executable")).toString();
}

QString SystemBridge::desktopExec(const QString &path)
{
    QSettings entry(path, QSettings::IniFormat);
    entry.beginGroup(QStringLiteral("Desktop Entry"));
    QString command = entry.value(QStringLiteral("Exec")).toString();
    command.remove(QRegularExpression(QStringLiteral("\\s+%[fFuUdDnNickvm]")));
    return command.trimmed();
}

void SystemBridge::refreshApplications()
{
    QVariantList result;
    QSet<QString> seen;
    for (const QString &root : desktopRoots()) {
        QDirIterator it(root, {QStringLiteral("*.desktop")}, QDir::Files,
                        QDirIterator::Subdirectories);
        while (it.hasNext()) {
            const QString path = it.next();
            QSettings entry(path, QSettings::IniFormat);
            entry.beginGroup(QStringLiteral("Desktop Entry"));
            if (entry.value(QStringLiteral("NoDisplay"), false).toBool()
                || entry.value(QStringLiteral("Hidden"), false).toBool())
                continue;
            const QString name = entry.value(QStringLiteral("Name")).toString();
            const QString exec = entry.value(QStringLiteral("Exec")).toString();
            if (name.isEmpty() || exec.isEmpty() || seen.contains(name))
                continue;
            seen.insert(name);
            result << QVariantMap{{QStringLiteral("type"), QStringLiteral("application")},
                                  {QStringLiteral("name"), name},
                                  {QStringLiteral("subtitle"), entry.value(QStringLiteral("Comment")).toString()},
                                  {QStringLiteral("icon"), entry.value(QStringLiteral("Icon"), QStringLiteral("application-x-executable")).toString()},
                                  {QStringLiteral("id"), QFileInfo(path).baseName()},
                                  {QStringLiteral("path"), path}};
        }
    }
    std::sort(result.begin(), result.end(), [](const QVariant &left, const QVariant &right) {
        return left.toMap().value(QStringLiteral("name")).toString().localeAwareCompare(
                   right.toMap().value(QStringLiteral("name")).toString()) < 0;
    });
    m_applications = result;
    emit applicationsChanged();
}

QVariantList SystemBridge::search(const QString &query) const
{
    return m_searchRegistry->query(query, m_applications);
}

QStringList SystemBridge::searchProviders() const
{
    return m_searchRegistry->providerIds();
}

bool SystemBridge::launchDesktop(const QString &desktopId) const
{
    for (const QVariant &application : m_applications) {
        const QVariantMap map = application.toMap();
        if (map.value(QStringLiteral("id")).toString() != desktopId)
            continue;
        const QString command = desktopExec(map.value(QStringLiteral("path")).toString());
        const QStringList parts = QProcess::splitCommand(command);
        if (parts.isEmpty())
            return false;
        return start(parts.first(), parts.mid(1));
    }
    return false;
}

bool SystemBridge::launchCommand(const QString &command) const
{
    if (command == QStringLiteral("displays"))
        return start(QStringLiteral("kcmshell6"), {QStringLiteral("kcm_kscreen")});
    if (command == QStringLiteral("networks"))
        return start(QStringLiteral("nm-connection-editor"));
    if (command == QStringLiteral("bluetooth"))
        return start(QStringLiteral("bluedevil-wizard"));
    static const QHash<QString, QString> allowed = {
        {QStringLiteral("files"), QStringLiteral("ar-files")},
        {QStringLiteral("settings"), QStringLiteral("ar-settings")},
        {QStringLiteral("terminal"), QStringLiteral("ar-terminal")},
        {QStringLiteral("software"), QStringLiteral("ar-software")},
        {QStringLiteral("updater"), QStringLiteral("ar-updater")},
        {QStringLiteral("about"), QStringLiteral("ar-about")},
        {QStringLiteral("lock"), QStringLiteral("ar-lock")},
        {QStringLiteral("installer"), QStringLiteral("calamares")}
    };
    return allowed.contains(command) && start(allowed.value(command));
}

QString SystemBridge::normalizedPath(const QString &path)
{
    if (path.startsWith(QStringLiteral("file:")))
        return QUrl(path).toLocalFile();
    return QDir::cleanPath(path);
}

QString SystemBridge::homePath() const { return QDir::homePath(); }

QString SystemBridge::parentPath(const QString &path) const
{
    QDir directory(normalizedPath(path));
    directory.cdUp();
    return directory.absolutePath();
}

QVariantList SystemBridge::listDirectory(const QString &path) const
{
    QVariantList result;
    QDir directory(normalizedPath(path));
    const QFileInfoList entries = directory.entryInfoList(
        QDir::AllEntries | QDir::NoDotAndDotDot | QDir::System,
        QDir::DirsFirst | QDir::IgnoreCase | QDir::Name);
    for (const QFileInfo &info : entries) {
        result << QVariantMap{{QStringLiteral("name"), info.fileName()},
                              {QStringLiteral("path"), info.absoluteFilePath()},
                              {QStringLiteral("isDir"), info.isDir()},
                              {QStringLiteral("size"), info.isDir() ? QString() : humanSize(info.size())},
                              {QStringLiteral("modified"), QLocale().toString(info.lastModified(), QLocale::ShortFormat)},
                              {QStringLiteral("hidden"), info.isHidden()}};
    }
    return result;
}

QVariantList SystemBridge::volumes() const
{
    QVariantList result;
    for (const QStorageInfo &storage : QStorageInfo::mountedVolumes()) {
        if (!storage.isValid() || !storage.isReady())
            continue;
        const QString rootPath = storage.rootPath();
        QString name = storage.displayName();
        if (name.isEmpty())
            name = rootPath == QStringLiteral("/") ? QStringLiteral("System") : rootPath;
        result << QVariantMap{{QStringLiteral("name"), name},
                              {QStringLiteral("path"), rootPath},
                              {QStringLiteral("device"), QString::fromUtf8(storage.device())},
                              {QStringLiteral("readOnly"), storage.isReadOnly()},
                              {QStringLiteral("size"), humanSize(storage.bytesTotal())},
                              {QStringLiteral("free"), humanSize(storage.bytesAvailable())},
                              {QStringLiteral("canUnmount"), rootPath != QStringLiteral("/")
                                   && !QDir::homePath().startsWith(rootPath + QLatin1Char('/'))}};
    }
    return result;
}

bool SystemBridge::unmountVolume(const QString &device) const
{
    if (!device.startsWith(QStringLiteral("/dev/"))
        || !QRegularExpression(QStringLiteral("^/dev/[A-Za-z0-9._/-]+$")).match(device).hasMatch())
        return false;
    return start(QStringLiteral("udisksctl"), {QStringLiteral("unmount"),
                                               QStringLiteral("--block-device"), device});
}

bool SystemBridge::openPath(const QString &path) const
{
    return QDesktopServices::openUrl(QUrl::fromLocalFile(normalizedPath(path)));
}

bool SystemBridge::createFolder(const QString &parent, const QString &name) const
{
    if (name.trimmed().isEmpty() || name.contains(QLatin1Char('/')))
        return false;
    return QDir(normalizedPath(parent)).mkdir(name.trimmed());
}

bool SystemBridge::renamePath(const QString &path, const QString &name) const
{
    if (name.trimmed().isEmpty() || name.contains(QLatin1Char('/')))
        return false;
    QFileInfo info(normalizedPath(path));
    return QDir(info.absolutePath()).rename(info.fileName(), name.trimmed());
}

bool SystemBridge::moveToTrash(const QString &path) const
{
    const QString source = normalizedPath(path);
    const QString trashRoot = QStandardPaths::writableLocation(QStandardPaths::GenericDataLocation)
        + QStringLiteral("/Trash");
    const QString trash = trashRoot + QStringLiteral("/files");
    const QString infoDirectory = trashRoot + QStringLiteral("/info");
    QDir().mkpath(trash);
    QDir().mkpath(infoDirectory);
    QFileInfo info(source);
    QString targetName = info.fileName();
    if (QFileInfo::exists(trash + QLatin1Char('/') + targetName))
        targetName += QStringLiteral("-%1").arg(QDateTime::currentMSecsSinceEpoch());

    QSaveFile metadata(infoDirectory + QLatin1Char('/') + targetName + QStringLiteral(".trashinfo"));
    if (!metadata.open(QIODevice::WriteOnly))
        return false;
    metadata.write("[Trash Info]\nPath=");
    metadata.write(QUrl::toPercentEncoding(source, QByteArrayLiteral("/")));
    metadata.write("\nDeletionDate=");
    metadata.write(QDateTime::currentDateTime().toString(QStringLiteral("yyyy-MM-ddTHH:mm:ss")).toUtf8());
    metadata.write("\n");
    if (!metadata.commit())
        return false;

    const bool moved = QFile::rename(source, trash + QLatin1Char('/') + targetName);
    if (!moved)
        QFile::remove(infoDirectory + QLatin1Char('/') + targetName + QStringLiteral(".trashinfo"));
    return moved;
}

bool SystemBridge::copyUrls(const QVariantList &urls, const QString &destination) const
{
    QDir target(normalizedPath(destination));
    bool ok = true;
    for (const QVariant &item : urls) {
        const QString source = normalizedPath(item.toString());
        QFileInfo info(source);
        ok = copyRecursively(source, target.filePath(info.fileName())) && ok;
    }
    return ok;
}

QVariantList SystemBridge::flatpakCatalog() const
{
    return {
        QVariantMap{{QStringLiteral("name"), QStringLiteral("Steam")}, {QStringLiteral("id"), QStringLiteral("com.valvesoftware.Steam")}, {QStringLiteral("category"), QStringLiteral("Games")}, {QStringLiteral("color"), QStringLiteral("#4C77D9")}},
        QVariantMap{{QStringLiteral("name"), QStringLiteral("Firefox")}, {QStringLiteral("id"), QStringLiteral("org.mozilla.firefox")}, {QStringLiteral("category"), QStringLiteral("Web")}, {QStringLiteral("color"), QStringLiteral("#F36A3F")}},
        QVariantMap{{QStringLiteral("name"), QStringLiteral("VLC")}, {QStringLiteral("id"), QStringLiteral("org.videolan.VLC")}, {QStringLiteral("category"), QStringLiteral("Media")}, {QStringLiteral("color"), QStringLiteral("#F49A36")}},
        QVariantMap{{QStringLiteral("name"), QStringLiteral("Krita")}, {QStringLiteral("id"), QStringLiteral("org.kde.krita")}, {QStringLiteral("category"), QStringLiteral("Create")}, {QStringLiteral("color"), QStringLiteral("#8266DE")}},
        QVariantMap{{QStringLiteral("name"), QStringLiteral("Bottles")}, {QStringLiteral("id"), QStringLiteral("com.usebottles.bottles")}, {QStringLiteral("category"), QStringLiteral("Windows apps")}, {QStringLiteral("color"), QStringLiteral("#34B5AC")}},
        QVariantMap{{QStringLiteral("name"), QStringLiteral("Discord")}, {QStringLiteral("id"), QStringLiteral("com.discordapp.Discord")}, {QStringLiteral("category"), QStringLiteral("Social")}, {QStringLiteral("color"), QStringLiteral("#6575DD")}}
    };
}

QVariantList SystemBridge::installedFlatpaks() const
{
    QVariantList result;
    const QString output = capture(QStringLiteral("flatpak"),
                                   {QStringLiteral("list"), QStringLiteral("--app"),
                                    QStringLiteral("--columns=name,application,version")});
    for (const QString &line : output.split(QLatin1Char('\n'), Qt::SkipEmptyParts)) {
        const QStringList fields = line.split(QLatin1Char('\t'));
        if (fields.size() >= 2)
            result << QVariantMap{{QStringLiteral("name"), fields.at(0)},
                                  {QStringLiteral("id"), fields.at(1)},
                                  {QStringLiteral("version"), fields.value(2)}};
    }
    return result;
}

bool SystemBridge::installFlatpak(const QString &appId) const
{
    if (!QRegularExpression(QStringLiteral("^[A-Za-z0-9._-]+$")).match(appId).hasMatch())
        return false;
    return start(QStringLiteral("konsole"),
                 {QStringLiteral("--new-tab"), QStringLiteral("-p"), QStringLiteral("tabtitle=AR Software"),
                  QStringLiteral("-e"), QStringLiteral("flatpak"), QStringLiteral("install"),
                  QStringLiteral("--user"), QStringLiteral("flathub"), appId});
}

QString SystemBridge::checkUpdates() const
{
    QString output = capture(QStringLiteral("pkcon"), {QStringLiteral("get-updates")});
    if (output.isEmpty())
        output = QStringLiteral("PackageKit is not available or no updates were returned.");
    return output;
}

bool SystemBridge::installUpdates() const
{
    return start(QStringLiteral("konsole"),
                 {QStringLiteral("-p"), QStringLiteral("tabtitle=AR Updater"), QStringLiteral("-e"),
                  QStringLiteral("pkcon"), QStringLiteral("update")});
}

QVariantMap SystemBridge::systemInfo() const
{
    QString pretty = QStringLiteral("AR OS");
    QFile osRelease(QStringLiteral("/etc/os-release"));
    if (osRelease.open(QIODevice::ReadOnly)) {
        for (const QString &line : QString::fromUtf8(osRelease.readAll()).split(QLatin1Char('\n'))) {
            if (line.startsWith(QStringLiteral("PRETTY_NAME=")))
                pretty = line.section(QLatin1Char('='), 1).remove(QLatin1Char('"'));
        }
    }
    QString cpu;
    QFile cpuInfo(QStringLiteral("/proc/cpuinfo"));
    if (cpuInfo.open(QIODevice::ReadOnly)) {
        for (const QString &line : QString::fromUtf8(cpuInfo.readAll()).split(QLatin1Char('\n'))) {
            if (line.startsWith(QStringLiteral("model name"))) {
                cpu = line.section(QLatin1Char(':'), 1).trimmed();
                break;
            }
        }
    }
    QString memory = capture(QStringLiteral("sh"),
                             {QStringLiteral("-c"), QStringLiteral("free -h | awk '/Mem:/ {print $2}'")});
    return {{QStringLiteral("product"), QStringLiteral("AR OS")},
            {QStringLiteral("version"), QStringLiteral(AR_OS_VERSION)},
            {QStringLiteral("base"), pretty},
            {QStringLiteral("kernel"), QSysInfo::kernelVersion()},
            {QStringLiteral("architecture"), QSysInfo::currentCpuArchitecture()},
            {QStringLiteral("cpu"), cpu},
            {QStringLiteral("memory"), memory},
            {QStringLiteral("host"), QSysInfo::machineHostName()},
            {QStringLiteral("session"), qEnvironmentVariable("XDG_SESSION_TYPE", QStringLiteral("unknown"))}};
}

bool SystemBridge::applyOobe(const QVariantMap &values)
{
    const QString directory = QStandardPaths::writableLocation(QStandardPaths::ConfigLocation)
        + QStringLiteral("/ar-os");
    QDir().mkpath(directory);
    QSaveFile file(directory + QStringLiteral("/oobe.json"));
    if (!file.open(QIODevice::WriteOnly))
        return false;
    QJsonObject object = QJsonObject::fromVariantMap(values);
    object.insert(QStringLiteral("completed"), true);
    object.insert(QStringLiteral("completedAt"), QDateTime::currentDateTimeUtc().toString(Qt::ISODate));
    file.write(QJsonDocument(object).toJson(QJsonDocument::Indented));
    if (!file.commit())
        return false;

    setAppearance(values.value(QStringLiteral("appearance"), QStringLiteral("light")).toString());
    setWallpaper(values.value(QStringLiteral("wallpaper"), QStringLiteral("ribbon")).toString());

    start(QStringLiteral("pkexec"), {QStringLiteral("ar-system-helper"),
                                     QStringLiteral("apply-oobe")});
    return true;
}

bool SystemBridge::oobeComplete() const
{
    QFile file(QStandardPaths::writableLocation(QStandardPaths::ConfigLocation)
               + QStringLiteral("/ar-os/oobe.json"));
    if (!file.open(QIODevice::ReadOnly))
        return false;
    return QJsonDocument::fromJson(file.readAll()).object().value(QStringLiteral("completed")).toBool();
}

void SystemBridge::lock() const { start(QStringLiteral("ar-lock")); }
void SystemBridge::suspend() const { start(QStringLiteral("systemctl"), {QStringLiteral("suspend")}); }
void SystemBridge::restart() const { start(QStringLiteral("systemctl"), {QStringLiteral("reboot")}); }
void SystemBridge::shutdown() const { start(QStringLiteral("systemctl"), {QStringLiteral("poweroff")}); }
