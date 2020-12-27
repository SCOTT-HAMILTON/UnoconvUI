#include "androidbackend.h"

static AndroidBackend *s_instance = nullptr;

AndroidBackend::AndroidBackend(QObject *parent) : QObject(parent)
{
}

void AndroidBackend::registerTypes(const char *uri)
{
    qmlRegisterSingletonType<AndroidBackend>(uri, 1, 0, "Backend", AndroidBackend::singletonProvider);
}

QObject *AndroidBackend::singletonProvider(QQmlEngine* qmlEngine, QJSEngine *)
{
    if (!s_instance) {
        s_instance = new AndroidBackend(qmlEngine);
    }
    return s_instance;
}

AndroidBackend *AndroidBackend::instance()
{
    return static_cast<AndroidBackend*>(s_instance);
}

void AndroidBackend::init()
{
    auto activity = QtAndroid::androidActivity();
    grantPermissions();
    activity.callMethod<void>("getIntents");
}

QString AndroidBackend::getPdfFile() const
{
    return m_pdf_file;
}

void AndroidBackend::openFileDialog()
{
    auto activity = QtAndroid::androidActivity();
    activity.callMethod<void>("openFileDialog");
}

void AndroidBackend::openPdf(const QString& pdf_file)
{
    auto activity = QtAndroid::androidActivity();
    auto file = QAndroidJniObject::fromString(pdf_file);
    activity.callMethod<void>("openPdfFile", "(Ljava/lang/String;)V", file.object());
}

void AndroidBackend::convertIntent()
{
    convertFile(m_intent_open_object_uri);
}

void AndroidBackend::convertSelectedFile()
{
    convertFile(m_file_selected_uri);
}

void AndroidBackend::grantPermissions()
{
    auto activity = QtAndroid::androidActivity();
    activity.callMethod<void>("grantPermissions");
}

void AndroidBackend::convertFile(const QAndroidJniObject &uri)
{
    emit debugChangeErrorArea("Running convertFile...");
    auto activity = QtAndroid::androidActivity();
    activity.callMethod<void>("convertFileWithLocalWebService", "(Landroid/net/Uri;)V", uri.object());
}

void AndroidBackend::gotOpenDocumentIntent(const QAndroidJniObject& uri)
{
    m_intent_open_object_uri = uri;
    emit intentOpenDocument();
}

void AndroidBackend::gotNoStartupIntent()
{
    emit noStartupIntent();
}

void AndroidBackend::gotFileSelected(const QAndroidJniObject &uri)
{
    m_file_selected_uri = uri;
    emit fileSelected();
    convertFile(uri);
}

void AndroidBackend::gotFileConverted(const QString &pdf_file)
{
    m_pdf_file = pdf_file;
    openPdf(pdf_file);
    emit fileConverted(pdf_file);
}

void AndroidBackend::gotPermissionsGranted()
{
    emit permissionsGranted();
}

void AndroidBackend::gotPermissionsDenied()
{
    emit permissionsDenied();
}

void AndroidBackend::gotDebugChangeErrorArea(const QString &debug_message)
{
    emit debugChangeErrorArea(debug_message);
}

void AndroidBackend::gotConversionFailure(const QString &error_message)
{
   emit conversionFailure(error_message);
}
