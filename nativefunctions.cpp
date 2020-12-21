#ifndef NATIVEFUNCTIONS_HPP
#define NATIVEFUNCTIONS_HPP

#include <jni.h>

#include <QMetaObject>
#include <QDebug>

#include <QAndroidJniObject>
#include <array>

#include "androidbackend.h"

static void onIntentOpenDocument(JNIEnv * env, jobject, jobject uri) {
    QAndroidJniObject object(uri);
    if (AndroidBackend::instance() == nullptr) {
        qDebug() << "Instance Is nullptr";
    }
    else {
        AndroidBackend::instance()->gotOpenDocumentIntent(object);
    }
}
static void onNoStartupIntent(JNIEnv * env, jobject) {
    if (AndroidBackend::instance() == nullptr) {
        qDebug() << "Instance Is nullptr";
    }
    else {
        AndroidBackend::instance()->gotNoStartupIntent();
    }
}
static void onFileSelected(JNIEnv * env, jobject, jobject uri) {
    QAndroidJniObject object(uri);
    if (AndroidBackend::instance() == nullptr) {
        qDebug() << "Instance Is nullptr";
    }
    else {
        AndroidBackend::instance()->gotFileSelected(object);
    }
}
static void onFileConverted(JNIEnv * env, jobject, jstring file) {
    QString str = QString::fromUtf8(env->GetStringUTFChars(file, nullptr));
    if (AndroidBackend::instance() == nullptr) {
        qDebug() << "Instance Is nullptr";
    }
    else {
        qDebug() << "Converted file : " << str;
        AndroidBackend::instance()->gotFileConverted(str);
    }
}
static void debugChangeErrorArea(JNIEnv * env, jobject, jstring debug_message) {
    QString str = QString::fromUtf8(env->GetStringUTFChars(debug_message, nullptr));
    if (AndroidBackend::instance() == nullptr) {
        qDebug() << "Instance Is nullptr";
    }
    else {
        AndroidBackend::instance()->gotDebugChangeErrorArea(str);
    }
}


static JNINativeMethod methods[] = {
    {"onIntentOpenDocument", "(Landroid/net/Uri;)V", (void*)onIntentOpenDocument},
    {"onNoStartupIntent", "()V", (void*)onNoStartupIntent},
    {"onFileSelected", "(Landroid/net/Uri;)V", (void*)onFileSelected},
    {"onFileConverted", "(Ljava/lang/String;)V", (void*)onFileConverted},
    {"debugChangeErrorArea", "(Ljava/lang/String;)V", (void*)debugChangeErrorArea}
};
// define our native static functions
// these are the functions that Java part will call directly from Android UI thread

//create a vector with all our JNINativeMethod(s)

// this method is called automatically by Java after the .so file is loaded
JNIEXPORT jint JNI_OnLoad(JavaVM *vm, void *)
{
    JNIEnv* env;
    // get the JNIEnv pointer.
    if (vm->GetEnv(reinterpret_cast<void**>(&env), JNI_VERSION_1_6) != JNI_OK)
      return JNI_ERR;

    // search for Java class which declares the native methods
    jclass javaClass = env->FindClass("org/scotthamilton/unoconvui/NativeFunctions");
    if (!javaClass)
      return JNI_ERR;

    // register our native methods
    if (env->RegisterNatives(javaClass, methods,
                          sizeof(methods) / sizeof(methods[0])) < 0) {
      return JNI_ERR;
    }

    return JNI_VERSION_1_6;
}


#endif // NATIVEFUNCTIONS_HPP
