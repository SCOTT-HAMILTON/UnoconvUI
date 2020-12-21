#ifndef ANDROIDBACKEND_H
#define ANDROIDBACKEND_H

#include <QObject>
#include <QtAndroid>

class AndroidBackend : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString pdf_file READ getPdfFile)

public:
    explicit AndroidBackend(QObject *parent = nullptr);
    static void setInstance(AndroidBackend* new_intance);
    static AndroidBackend* instance();
    void init();
    QString getPdfFile() const;

signals:
    void intentOpenDocument();
    void noStartupIntent();
    void fileSelected();
    void fileConverted(QString);
    void debugChangeErrorArea(QString);

public slots:
    Q_INVOKABLE void openFileDialog();
    Q_INVOKABLE void openPdf(const QString& pdf_file);
    Q_INVOKABLE void convertIntent();
    void convertFile(const QAndroidJniObject& uri);
    void gotOpenDocumentIntent(const QAndroidJniObject& uri);
    void gotNoStartupIntent();
    void gotFileSelected(const QAndroidJniObject& uri);
    void gotFileConverted(const QString& pdf_file);
    void gotDebugChangeErrorArea(const QString& debug_message);

private:
    static AndroidBackend* m_instance;
    QString m_pdf_file;
    QAndroidJniObject m_intent_open_object_uri;
};

#endif // ANDROIDBACKEND_H
