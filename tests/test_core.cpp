#include "systembridge.h"

#include <QFileInfo>
#include <QTemporaryDir>
#include <QtTest>

class CoreTests final : public QObject
{
    Q_OBJECT

private slots:
    void reportsHomeDirectory()
    {
        SystemBridge bridge;
        QVERIFY(!bridge.homePath().isEmpty());
        QVERIFY(QFileInfo(bridge.homePath()).isDir());
    }

    void rejectsUnsafeFolderNames()
    {
        QTemporaryDir directory;
        QVERIFY(directory.isValid());
        SystemBridge bridge;
        QVERIFY(!bridge.createFolder(directory.path(), QStringLiteral("../escape")));
        QVERIFY(!bridge.createFolder(directory.path(), QStringLiteral("")));
        QVERIFY(bridge.createFolder(directory.path(), QStringLiteral("safe")));
    }

    void exposesStoreCatalog()
    {
        SystemBridge bridge;
        const QVariantList catalog = bridge.flatpakCatalog();
        QVERIFY(catalog.size() >= 4);
        QVERIFY(catalog.first().toMap().contains(QStringLiteral("id")));
    }
};

QTEST_MAIN(CoreTests)
#include "test_core.moc"
