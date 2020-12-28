#include "settingsbackend.h"
#include "settings.hpp"

static SettingsBackend *s_instance = nullptr;

SettingsBackend::SettingsBackend(QObject *parent) : QObject(parent)
{
}

void SettingsBackend::registerTypes(const char *uri)
{
    qmlRegisterSingletonType<SettingsBackend>(uri, 1, 0, "SettingsBackend", SettingsBackend::singletonProvider);
}

QObject *SettingsBackend::singletonProvider(QQmlEngine *qmlEngine, QJSEngine *)
{
    if (!s_instance) {
        s_instance = new SettingsBackend(qmlEngine);
    }
    return s_instance;
}

SettingsBackend *SettingsBackend::instance()
{
    return static_cast<SettingsBackend*>(s_instance);
}

QString SettingsBackend::getWebServiceAddressSetting()
{
    QSettings settings;
    auto addressValue = settings.value(WEBSERVICE_ADDRESS);
    if (addressValue == QVariant()) {
        setWebServiceAddressSetting(WEBSERVICE_DEFAULT_ADDRESS, false);
        return WEBSERVICE_DEFAULT_ADDRESS;
    } else {
        return addressValue.toString();
    }
}

int SettingsBackend::getWebServicePortSetting()
{
    QSettings settings;
    auto portValue = settings.value(WEBSERVICE_PORT);
    if (portValue == QVariant()) {
        setWebServicePortSetting(WEBSERVICE_DEFAULT_PORT, false);
        return WEBSERVICE_DEFAULT_PORT;
    } else {
        return portValue.toInt();
    }
}

void SettingsBackend::setWebServiceAddressSetting(const QString &address, bool informUi)
{
    QUrl url(address);
    if (!url.isValid()) {
        qDebug() << "[error] invalid web service address : " << address;
        if (informUi) {
            emit settingFailure(tr("Invalid Web Service Address !"));
        }
    } else if (url.scheme().isEmpty()) {
        qDebug() << "[error] invalid web service address, no scheme : " << address;
        if (informUi) {
            emit settingFailure(tr("Address needs a scheme (for exemple https://)"));
        }
    } else {
        {
            QSettings settings;
            settings.setValue(WEBSERVICE_ADDRESS, address);
        }
        qDebug() << "[log] successfully saved web service address";
        if (informUi) {
            emit settingSuccess(tr("Web Service Address Saved !"));
        }
    }
}

void SettingsBackend::setWebServicePortSetting(int port, bool informUi)
{
    if (port < 0 || port > 100000) {
        qDebug() << "[error] invalid web service port, not in range [0;100 000] : " << port;
        if (informUi) {
            emit settingFailure(tr("Invalid Web Service Port, not in range [0;100 000]"));
        }
    } else {
        {
            QSettings settings;
            settings.setValue(WEBSERVICE_PORT, port);
        }
        qDebug() << "[log] successfully saved web service port";
        if (informUi) {
            emit settingSuccess(tr("Web Service Port Saved !"));
        }
    }
}
