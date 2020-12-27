#ifndef DESKTOPBACKEND_H
#define DESKTOPBACKEND_H

#include <QObject>
#include <QNetworkReply>
#include <QQmlEngine>

class DesktopBackend : public QObject
{
	Q_OBJECT
	Q_PROPERTY(QString pdf_file READ getPdfFile)
public:
	explicit DesktopBackend(QObject *parent = nullptr);
	static void registerTypes(const char *uri);
	static QObject *singletonProvider(QQmlEngine* , QJSEngine *);
	static DesktopBackend* instance();
	Q_INVOKABLE void init();
	QString getPdfFile() const;

signals:
	void readyForFileSelection();
	void fileSelected();
	void fileConverted(QString);
	void debugChangeErrorArea(QString);
	void conversionFailure(QString);

	// Not to be used, just for letting QML be happy
	void intentOpenDocument();
	void noStartupIntent();
	void permissionsGranted();
	void permissionsDenied();

	public slots:
		Q_INVOKABLE void openFileDialog();
	Q_INVOKABLE void openPdf(const QString& pdf_file);
	Q_INVOKABLE void convertSelectedFile();
	void onRequestReplyFinished();
	void onRequestReplyUploadProgress(qint64 bytesSent, qint64 bytesTotal);
	void onRequestReplyDownloadProgress(qint64 bytesReceived, qint64 bytesTotal);
	void onRequestReplyErrorOccured(QNetworkReply::NetworkError errorCode);

private:
	QString m_pdf_file;
	QString m_selected_file;
	QString m_file_to_convert_basename;
	QString m_host;
	QNetworkReply* m_reply;

	void convertFile(const QString& filename);

};

#endif // DESKTOPBACKEND_H
