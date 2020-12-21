import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.0

ApplicationWindow {
    id: root
    width: 640
    height: 480
    visible: true
    title: qsTr("Unoconv")

    Button {
        id: button
        highlighted: true
        x: root.width/2-width/2
        y: root.height/2-height/2
        state: ""

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
            }
        ]

        Connections {
            target: androidBackend

            function onIntentOpenDocument() {
                button.state = "convert";
            }
            function onNoStartupIntent() {
                button.state = "select-file";
            }
            function onFileSelected() {
                button.state = "converting";
            }
            function onFileConverted(pdf_file) {
                button.state = "open";
            }

        }

        onClicked: {
            switch (state) {
            case "select-file":
                androidBackend.openFileDialog()
                break
            case "convert":
                androidBackend.convertIntent()
                button.state = "converting"
                break
            case "open":
                androidBackend.openPdf(androidBackend.pdf_file)
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
                target: androidBackend
                function onDebugChangeErrorArea(text) {
                    debugErrorArea.text += "\n - "+text
                }
            }
        }
    }
}
