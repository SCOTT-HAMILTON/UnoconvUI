#include <QApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>

#include <QLocale>
#include <QTranslator>

#ifdef Q_OS_ANDROID
#include "androidbackend.h"
#else
#include "desktopbackend.h"
#endif

int main(int argc, char *argv[])
{
    QApplication::setAttribute(Qt::AA_EnableHighDpiScaling);

    QApplication app(argc, argv);

    QTranslator translator;
    QLocale locale;//(QLocale::English, QLocale::UnitedStates);

    if (translator.load(":/translations/UnoconvUI_"+locale.name()+".qm"))
        app.installTranslator(&translator);

    QQmlApplicationEngine engine;
    const QUrl url(QStringLiteral("qrc:/main.qml"));
    QObject::connect(&engine, &QQmlApplicationEngine::objectCreated,
                     &app, [url](QObject *obj, const QUrl &objUrl) {
        if (!obj && url == objUrl)
            QApplication::exit(-1);
    }, Qt::QueuedConnection);

#ifdef Q_OS_ANDROID
    AndroidBackend androidBackend;
    AndroidBackend::setInstance(&androidBackend);
    engine.rootContext()->setContextProperty("backend", &androidBackend);
#else
    DesktopBackend desktopBackend;
    engine.rootContext()->setContextProperty("backend", &desktopBackend);
#endif


    engine.load(url);

#ifdef Q_OS_ANDROID
    androidBackend.init();
#else
    desktopBackend.init();
#endif

    return app.exec();
}
