package org.scotthamilton.unoconvui;

import android.content.ContentResolver;
import android.os.Environment;
import android.net.Uri;
import android.os.Build;
import java.io.BufferedReader;
import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.OutputStream;
import java.io.UnsupportedEncodingException;
import java.net.HttpURLConnection;
import java.net.MalformedURLException;
import java.net.URL;
import java.net.URLEncoder;
import java.util.UUID;
import java.util.logging.Logger;

public class WebServiceFileConvertRunnable implements Runnable
{
        private static final Logger logger = Logger.getLogger("org.scotthamilton.unoconvui");
        private static final String m_ip_address = "192.168.1.23";
        private MyActivity m_activity;
        private Uri m_input_file_uri;


        public WebServiceFileConvertRunnable(MyActivity activity, Uri input_file_uri) {
                m_activity = activity;
                m_input_file_uri = input_file_uri;
                }
        // this method is called on Android Ui Thread

        public static byte[] readAllBytes(InputStream inputStream) throws IOException {
             final int bufLen = 4 * 0x400; // 4KB
             byte[] buf = new byte[bufLen];
             int readLen;
             IOException exception = null;

             try {
                 try (ByteArrayOutputStream outputStream = new ByteArrayOutputStream()) {
                     while ((readLen = inputStream.read(buf, 0, bufLen)) != -1)
                         outputStream.write(buf, 0, readLen);

                     return outputStream.toByteArray();
                 }
             } catch (IOException e) {
                 exception = e;
                 throw e;
             } finally {
                 if (exception == null) inputStream.close();
                 else try {
                     inputStream.close();
                 } catch (IOException e) {
                     exception.addSuppressed(e);
                 }
             }
         }

        // Copy an InputStream to a File.
        //
        private void copyInputStreamToFile(InputStream in, File file) {
                OutputStream out = null;
                long total_length = 0;
                try {
                        out = new FileOutputStream(file);
                        byte[] buf = new byte[10240];
                        int len;
                        while((len=in.read(buf))>0){
                                out.write(buf,0,len);
                                total_length += len;
                        }
                }
                catch (Exception e) {
                        e.printStackTrace();
                }
                finally {
                        // Ensure that the InputStreams are closed even if there's an exception.
                        try {
                                if ( out != null ) {
                                        out.close();
                                }

                                // If you want to close the "in" InputStream yourself then remove this
                                // from here but ensure that you close it yourself eventually.
                                in.close();
                        }
                        catch ( IOException e ) {
                                e.printStackTrace();
                        }
                }
        }

        @Override
        public void run() {
                Thread thread = new Thread(new Runnable() {
                        public void run() {
                                NativeFunctions.debugChangeErrorArea("WebService Runnable Thread started");
                                try  {
                                        // Prepare Data
                                        NativeFunctions.debugChangeErrorArea("Preparing Data...");
                                        InputStream fileReader = m_activity.getContentResolver().openInputStream(m_input_file_uri);
                                        String input_file_basename = null;
                                        try {
                                                input_file_basename = UriUtils.getUriRealBasename(m_activity, m_input_file_uri);
                                                NativeFunctions.debugChangeErrorArea("Input File Basename : `"+input_file_basename+"`");
                                        } catch (RuntimeException e) {
                                                // Couldn't extract
                                                NativeFunctions.debugChangeErrorArea("Error: couldn't extract basename from Uri : "+m_input_file_uri.toString());
                                                NativeFunctions.conversionFailure("Filename to convert is invalid");
                                                return;
                                        }
                                        String str_boundary = UUID.randomUUID().toString();
                                        byte[] boundary = str_boundary.getBytes();
                                        byte[] heading =
   ("\r\nContent-Disposition: form-data; name=\"file\"; filename=\""+input_file_basename+"\""
 + "\r\nContent-Type: application/octet-stream\r\n\r\n").getBytes();
                                        byte[] file = readAllBytes(fileReader); // 50 MB max
                                        ByteArrayOutputStream outputStream = new ByteArrayOutputStream( );
                                        outputStream.write("--".getBytes());
                                        outputStream.write(boundary);
                                        outputStream.write(heading);
                                        outputStream.write(file);
                                        outputStream.write("\r\n--".getBytes());
                                        outputStream.write(boundary);
                                        outputStream.write("--\r\n".getBytes());
                                        byte[] data = outputStream.toByteArray( );

                                        NativeFunctions.debugChangeErrorArea("Sending Data...");
                                        // Send Data
                                        URL url = null;
                                        try {
                                                url = new URL("http://"+m_ip_address+"/unoconv/pdf");
                                                } catch (MalformedURLException e){
                                                        logger.severe("MalformedURLException when connecting to web service : "+e.toString());
                                                        NativeFunctions.debugChangeErrorArea("MalformedURLException when connecting to web service : "+e.toString());
                                                        NativeFunctions.conversionFailure("Bad server Url");
                                                }
                                        HttpURLConnection client = null;
                                        try {
                                                logger.severe("Openning Connection...");
                                                NativeFunctions.debugChangeErrorArea("Openning Connection...");
                                                client = (HttpURLConnection) url.openConnection();
                                                client.setUseCaches(false);
                                                client.setDoOutput(true);
                                                client.setDoInput(true);
                                                logger.severe("Opened Connection");
                                                NativeFunctions.debugChangeErrorArea("Opened Connection");
                                                client.setRequestMethod("POST");
                                                client.setRequestProperty("Host", m_ip_address);
                                                client.setRequestProperty("User-Agent","curl/7.73.0");
                                                client.setRequestProperty("Accept","*/*");
                                                client.setRequestProperty("Content-Length",String.valueOf(data.length));
                                                client.setRequestProperty("Content-Type","multipart/form-data; boundary="+str_boundary);
                                                client.setRequestProperty("Accept-Encoding", "identity");
                                                client.setDoOutput(true);

                                                logger.severe("Writing Data POST...");
                                                NativeFunctions.debugChangeErrorArea("Writing Data to POST request...");
                                                // Write data to POST
                                                client.setFixedLengthStreamingMode(data.length);
                                                OutputStream wr = client.getOutputStream();
                                                wr.write(data);
                                                wr.flush();
                                                wr.close();
                                                logger.severe("Wrote Data");
                                                NativeFunctions.debugChangeErrorArea("Data written to request");
                                                int status = client.getResponseCode();
                                                logger.severe("Answer : "+status);
                                                NativeFunctions.debugChangeErrorArea("Answer : "+status);
                                                if (status == 415) {
                                                        logger.severe("Unsupported Data Type, can't convert");
                                                        NativeFunctions.debugChangeErrorArea("Unsupported Data Type, can't convert");
                                                        return;
                                                }

                                                // Read answer
                                                NativeFunctions.debugChangeErrorArea("Reading Answer...");
                                                logger.severe("Reading Answer...");
                                                File download_dir = Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_DOWNLOADS);
                                                String output_file_path = "";
                                                final int lastPeriodPos = input_file_basename.lastIndexOf('.');
                                                if (lastPeriodPos <= 0) {
                                                        output_file_path = download_dir.getPath()+"/"+input_file_basename;
                                                } else {
                                                        output_file_path = download_dir.getPath()+"/"+input_file_basename.substring(0, lastPeriodPos)+".pdf";
                                                }
                                                NativeFunctions.debugChangeErrorArea("Writing to "+output_file_path);
                                                logger.severe("Writing to file : `"+output_file_path+"`");
                                                File new_file = new File(output_file_path);
                                                new_file.createNewFile();
                                                copyInputStreamToFile(client.getInputStream(), new_file);
                                                NativeFunctions.debugChangeErrorArea("File Converted");
                                                logger.severe("File Converted");
                                                NativeFunctions.onFileConverted(output_file_path);
                                        } catch ( IOException e ){
                                                logger.severe("IOException when connecting to web service : "+e.toString());
                                                NativeFunctions.debugChangeErrorArea("IOException when connecting to web service : "+e.toString());
                                                NativeFunctions.conversionFailure("Can't connect to webservice, verify your internet ?");
                                        } catch ( SecurityException e){
                                                logger.severe("SecurityException when connecting to web service : "+e.toString());
                                                NativeFunctions.debugChangeErrorArea("SecurityException when connecting to web service : "+e.toString());
                                                NativeFunctions.conversionFailure("Security error when connecting to web service");
                                        } catch ( IllegalArgumentException e){
                                                logger.severe("IllegalArgumentException when connecting to web service : "+e.toString());
                                                NativeFunctions.debugChangeErrorArea("IllegalArgumentException when connecting to web service : "+e.toString());
                                                NativeFunctions.conversionFailure("Failed to connect to web service");
                                        } catch ( UnsupportedOperationException e){
                                                logger.severe("UnsupportedOperationException when connecting to web service : "+e.toString());
                                                NativeFunctions.debugChangeErrorArea("UnsupportedOperationException when connecting to web service : "+e.toString());
                                                NativeFunctions.conversionFailure("Failed to request web service");
                                        } finally {
                                                if(client != null) // Make sure the connection is not null.
                                                        client.disconnect();
                                                }
                                        } catch (Exception e) {
                                                e.printStackTrace();
                                                NativeFunctions.conversionFailure("Failed to convert");
                                        }
                                }
                        });
                        thread.start();
                }
        }
