#include <QApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>

#include <QUrl>
#include <QNetworkAccessManager>
#include <QNetworkRequest>

#include "androidbackend.h"

int main(int argc, char *argv[])
{
    QApplication::setAttribute(Qt::AA_EnableHighDpiScaling);

    QApplication app(argc, argv);
    AndroidBackend androidBackend;
    AndroidBackend::setInstance(&androidBackend);

    QQmlApplicationEngine engine;
    const QUrl url(QStringLiteral("qrc:/main.qml"));
    QObject::connect(&engine, &QQmlApplicationEngine::objectCreated,
                     &app, [url](QObject *obj, const QUrl &objUrl) {
        if (!obj && url == objUrl)
            QApplication::exit(-1);
    }, Qt::QueuedConnection);

    engine.rootContext()->setContextProperty("androidBackend", &androidBackend);

    engine.load(url);

    androidBackend.init();

    return app.exec();
}
