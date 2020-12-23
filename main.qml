import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.0

ApplicationWindow {
    id: root
    width: 640
    height: 480
    visible: true
    title: qsTr("Unoconv")

    property bool got_startup_intent: false

    Button {
        id: button
        highlighted: true
        x: root.width/2-width/2
        y: root.height/2-height/2
        state: ""
        width: root.width*0.5
        height: width*0.3

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
        }

        onClicked: {
            switch (state) {
            case "select-file":
                backend.openFileDialog()
                break
            case "convert":
                backend.convertIntent()
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
        anchors.top: convertingIndicator.bottom
        anchors.topMargin: root.height*0.01
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
