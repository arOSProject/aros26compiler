#include "searchprovider.h"

#include <QDir>
#include <QDirIterator>
#include <QFileInfo>
#include <QPair>
#include <QVariantMap>

namespace {
class ApplicationProvider final : public SearchProvider
{
public:
    QString id() const override { return QStringLiteral("applications"); }
    QVariantList query(const QString &text, const QVariantList &applications,
                       int limit) const override
    {
        QVariantList result;
        for (const QVariant &application : applications) {
            const QVariantMap map = application.toMap();
            if (text.isEmpty()
                || map.value(QStringLiteral("name")).toString().contains(text, Qt::CaseInsensitive)
                || map.value(QStringLiteral("subtitle")).toString().contains(text, Qt::CaseInsensitive))
                result << map;
            if (result.size() >= limit)
                break;
        }
        return result;
    }
};

class SettingsProvider final : public SearchProvider
{
public:
    QString id() const override { return QStringLiteral("settings"); }
    QVariantList query(const QString &text, const QVariantList &, int limit) const override
    {
        static const QList<QPair<QString, QString>> settings = {
            {QStringLiteral("Wi-Fi and network"), QStringLiteral("NetworkManager connections and VPN")},
            {QStringLiteral("Bluetooth"), QStringLiteral("Devices, pairing, and audio")},
            {QStringLiteral("Sound"), QStringLiteral("Volume, output, and microphone")},
            {QStringLiteral("Display"), QStringLiteral("Brightness, scaling, and monitors")},
            {QStringLiteral("Wallpaper"), QStringLiteral("Desktop background")},
            {QStringLiteral("Theme and appearance"), QStringLiteral("Light and dark appearance")},
            {QStringLiteral("Notifications"), QStringLiteral("Alerts and do not disturb")},
            {QStringLiteral("Security and privacy"), QStringLiteral("Lock, permissions, and diagnostics")},
            {QStringLiteral("Accounts"), QStringLiteral("Users and administrator access")},
            {QStringLiteral("System Update"), QStringLiteral("PackageKit and Flatpak updates")},
            {QStringLiteral("About AR OS"), QStringLiteral("Hardware and system information")}
        };
        QVariantList result;
        for (const auto &entry : settings) {
            if (!text.isEmpty() && !entry.first.contains(text, Qt::CaseInsensitive)
                && !entry.second.contains(text, Qt::CaseInsensitive))
                continue;
            result << QVariantMap{{QStringLiteral("type"), QStringLiteral("setting")},
                                  {QStringLiteral("name"), entry.first},
                                  {QStringLiteral("subtitle"), entry.second},
                                  {QStringLiteral("icon"), QStringLiteral("preferences-system")},
                                  {QStringLiteral("action"), QStringLiteral("settings")}};
            if (result.size() >= limit)
                break;
        }
        return result;
    }
};

class FileProvider final : public SearchProvider
{
public:
    QString id() const override { return QStringLiteral("files"); }
    QVariantList query(const QString &text, const QVariantList &, int limit) const override
    {
        QVariantList result;
        if (text.trimmed().isEmpty())
            return result;
        QDirIterator files(QDir::homePath(), QDir::Files | QDir::Dirs | QDir::NoDotAndDotDot,
                           QDirIterator::Subdirectories);
        int visited = 0;
        while (files.hasNext() && result.size() < limit && visited < 5000) {
            const QString path = files.next();
            ++visited;
            const QFileInfo info(path);
            if (!info.fileName().contains(text, Qt::CaseInsensitive))
                continue;
            result << QVariantMap{{QStringLiteral("type"), QStringLiteral("file")},
                                  {QStringLiteral("name"), info.fileName()},
                                  {QStringLiteral("subtitle"), info.absolutePath()},
                                  {QStringLiteral("icon"), info.isDir() ? QStringLiteral("folder") : QStringLiteral("text-x-generic")},
                                  {QStringLiteral("path"), path}};
        }
        return result;
    }
};
}

SearchRegistry::SearchRegistry()
{
    addProvider(std::make_unique<ApplicationProvider>());
    addProvider(std::make_unique<SettingsProvider>());
    addProvider(std::make_unique<FileProvider>());
}

void SearchRegistry::addProvider(std::unique_ptr<SearchProvider> provider)
{
    if (provider)
        m_providers.push_back(std::move(provider));
}

QVariantList SearchRegistry::query(const QString &text, const QVariantList &applications,
                                   int limit) const
{
    QVariantList result;
    for (const auto &provider : m_providers) {
        if (result.size() >= limit)
            break;
        const QVariantList contribution = provider->query(text.trimmed(), applications,
                                                           limit - result.size());
        result.append(contribution);
        if (result.size() >= limit)
            break;
    }
    return result;
}

QStringList SearchRegistry::providerIds() const
{
    QStringList result;
    for (const auto &provider : m_providers)
        result << provider->id();
    return result;
}
