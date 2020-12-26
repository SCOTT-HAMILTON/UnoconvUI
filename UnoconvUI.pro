QT += quick widgets
unix:android: QT += androidextras
else: QT += network gui

CONFIG += c++11 lrelease embed_translations

# You can make your code fail to compile if it uses deprecated APIs.
# In order to do so, uncomment the following line.
#DEFINES += QT_DISABLE_DEPRECATED_BEFORE=0x060000    # disables all the APIs deprecated before Qt 6.0.0

SOURCES += \
        main.cpp
unix:android: SOURCES += nativefunctions.cpp \
                         androidbackend.cpp
else: SOURCES += desktopbackend.cpp


unix:android: HEADERS += androidbackend.h
else: HEADERS += desktopbackend.h

RESOURCES += qml.qrc

RC_ICONS = icon.ico

TRANSLATIONS += \
        translations/UnoconvUI_fr_FR.ts
QM_FILES_RESOURCE_PREFIX = :/translations

# Additional import path used to resolve QML modules in Qt Creator's code model
QML_IMPORT_PATH =

# Additional import path used to resolve QML modules just for Qt Quick Designer
QML_DESIGNER_IMPORT_PATH =

# Default rules for deployment.
target = UnoconvUI
qnx: target.path = /tmp/$${TARGET}/bin
else: unix:!android: {
	target.path = $${QT_INSTALL_PREFIX}/bin

	icon16.path = $${QT_INSTALL_PREFIX}/share/icons/hicolor/16x16/apps
	icon16.files = icons/16/UnoconvUI.png
	icon16.extra = rsvg-convert -w 16 -h 16 -f png icon.svg > icons/16/UnoconvUI.png
	icon32.path = $${QT_INSTALL_PREFIX}/share/icons/hicolor/32x32/apps
	icon32.files = icons/32/UnoconvUI.png
	icon32.extra = rsvg-convert -w 32 -h 32 -f png icon.svg > icons/32/UnoconvUI.png
	icon48.path = $${QT_INSTALL_PREFIX}/share/icons/hicolor/48x48/apps
	icon48.files = icons/48/UnoconvUI.png
	icon48.extra = rsvg-convert -w 48 -h 48 -f png icon.svg > icons/48/UnoconvUI.png
	icon64.path = $${QT_INSTALL_PREFIX}/share/icons/hicolor/64x64/apps
	icon64.files = icons/64/UnoconvUI.png
	icon64.extra = rsvg-convert -w 64 -h 64 -f png icon.svg > icons/64/UnoconvUI.png
	icon128.path = $${QT_INSTALL_PREFIX}/share/icons/hicolor/128x128/apps
	icon128.files = icons/128/UnoconvUI.png
	icon128.extra = rsvg-convert -w 128 -h 128 -f png icon.svg > icons/128/UnoconvUI.png
	icon256.path = $${QT_INSTALL_PREFIX}/share/icons/hicolor/256x256/apps
	icon256.files = icons/256/UnoconvUI.png
	icon256.extra = rsvg-convert -w 256 -h 256 -f png icon.svg > icons/256/UnoconvUI.png
	iconscalable.path = $${QT_INSTALL_PREFIX}/share/icons/hicolor/256x256/apps
	iconscalable.files = icons/scalable/UnoconvUI.svg
	iconscalable.extra = cp icon.svg icons/scalable/UnoconvUI.svg

	desktop.path = $${QT_INSTALL_PREFIX}/share/applications
	desktop.files = desktop/unoconvui.desktop

	INSTALLS += icon16 icon32 icon48 icon64 icon128 icon256 iconscalable desktop
}
!isEmpty(target.path): INSTALLS += target

unix:android: \
DISTFILES += \
    android/AndroidManifest.xml \
    android/build.gradle \
    android/gradle.properties \
    android/gradle/wrapper/gradle-wrapper.jar \
    android/gradle/wrapper/gradle-wrapper.properties \
    android/gradlew \
    android/gradlew.bat \
    android/res/values/libs.xml \
    android/src/org/scotthamilton/unoconvui/MyActivity.java \
    android/src/org/scotthamilton/unoconvui/NativeFunctions.java \
    android/src/org/scotthamilton/unoconvui/OpenFileDialogRunnable.java \
    android/src/org/scotthamilton/unoconvui/OpenPdfRunnable.java \
    android/src/org/scotthamilton/unoconvui/Test.java \
    android/src/org/scotthamilton/unoconvui/UriUtils.java \
    android/src/org/scotthamilton/unoconvui/WebServiceFileConvertRunnable.java

unix:android: \
ANDROID_PACKAGE_SOURCE_DIR = $$PWD/android

