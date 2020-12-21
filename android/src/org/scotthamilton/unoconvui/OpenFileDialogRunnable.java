package org.scotthamilton.unoconvui;

import android.content.Intent;

public class OpenFileDialogRunnable implements Runnable
{
    private MyActivity m_activity;
    public OpenFileDialogRunnable(MyActivity activity) {
        m_activity = activity;
    }
    // this method is called on Android Ui Thread
    @Override
    public void run() {
        Intent intent = new Intent()
                .setType("*/*")
                .setAction(Intent.ACTION_GET_CONTENT);
        m_activity.startActivityForResult(Intent.createChooser(intent, "Select a file"), 123);
    }
}
