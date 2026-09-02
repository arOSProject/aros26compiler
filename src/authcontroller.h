#pragma once

#include <QObject>

class AuthController final : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString error READ error NOTIFY errorChanged)

public:
    explicit AuthController(QObject *parent = nullptr);
    QString error() const { return m_error; }
    Q_INVOKABLE bool authenticate(const QString &password);

signals:
    void errorChanged();
    void unlocked();

private:
    QString m_error;
};

