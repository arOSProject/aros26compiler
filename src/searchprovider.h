#pragma once

#include <QString>
#include <QStringList>
#include <QVariantList>

#include <memory>
#include <vector>

class SearchProvider
{
public:
    virtual ~SearchProvider() = default;
    virtual QString id() const = 0;
    virtual QVariantList query(const QString &text, const QVariantList &applications,
                               int limit) const = 0;
};

class SearchRegistry final
{
public:
    SearchRegistry();
    void addProvider(std::unique_ptr<SearchProvider> provider);
    QVariantList query(const QString &text, const QVariantList &applications,
                       int limit = 48) const;
    QStringList providerIds() const;

private:
    std::vector<std::unique_ptr<SearchProvider>> m_providers;
};

