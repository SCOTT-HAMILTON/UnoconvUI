#include "desktopbackend.h"

#include <QDebug>
#include <QFileDialog>
#include <QStandardPaths>

#include <QDesktopServices>
#include <QFile>
#include <QFileInfo>
#include <QHttpPart>
#include <QNetworkAccessManager>
#include <QNetworkRequest>
#include <QUrl>

DesktopBackend::DesktopBackend(QObject *parent) : QObject(parent),
    m_host("192.168.1.23"), m_reply(nullptr)
{

}

void DesktopBackend::init()
{
    emit readyForFileSelection();
}

QString DesktopBackend::getPdfFile() const
{
    return m_pdf_file;
}

void DesktopBackend::openFileDialog()
{
    QString filename = QFileDialog::getOpenFileName(nullptr,
        tr("Open File to convert"),
        QStandardPaths::writableLocation(QStandardPaths::DownloadLocation),
        tr("Any file supported by unoconv (*.*)"));
    emit fileSelected();
    convertFile(filename);
}

void DesktopBackend::openPdf(const QString &pdf_file)
{
    auto url = QUrl::fromLocalFile(pdf_file);
    qDebug() << "[log] Openning pdf " << url.toString();
    emit debugChangeErrorArea("Openning pdf `"+url.toString()+"`");
    QDesktopServices::openUrl(url);
}

void DesktopBackend::onRequestReplyFinished()
{
    if (!m_reply) {
        qDebug() << "[error] received finished signal from POST request reply but reply is nullptr";
        emit debugChangeErrorArea("received finished signal from POST request reply but reply is nullptr");
    } else if (m_reply->error() != QNetworkReply::NoError) {
        qDebug() << "[error] request failed : " << m_reply->errorString();
        emit debugChangeErrorArea("request failed : "+m_reply->errorString());
    } else {
        // Write to Pdf file
        QString download_folder = QStandardPaths::writableLocation(QStandardPaths::DownloadLocation);
        QString pdf_file_path = download_folder+"/"+m_file_to_convert_basename+".pdf";
        m_pdf_file = pdf_file_path;
        qDebug() << "[log] writing to pdf file `" << pdf_file_path << "`";
        emit debugChangeErrorArea("writing to pdf file `"+pdf_file_path+"`");
        QFile pdf(pdf_file_path);
        pdf.open(QIODevice::WriteOnly);
        pdf.write(m_reply->readAll());
        pdf.close();
        qDebug() << "[log] File Converted";
        emit debugChangeErrorArea("File Converted");
        emit fileConverted(pdf_file_path);
        openPdf(pdf_file_path);
    }
}

void DesktopBackend::onRequestReplyUploadProgress(qint64 bytesSent, qint64 bytesTotal)
{
    float pc = static_cast<float>(bytesSent)/bytesTotal*100.0f;
    qDebug() << "[log] " << pc << "% bytes uploaded";
    emit debugChangeErrorArea(QString::number(pc)+"% bytes uploaded");
}

void DesktopBackend::onRequestReplyDownloadProgress(qint64 bytesReceived, qint64 bytesTotal)
{
    float pc = static_cast<float>(bytesReceived)/bytesTotal*100.0f;
    qDebug() << "[log] " << pc << "% bytes downloaded";
    emit debugChangeErrorArea(QString::number(pc)+"% bytes downloaded");
}

void DesktopBackend::onRequestReplyErrorOccured(QNetworkReply::NetworkError errorCode)
{
    qDebug() << "Error occured : " << errorCode;
    if (m_reply) {
        qDebug() << "error : " << m_reply->errorString();
    }
}

void DesktopBackend::convertFile(const QString &filename)
{
    // Preparing Data
    auto file = new QFile(filename);
    qDebug() << "filename : " << filename;
    if (!file->exists()) {
        qDebug() << "[error] filename to convert `" << filename << "`, doesn't exist";
        emit debugChangeErrorArea("filename to convert `" + filename + "`, doesn't exist");
    } else {
        file->open(QIODevice::ReadOnly);
        QString input_file_basename;
        {
            auto fileInfo = QFileInfo(filename);
            input_file_basename = fileInfo.completeBaseName();
            m_file_to_convert_basename = fileInfo.baseName();
        }

        // Making Multipart formdata
        auto multiPart = new QHttpMultiPart(QHttpMultiPart::FormDataType);
        QHttpPart filePart;
        filePart.setHeader(QNetworkRequest::ContentDispositionHeader, QVariant("form-data; name=\"file\"; filename=\""+input_file_basename+"\""));
        filePart.setBodyDevice(file);
        file->setParent(multiPart);
        multiPart->append(filePart);

        QUrl url("http://"+m_host+"/unoconv/pdf");
        QNetworkRequest request(url);
        request.setAttribute(QNetworkRequest::Http2AllowedAttribute, false);
        request.setHeader(QNetworkRequest::UserAgentHeader, QString("curl/7.73.0").toUtf8());
        request.setRawHeader(QString("Accept").toUtf8(), QString("*/*").toUtf8());
        request.setRawHeader(QString("Accept-Encoding").toUtf8(), QString("identity").toUtf8());

        // Sending Request
        qDebug() << "[log] Sending POST Request...";
        emit debugChangeErrorArea("Sending POST Request...");
        if (m_reply != nullptr) {
            QObject::disconnect(m_reply, &QNetworkReply::finished, this, &DesktopBackend::onRequestReplyFinished);
            QObject::disconnect(m_reply, &QNetworkReply::uploadProgress, this, &DesktopBackend::onRequestReplyUploadProgress);
            QObject::disconnect(m_reply, &QNetworkReply::downloadProgress, this, &DesktopBackend::onRequestReplyDownloadProgress);
            QObject::disconnect(m_reply, &QNetworkReply::errorOccurred, this, &DesktopBackend::onRequestReplyErrorOccured);
        }
        QNetworkAccessManager* accessManager = new QNetworkAccessManager(this);
        m_reply = accessManager->post(request, multiPart);
        QObject::connect(m_reply, &QNetworkReply::finished, this, &DesktopBackend::onRequestReplyFinished);
        QObject::connect(m_reply, &QNetworkReply::uploadProgress, this, &DesktopBackend::onRequestReplyUploadProgress);
        QObject::connect(m_reply, &QNetworkReply::downloadProgress, this, &DesktopBackend::onRequestReplyDownloadProgress);
        QObject::connect(m_reply, &QNetworkReply::errorOccurred, this, &DesktopBackend::onRequestReplyErrorOccured);
    }
}
