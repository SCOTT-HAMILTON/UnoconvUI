QT += quick widgets
unix:android: QT += androidextras

CONFIG += c++11

# You can make your code fail to compile if it uses deprecated APIs.
# In order to do so, uncomment the following line.
#DEFINES += QT_DISABLE_DEPRECATED_BEFORE=0x060000    # disables all the APIs deprecated before Qt 6.0.0

SOURCES += \
        androidbackend.cpp \
        main.cpp \
        nativefunctions.cpp

HEADERS += \
    androidbackend.h

RESOURCES += qml.qrc

# Additional import path used to resolve QML modules in Qt Creator's code model
QML_IMPORT_PATH =

# Additional import path used to resolve QML modules just for Qt Quick Designer
QML_DESIGNER_IMPORT_PATH =

# Default rules for deployment.
qnx: target.path = /tmp/$${TARGET}/bin
else: unix:!android: target.path = /opt/$${TARGET}/bin
!isEmpty(target.path): INSTALLS += target

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

ANDROID_PACKAGE_SOURCE_DIR = $$PWD/android
