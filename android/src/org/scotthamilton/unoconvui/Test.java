package org.scotthamilton.unoconvui;

import android.webkit.MimeTypeMap;
import java.util.logging.Logger;

public class Test {
        private static final Logger logger = Logger.getLogger("org.scotthamilton.unoconvui");

        public static void test(){
                String[] list = {
                    "bib",
                    "doc",
                    "doc6",
                    "doc95",
                    "docbook",
                    "docx",
                    "docx7",
                    "fodt",
                    "html",
                    "latex",
                    "mediawiki",
                    "odt",
                    "ooxml",
                    "ott",
                    "pdb",
                    "pdf",
                    "psw",
                    "rtf",
                    "sdw",
                    "sdw4",
                    "sdw3",
                    "stw",
                    "sxw",
                    "text",
                    "txt",
                    "uot",
                    "vor",
                    "vor4",
                    "vor3",
                    "wps",
                    "xhtml",
                    "epub",
                    "bmp",
                    "emf",
                    "eps",
                    "fodg",
                    "gif",
                    "html",
                    "jpg",
                    "met",
                    "odd",
                    "otg",
                    "pbm",
                    "pct",
                    "pdf",
                    "pgm",
                    "png",
                    "ppm",
                    "ras",
                    "std",
                    "svg",
                    "svm",
                    "swf",
                    "sxd",
                    "sxd3",
                    "sxd5",
                    "sxw",
                    "tiff",
                    "vor",
                    "vor3",
                    "wmf",
                    "xhtml",
                    "xpm",
                    "bmp",
                    "emf",
                    "eps",
                    "fodp",
                    "gif",
                    "html",
                    "jpg",
                    "met",
                    "odg",
                    "odp",
                    "otp",
                    "pbm",
                    "pct",
                    "pdf",
                    "pgm",
                    "png",
                    "potm",
                    "pot",
                    "ppm",
                    "pptx",
                    "pps",
                    "ppt",
                    "pwp",
                    "ras",
                    "sda",
                    "sdd",
                    "sdd3",
                    "sdd4",
                    "sxd",
                    "sti",
                    "svg",
                    "svm",
                    "swf",
                    "sxi",
                    "tiff",
                    "uop",
                    "vor",
                    "vor3",
                    "vor4",
                    "vor5",
                    "wmf",
                    "xhtml",
                    "xpm",
                    "csv",
                    "dbf",
                    "dif",
                    "fods",
                    "html",
                    "ods",
                    "ooxml",
                    "ots",
                    "pdf",
                    "pxl",
                    "sdc",
                    "sdc4",
                    "sdc3",
                    "slk",
                    "stc",
                    "sxc",
                    "uos",
                    "vor3",
                    "vor4",
                    "vor",
                    "xhtml",
                    "xls",
                    "xls5",
                    "xls95",
                    "xlt",
                    "xlt5",
                    "xlt95",
                    "xlsx"
                };
                for (String type : list) {
                        String str = MimeTypeMap.getSingleton().getMimeTypeFromExtension(type);
                        if (str != null)
                                logger.severe(str);
                }
        }
}
