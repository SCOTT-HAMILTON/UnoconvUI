/**
 * References:
 * - https://www.programcreek.com/java-api-examples/?code=MLNO/airgram/airgram-master/TMessagesProj/src/main/java/ir/hamzad/telegram/MediaController.java
 * - https://stackoverflow.com/questions/5568874/how-to-extract-the-file-name-from-uri-returned-from-intent-action-get-content
 *
 * @author Manish@bit.ly/2HjxA0C
 * Created on: 03-07-2020
 */

package org.scotthamilton.unoconvui;

import android.content.Context;
import android.content.ContentResolver;
import android.net.Uri;
import android.database.Cursor;
import android.provider.MediaStore;
import android.provider.OpenableColumns;

public final class UriUtils {


    public static final int CONTENT_SIZE_INVALID = -1;

    /**
     * @param context context
     * @param contentUri content Uri, i.e, of the scheme <code>content://</code>
     * @return The Display name and size for content. In case of non-determination, display name
     * would be null and content size would be {@link #CONTENT_SIZE_INVALID}
     */
    public static String getUriRealBasename(Context context, Uri contentUri){
        final String scheme = contentUri.getScheme();
        if(scheme == null) {
                throw new RuntimeException("Only scheme content:// is accepted");
        }
        if (scheme.equals(ContentResolver.SCHEME_FILE)){
            return contentUri.getLastPathSegment();
        }
        if (!scheme.equals(ContentResolver.SCHEME_CONTENT)){
                throw new RuntimeException("Only scheme content:// is accepted");
        }

        String displayName = null;

        String[] projection = new String[]{MediaStore.Images.Media.DATA, OpenableColumns.DISPLAY_NAME, OpenableColumns.SIZE};
        Cursor cursor = context.getContentResolver().query(contentUri, projection, null, null, null);
        try {
            if (cursor != null && cursor.moveToFirst()) {

                // Try extracting content size

                int sizeIndex = cursor.getColumnIndex(OpenableColumns.SIZE);
                if (sizeIndex != -1) {
                }

                // Try extracting display name
                String name = null;

                // Strategy: The column name is NOT guaranteed to be indexed by DISPLAY_NAME
                // so, we try two methods
                int nameIndex = cursor.getColumnIndex(OpenableColumns.DISPLAY_NAME);
                if (nameIndex != -1) {
                    name = cursor.getString(nameIndex);
                }

                if (nameIndex == -1 || name == null) {
                    nameIndex = cursor.getColumnIndex(MediaStore.Images.Media.DATA);
                    if (nameIndex != -1) {
                        name = cursor.getString(nameIndex);
                    }
                }
                displayName = name;
            }
        }
        finally {
            if(cursor != null){
                cursor.close();
            }
        }

        // We tried querying the ContentResolver...didn't work out
        // Try extracting the last path segment
        if(displayName == null){
           displayName = contentUri.getLastPathSegment();
        }

        return displayName;
    }
}
