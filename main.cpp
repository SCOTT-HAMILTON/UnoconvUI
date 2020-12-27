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
    qDebug() << "locale : " << locale.name();

    if (translator.load(":/translations/UnoconvUI_"+locale.name()+".qm")) {
        qDebug() << "Successfully loaded :/translations/UnoconvUI_"+locale.name()+".qm";
        app.installTranslator(&translator);
    }
    else
        qDebug() << "Couldn't load :/translations/UnoconvUI_" + locale.name() + ".qm";

    QQmlApplicationEngine engine;
#ifdef Q_OS_ANDROID
	AndroidBackend::registerTypes("org.scotthamilton.unoconvui");
#else
	DesktopBackend::registerTypes("org.scotthamilton.unoconvui");
#endif

    const QUrl url(QStringLiteral("qrc:/main.qml"));
    QObject::connect(&engine, &QQmlApplicationEngine::objectCreated,
                     &app, [url](QObject *obj, const QUrl &objUrl) {
        if (!obj && url == objUrl)
            QApplication::exit(-1);
    }, Qt::QueuedConnection);

    engine.load(url);

#ifdef Q_OS_ANDROID
	auto androidBackend = AndroidBackend::instance();
#else
	auto desktopBackend = DesktopBackend::instance();
#endif

#ifdef Q_OS_ANDROID
    androidBackend->init();
#else
    desktopBackend->init();
#endif

    return app.exec();
}
