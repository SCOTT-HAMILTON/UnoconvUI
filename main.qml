import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Controls.Material 2.12

import org.scotthamilton.unoconvui 1.0

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
        Text {
            id: errorLabel
            text: ""
            anchors.centerIn: errorBox
            font.pointSize: 12
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
        function onConversionFailure (error_message) {
            errorBox.visible = true
            errorBox.show_error(error_message)
        }
        Component.onCompleted: {
            Backend.conversionFailure.connect(onConversionFailure);
        }
    }

    SwipeView {
        id: view

        currentIndex: 0
        x: 0
        y: 0
        width: root.width
        height: root.height

        Item {
            id: firstPage

            Button {
                id: button
                highlighted: true
                x: root.width/2-width/2
                y: root.height*0.3-height/2
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

                function onIntentOpenDocument() {
                    root.got_startup_intent = true
                    button.state = "convert";
                }
                function onReadyForFileSelection() {
                    console.log("Received Ready for File Selection");
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

                onClicked: {
                    switch (state) {
                    case "select-file":
                        Backend.openFileDialog()
                        break
                    case "convert":
                        if (root.got_startup_intent) {
                            Backend.convertIntent()
                        } else {
                            Backend.convertSelectedFile()
                        }
                        button.state = "converting"
                        break
                    case "open":
                        Backend.openPdf(Backend.pdf_file)
                        break
                    case "grant-permissions":
                        Backend.grantPermissions()
                        break
                    }
                }
                Component.onCompleted: {
                    Backend.intentOpenDocument.connect(onIntentOpenDocument)
                    Backend.readyForFileSelection.connect(onReadyForFileSelection)
                    Backend.noStartupIntent.connect(onNoStartupIntent)
                    Backend.fileSelected.connect(onFileSelected)
                    Backend.fileConverted.connect(onFileConverted)
                    Backend.permissionsGranted.connect(onPermissionsGranted)
                    Backend.permissionsDenied.connect(onPermissionsDenied)
                    Backend.conversionFailure.connect(onConversionFailure)
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
                y: root.height*0.8-height
                focusPolicy: Qt.NoFocus
                TextArea {
                    id: debugErrorArea
                    readOnly: true
                    text: "Debug Area : \n"
                    Keys.onPressed: {
                        event.accepted = false;
                    }

                    function onDebugChangeErrorArea(text) {
                        debugErrorArea.text += "\n - "+text
                    }
                    Component.onCompleted: {
                        Backend.debugChangeErrorArea.connect(onDebugChangeErrorArea)
                    }
                }
            }
        }
        Item {
            id: secondPage
            property bool stacked: root.width/webServiceAddressInput.contentWidth<2.5
            Component.onCompleted: {
                console.log(root.width+", "+webServiceAddressInput.contentWidth+", "+root.width/webServiceAddressInput.contentWidth)
            }

            Text {
                id: settingsPageHeader
                x: root.width/2-width/2
                y: root.height*0.1
                color: "#FFFFFF"
                text: qsTr("Settings Page")
                font.pointSize: 20
                font.bold: true
                font.capitalization: Font.AllUppercase
            }
            Text {
                id: labelWebServiceAddressInput
                property var xNormal: root.width*0.1
                property var yNormal: root.height*0.3
                property var xStacked: root.width/2-width/2
                property var yStacked: root.height*0.3
                state: secondPage.stacked?"stacked":"normal"
                states: [
                    State {
                        name: "normal"
                        PropertyChanges {
                            target: labelWebServiceAddressInput
                            x: xNormal; y: yNormal
                        }
                    },
                    State {
                        name: "stacked"
                        PropertyChanges {
                            target: labelWebServiceAddressInput
                            x: xStacked; y: yStacked
                        }
                    }
                ]
                color: "#FFFFFF"
                text: qsTr("Web Service Address (with the schema) : ")
                font.bold: true
            }
            TextField {
                id: webServiceAddressInput
                width: (secondPage.stacked)?
                    (root.width*0.8):
                    (root.width*0.8-labelWebServiceAddressInput.width)
                property var xNormal: labelWebServiceAddressInput.x+labelWebServiceAddressInput.width+root.width*0.03
                property var yNormal: labelWebServiceAddressInput.y+labelWebServiceAddressInput.height/2-height/2
                property var xStacked: root.width/2-width/2
                property var yStacked: labelWebServiceAddressInput.yStacked+labelWebServiceAddressInput.height+root.height*0.03
                state: secondPage.stacked?"stacked":"normal"
                states: [
                    State {
                        name: "normal"
                        PropertyChanges {
                            target: webServiceAddressInput
                            x: xNormal; y: yNormal
                        }
                    },
                    State {
                        name: "stacked"
                        PropertyChanges {
                            target: webServiceAddressInput
                            x: xStacked; y: yStacked
                        }
                    }
                ]
                placeholderText: qsTr("exemple : http://192.168.1.23")
                horizontalAlignment: secondPage.stacked?Text.AlignHCenter:Text.AlignLeft
                Component.onCompleted: {
                    text = SettingsBackend.getWebServiceAddressSetting()
                }
            }
            Text {
                id: labelWebServicePortInput
                property var xNormal: labelWebServiceAddressInput.x+labelWebServiceAddressInput.width-width
                property var yNormal: labelWebServiceAddressInput.y+labelWebServiceAddressInput.height+root.height*0.07
                property var xStacked: root.width/2-width/2
                property var yStacked: webServiceAddressInput.yStacked+webServiceAddressInput.height+root.height*0.03
                state: secondPage.stacked?"stacked":"normal"
                states: [
                    State {
                        name: "normal"
                        PropertyChanges {
                            target: labelWebServicePortInput
                            x: xNormal; y: yNormal
                        }
                    },
                    State {
                        name: "stacked"
                        PropertyChanges {
                            target: labelWebServicePortInput
                            x: xStacked; y: yStacked
                        }
                    }
                ]
                color: "#FFFFFF"
                text: qsTr("Web Service Port : ")
                font.bold: true
            }
            SpinBox {
                id: webServicePortInput
                width: webServiceAddressInput.width
                property var xNormal: labelWebServicePortInput.x+labelWebServicePortInput.width+root.width*0.03
                property var yNormal: labelWebServicePortInput.y+labelWebServicePortInput.height/2-height/2
                property var xStacked: root.width/2-width/2
                property var yStacked: labelWebServicePortInput.yStacked+labelWebServicePortInput.height+root.height*0.03
                state: secondPage.stacked?"stacked":"normal"
                states: [
                    State {
                        name: "normal"
                        PropertyChanges {
                            target: webServicePortInput
                            x: xNormal; y: yNormal
                        }
                    },
                    State {
                        name: "stacked"
                        PropertyChanges {
                            target: webServicePortInput
                            x: xStacked; y: yStacked
                        }
                    }
                ]
                editable: true
                from: 0
                to: 1000000
                Component.onCompleted: {
                    value = SettingsBackend.getWebServicePortSetting()
                }
            }
            Button {
                id: validateSettingsButton
                x: root.width/2-width/2
                y: webServicePortInput.y+webServicePortInput.height+root.height*0.04
                text: qsTr("Validate Changes")
                highlighted: true
                enabled: false
                // Bad stuff to fix input initialisations
                property bool firstAddressChange: true
                property bool firstPortChange: true
                property var currentAddressSetting: ""
                property var currentPortSetting: 0
                Connections {
                    target: webServiceAddressInput
                    function onTextChanged() {
                        if (!validateSettingsButton.firstAddressChange) {
                            validateSettingsButton.enabled =
                                    webServiceAddressInput.text !== validateSettingsButton.currentAddressSetting ||
                                    webServicePortInput.value !== validateSettingsButton.currentPortSetting
                        } else {
                            validateSettingsButton.firstAddressChange = false
                        }
                    }
                }
                Connections {
                    target: webServicePortInput
                    function onValueChanged() {
                        if (!validateSettingsButton.firstPortChange) {
                            validateSettingsButton.enabled =
                                    webServiceAddressInput.text !== validateSettingsButton.currentAddressSetting ||
                                    webServicePortInput.value !== validateSettingsButton.currentPortSetting
                        } else {
                            validateSettingsButton.firstPortChange = false
                        }
                    }
                }
                Component.onCompleted: {
                    currentAddressSetting = SettingsBackend.getWebServiceAddressSetting()
                    currentPortSetting = SettingsBackend.getWebServicePortSetting()
                }
                onClicked: {
                    if (webServiceAddressInput.text !== currentAddressSetting) {
                        SettingsBackend.setWebServiceAddressSetting(webServiceAddressInput.text)
                        currentAddressSetting = webServiceAddressInput.text
                        validateSettingsButton.enabled = false
                    }
                    if (webServicePortInput.text !== currentPortSetting) {
                        SettingsBackend.setWebServicePortSetting(webServicePortInput.value)
                        currentPortSetting = webServicePortInput.value
                        validateSettingsButton.enabled = false
                    }
                }
            }
        }
    }
    ToolButton {
        id: goLeftButton
        visible: view.currentIndex > 0
        x: root.width*0.01
        y: root.height*0.01
        icon.source: "icons/left-arrow.svg"
        icon.width: root.width*0.07
        icon.height: root.width*0.07
        icon.color: Material.color(Material.accentColor)
        onClicked: {
            if (view.currentIndex-1 >= 0) {
                view.setCurrentIndex(view.currentIndex-1)
            }
        }
    }
    ToolButton {
        id: goRightButton
        visible: view.currentIndex < view.count-1
        x: root.width-root.width*0.01-width
        y: root.height*0.01
        icon.source: "icons/right-arrow.svg"
        icon.width: root.width*0.07
        icon.height: root.width*0.07
        icon.color: Material.color(Material.accentColor)
        onClicked: {
            if (view.currentIndex+1 < view.count) {
                view.setCurrentIndex(view.currentIndex+1)
            }
        }
    }
    PageIndicator {
        id: indicator

        count: view.count
        currentIndex: view.currentIndex

        anchors.bottom: view.bottom
        anchors.horizontalCenter: view.horizontalCenter
    }
    Shortcut {
        sequence: StandardKey.Forward
        onActivated: {
            if (view.currentIndex+1 < view.count) {
                view.setCurrentIndex(view.currentIndex+1)
            }
        }
    }
    Shortcut {
        sequence: StandardKey.Back
        onActivated: {
            if (view.currentIndex-1 >= 0) {
                view.setCurrentIndex(view.currentIndex-1)
            }
        }
    }
}
