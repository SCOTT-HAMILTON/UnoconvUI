package org.scotthamilton.unoconvui;

import android.net.Uri;

public class NativeFunctions {
	// define the native function
	// these functions are called by the BroadcastReceiver object
	// when it receives a new notification
        public static native void onIntentOpenDocument(Uri file_to_convert);
        public static native void onNoStartupIntent();
        public static native void onFileSelected(Uri selected_file);
        public static native void onFileConverted(String pdf_file);

        public static native void debugChangeErrorArea(String pdf_file);
}
