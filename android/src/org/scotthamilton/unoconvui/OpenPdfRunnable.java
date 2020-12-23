package org.scotthamilton.unoconvui;

import android.content.ActivityNotFoundException;
import android.content.Intent;
import android.net.Uri;
import android.support.v4.content.FileProvider;
import java.io.File;
import java.util.logging.Logger;

public class OpenPdfRunnable implements Runnable
{
        private static final Logger logger = Logger.getLogger("org.scotthamilton.unoconvui");
        private MyActivity m_activity;
        private String m_pdf_file;

        public OpenPdfRunnable(MyActivity activity, String pdf_file) {
                m_activity = activity;
                m_pdf_file = pdf_file;
        }

        @Override
        public void run() {
                File file = new File(m_pdf_file);
                if (!file.exists()) {
                        logger.severe("Converted pdf file doesn't exist, can't open it");
                        return;
                }
                logger.severe("Pdf File "+m_pdf_file+" exists");
                NativeFunctions.debugChangeErrorArea(("Pdf File "+m_pdf_file+" exists"));
                Intent target = new Intent();
                target.setAction(android.content.Intent.ACTION_VIEW);
                Uri uri = FileProvider.getUriForFile(m_activity, "org.scotthamilton.unoconvui.fileprovider", file);
                target.setDataAndType(uri, "application/pdf");
                target.setFlags(Intent.FLAG_ACTIVITY_NO_HISTORY | Intent.FLAG_GRANT_READ_URI_PERMISSION);
                Intent intent = Intent.createChooser(target, "Open File");
                try {
                        m_activity.startActivityForResult(target, 10);
                } catch (ActivityNotFoundException e) {
                        logger.severe("No Pdf reader available, please install one");
                        NativeFunctions.debugChangeErrorArea("No Pdf reader available, please install one");
                        NativeFunctions.conversionFailure("No pdf reader available");
                }
        }
}
