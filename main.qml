import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.0
import QtGraphicalEffects 1.0

ApplicationWindow {
    id: root
    width: 640
    height: 480
    visible: true
    title: qsTr("Unoconv")

    property bool got_startup_intent: false

    Rectangle {
        id: errorBox
        width: errorLabel.width*1.07
        height: errorLabel.height*2
        x: -2*width
        y: root.height*0.1
        color: "#FF0000"
        property var clean_anim: function() {
                errorBox.visible = false
                errorBox.x = -2*errorBox.width
                errorBox.opacity = 1.0
        }

        property var show_error: function (error_message) {
            if (errorBoxLifecycleAnimation.running) {
                errorBoxLifecycleAnimation.stop()
                clean_anim()
            }
            errorLabel.text = error_message
            errorBox.visible = true
            errorBoxLifecycleAnimation.start()
        }
        ScrollView {
            width: errorLabel.width>=root.width*0.7?root.width*0.7:errorLabel.width
            anchors.centerIn: parent
            Text {
                id: errorLabel
                anchors.fill: parent
                text: ""
                font.pointSize: 12
            }
        }
        SequentialAnimation {
            id: errorBoxLifecycleAnimation
            PropertyAnimation {
                target: errorBox
                property: "x"
                from: errorBox.x
                to: 0
                duration: 1000
                easing.type: Easing.OutQuint
            }
            PauseAnimation {
                duration: 3000
            }
            PropertyAnimation {
                target: errorBox
                property: "opacity"
                from: 1.0
                to: 0
                duration: 1000
            }
            onFinished: {
                errorBox.clean_anim()
            }
        }
        Connections {
            target: backend
            function onConversionFailure (error_message) {
                errorBox.visible = true
                errorBox.show_error(error_message)
            }
        }
    }

    Button {
        id: button
        highlighted: true
        x: root.width/2-width/2
        y: root.height*0.4-height/2
        state: ""
        width: root.width*0.5
        padding: root.width*0.04
        states: [
            State {
                name: "select-file"
                PropertyChanges { target: button; text: qsTr("Select a file"); enabled: true }
            },
            State {
                name: "converting"
                PropertyChanges { target: button; text: qsTr("Converting..."); enabled: false }
            },
            State {
                name: "convert"
                PropertyChanges { target: button; text: qsTr("Convert"); enabled: true }
            },
            State {
                name: "open"
                PropertyChanges { target: button; text: qsTr("Open"); enabled: true }
            },
            State {
                name: "grant-permissions"
                PropertyChanges { target: button; text: qsTr("Grant Permissions"); enabled: true }
            }
        ]

        Connections {
            target: backend

            function onIntentOpenDocument() {
                root.got_startup_intent = true
                button.state = "convert";
            }
            function onReadyForFileSelection() {
                root.got_startup_intent = false
                button.state = "select-file";
            }
            function onNoStartupIntent() {
                root.got_startup_intent = false
                button.state = "select-file";
            }
            function onFileSelected() {
                button.state = "converting";
            }
            function onFileConverted(pdf_file) {
                button.state = "open";
            }
            function onPermissionsGranted() {
                if (root.got_startup_intent) {
                    button.state = "convert";
                } else {
                    button.state = "select-file";
                }
            }
            function onPermissionsDenied() {
                button.state = "grant-permissions";
            }
            function onConversionFailure(error_message) {
                button.state = "convert";
            }
        }

        onClicked: {
            switch (state) {
            case "select-file":
                backend.openFileDialog()
                break
            case "convert":
                if (root.got_startup_intent) {
                    backend.convertIntent()
                } else {
                    backend.convertSelectedFile()
                }
                button.state = "converting"
                break
            case "open":
                backend.openPdf(backend.pdf_file)
                break
            case "grant-permissions":
                backend.grantPermissions()
                break
            }
        }
    }

    BusyIndicator {
        id: convertingIndicator
        running: button.state === "converting"
        anchors.horizontalCenter: button.horizontalCenter
        anchors.top: button.bottom
        anchors.topMargin: root.height*0.01

    }

    ScrollView {
        width: root.width*0.8
        height: root.height*0.3
        anchors.horizontalCenter: button.horizontalCenter
        y: root.height*0.99-height
        TextArea {
            id: debugErrorArea
            readOnly: true
            text: "Debug Area : \n"
            Connections {
                target: backend
                function onDebugChangeErrorArea(text) {
                    debugErrorArea.text += "\n - "+text
                }
            }
        }
    }
}
