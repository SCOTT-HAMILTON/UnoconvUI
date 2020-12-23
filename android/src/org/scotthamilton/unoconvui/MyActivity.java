package org.scotthamilton.unoconvui;

import android.Manifest;
import android.content.Context;
import android.content.Intent;
import android.net.Uri;
import android.webkit.MimeTypeMap;
import java.util.List;
import java.util.logging.Logger;
import org.qtproject.qt5.android.bindings.QtActivity;
import pub.devrel.easypermissions.EasyPermissions;

public class MyActivity extends QtActivity implements EasyPermissions.PermissionCallbacks
{
        private static final Logger logger = Logger.getLogger("org.scotthamilton.unoconvui");
        private static final int RC_PERM = 1;


        public void getIntents() {
                // Get intent, action and MIME type
                logger.severe("Getting Intents...");
                NativeFunctions.debugChangeErrorArea("Getting Intents...");
                Intent intent = getIntent();
                String action = intent.getAction();
                String type = intent.getType();

                if (Intent.ACTION_VIEW.equals(action) && type != null) {
                        logger.severe("Got View Intent");
                        NativeFunctions.debugChangeErrorArea("Got View Intent");
                        NativeFunctions.debugChangeErrorArea("Type is : "+type);
                        NativeFunctions.onIntentOpenDocument(intent.getData());
                } else if (Intent.ACTION_SEND.equals(action) && type != null) {
                        logger.severe("Got Send Intent");
                        NativeFunctions.debugChangeErrorArea("Got Send Intent");
                        NativeFunctions.debugChangeErrorArea("Type is : "+type);
                        Uri uri = (Uri) intent.getParcelableExtra(Intent.EXTRA_STREAM);
                        NativeFunctions.onIntentOpenDocument(uri);
                } else if (Intent.ACTION_SEND_MULTIPLE.equals(action) && type != null) {
                        logger.severe("Got Send Multiple Intent");
                        NativeFunctions.debugChangeErrorArea("Got Send Multiple Intent");
                        NativeFunctions.debugChangeErrorArea("Type is : "+type);
                        Uri uri = null;
                        try {
                                uri = (Uri) intent.getParcelableArrayListExtra(Intent.EXTRA_STREAM).get(0);
                        } catch (IndexOutOfBoundsException e) {
                                logger.severe("Can't extract Uris from Intent, EXTRA_STREAM is empty");
                                NativeFunctions.debugChangeErrorArea("Can't extract Uris from Intent, EXTRA_STREAM is empty");
                                NativeFunctions.conversionFailure("Given file is invalid");
                                return;
                        }
                        NativeFunctions.onIntentOpenDocument(uri);
                } else {
                        NativeFunctions.onNoStartupIntent();
                }
        }

        public void openPdfFile(String pdf_file) {
                runOnUiThread(new OpenPdfRunnable(this, pdf_file));
        }

        public void grantPermissions() {
                String[] perms = new String[] { Manifest.permission.WRITE_EXTERNAL_STORAGE, Manifest.permission.INTERNET};
                if (EasyPermissions.hasPermissions(this, perms)) {
                        logger.severe("Already have permissions");
                        NativeFunctions.debugChangeErrorArea("Already Have Permissions");
                } else {
                        logger.severe("Asking for Permissions");
                        NativeFunctions.debugChangeErrorArea("Asking For Permissions");
                        EasyPermissions.requestPermissions(this, "We need to access internet and your download folder",
                        RC_PERM, perms);
                }
        }

        @Override
        public void onRequestPermissionsResult(int requestCode, String[] permissions, int[] grantResults) {
                logger.severe("Got permission request result");
                NativeFunctions.debugChangeErrorArea("Got permission request result");
                EasyPermissions.onRequestPermissionsResult(requestCode, permissions, grantResults, this);
        }

        @Override
        public void onPermissionsGranted(int requestCode, List<String> list) {
                logger.severe("RC CODE : " + String.valueOf(requestCode) + " : granted " + list.toString());
                NativeFunctions.debugChangeErrorArea(("RC CODE : " + String.valueOf(requestCode) + " : granted " + list.toString()));
                NativeFunctions.onPermissionsGranted(list);
        }

        @Override
        public void onPermissionsDenied(int requestCode, List<String> list) {
                logger.severe("RC CODE : " + String.valueOf(requestCode) + " : denied " + list.toString());
                NativeFunctions.debugChangeErrorArea(("RC CODE : " + String.valueOf(requestCode) + " : denied " + list.toString()));
                NativeFunctions.onPermissionsDenied(list);
        }

        public void openFileDialog() {
                runOnUiThread(new OpenFileDialogRunnable(this));
        }

        public void convertFileWithLocalWebService(Uri input_file_uri) {
                NativeFunctions.debugChangeErrorArea("Start Web Service Runnable");
                runOnUiThread(new WebServiceFileConvertRunnable(this, input_file_uri));
                NativeFunctions.debugChangeErrorArea("Started Web Service Runnable");
        }

        @Override
        protected void onActivityResult(int requestCode, int resultCode, Intent data) {
                super.onActivityResult(requestCode, resultCode, data);
                if(requestCode == 123 && resultCode == RESULT_OK) {
                        Uri selectedFile = data.getData(); //The uri with the location of the file
                        NativeFunctions.onFileSelected(selectedFile);
                }
        }
}
