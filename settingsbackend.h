#ifndef SETTINGSBACKEND_H
#define SETTINGSBACKEND_H

#include <QObject>
#include <QSettings>
#include <QQmlEngine>

class SettingsBackend : public QObject
{
    Q_OBJECT
public:
    explicit SettingsBackend(QObject *parent = nullptr);
    static void registerTypes(const char *uri);
    static QObject *singletonProvider(QQmlEngine* engine, QJSEngine *);
    static SettingsBackend *instance();
    Q_INVOKABLE QString getWebServiceAddressSetting();
    Q_INVOKABLE int getWebServicePortSetting();

signals:
    void settingFailure(QString);
    void settingSuccess(QString);

public slots:
    Q_INVOKABLE void setWebServiceAddressSetting(const QString& address, bool informUi = true);
    Q_INVOKABLE void setWebServicePortSetting(int port, bool informUi = true);
};

#endif // SETTINGSBACKEND_H
