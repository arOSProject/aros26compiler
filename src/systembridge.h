#pragma once

#include <QObject>
#include <QVariantList>
#include <QVariantMap>

#include <memory>

class QTimer;
class SearchRegistry;

class SystemBridge final : public QObject
{
    Q_OBJECT
    Q_PROPERTY(bool wifiEnabled READ wifiEnabled WRITE setWifiEnabled NOTIFY stateChanged)
    Q_PROPERTY(bool bluetoothEnabled READ bluetoothEnabled WRITE setBluetoothEnabled NOTIFY stateChanged)
    Q_PROPERTY(int volume READ volume WRITE setVolume NOTIFY stateChanged)
    Q_PROPERTY(int brightness READ brightness WRITE setBrightness NOTIFY stateChanged)
    Q_PROPERTY(int battery READ battery NOTIFY stateChanged)
    Q_PROPERTY(QString networkName READ networkName NOTIFY stateChanged)
    Q_PROPERTY(QString userName READ userName CONSTANT)
    Q_PROPERTY(QString displayName READ displayName NOTIFY stateChanged)
    Q_PROPERTY(QString appearance READ appearance WRITE setAppearance NOTIFY appearanceChanged)
    Q_PROPERTY(QString wallpaper READ wallpaper WRITE setWallpaper NOTIFY appearanceChanged)
    Q_PROPERTY(QVariantList applications READ applications NOTIFY applicationsChanged)

public:
    explicit SystemBridge(QObject *parent = nullptr);
    ~SystemBridge() override;

    bool wifiEnabled() const { return m_wifiEnabled; }
    bool bluetoothEnabled() const { return m_bluetoothEnabled; }
    int volume() const { return m_volume; }
    int brightness() const { return m_brightness; }
    int battery() const { return m_battery; }
    QString networkName() const { return m_networkName; }
    QString userName() const;
    QString displayName() const;
    QString appearance() const;
    QString wallpaper() const;
    QVariantList applications() const { return m_applications; }

    void setWifiEnabled(bool enabled);
    void setBluetoothEnabled(bool enabled);
    void setVolume(int value);
    void setBrightness(int value);
    void setAppearance(const QString &appearance);
    void setWallpaper(const QString &wallpaper);

    Q_INVOKABLE void refresh();
    Q_INVOKABLE void refreshApplications();
    Q_INVOKABLE QVariantList search(const QString &query) const;
    Q_INVOKABLE bool launchDesktop(const QString &desktopId) const;
    Q_INVOKABLE bool launchCommand(const QString &command) const;
    Q_INVOKABLE QVariantList listDirectory(const QString &path) const;
    Q_INVOKABLE QVariantList volumes() const;
    Q_INVOKABLE bool unmountVolume(const QString &device) const;
    Q_INVOKABLE QString homePath() const;
    Q_INVOKABLE QString parentPath(const QString &path) const;
    Q_INVOKABLE bool openPath(const QString &path) const;
    Q_INVOKABLE bool createFolder(const QString &parent, const QString &name) const;
    Q_INVOKABLE bool renamePath(const QString &path, const QString &name) const;
    Q_INVOKABLE bool moveToTrash(const QString &path) const;
    Q_INVOKABLE bool copyUrls(const QVariantList &urls, const QString &destination) const;
    Q_INVOKABLE QVariantList flatpakCatalog() const;
    Q_INVOKABLE QStringList searchProviders() const;
    Q_INVOKABLE QVariantList installedFlatpaks() const;
    Q_INVOKABLE bool installFlatpak(const QString &appId) const;
    Q_INVOKABLE QString checkUpdates() const;
    Q_INVOKABLE bool installUpdates() const;
    Q_INVOKABLE QVariantMap systemInfo() const;
    Q_INVOKABLE bool applyOobe(const QVariantMap &values);
    Q_INVOKABLE bool oobeComplete() const;
    Q_INVOKABLE void lock() const;
    Q_INVOKABLE void suspend() const;
    Q_INVOKABLE void restart() const;
    Q_INVOKABLE void shutdown() const;

signals:
    void stateChanged();
    void appearanceChanged();
    void applicationsChanged();
    void operationFailed(const QString &message);

private:
    static QString capture(const QString &program, const QStringList &arguments = {});
    static QString desktopExec(const QString &path);
    static QString desktopName(const QString &path);
    static QString desktopIcon(const QString &path);
    static QString normalizedPath(const QString &path);
    static bool start(const QString &program, const QStringList &arguments = {});
    void loadAppearance();

    bool m_wifiEnabled = true;
    bool m_bluetoothEnabled = false;
    int m_volume = 50;
    int m_brightness = 70;
    int m_battery = -1;
    QString m_networkName;
    QString m_appearance = QStringLiteral("light");
    QString m_wallpaper = QStringLiteral("ribbon");
    QVariantList m_applications;
    QTimer *m_refreshTimer = nullptr;
    std::unique_ptr<SearchRegistry> m_searchRegistry;
};
