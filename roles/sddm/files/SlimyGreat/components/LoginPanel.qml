import QtQuick

Rectangle {
    id: panel

    property real s: 1
    property int sessionIndex: 0
    property alias username: userField.text

    readonly property real pad: Math.round(24 * s)

    width: pad * 2 + userField.width + Math.round(16 * s) + passwordField.width
    height: Math.round(80 * s)
    color: Theme.base
    topLeftRadius: 16 * s
    topRightRadius: 16 * s

    function focusInput() {
        if (userField.text.length === 0)
            userField.input.forceActiveFocus()
        else
            passwordField.input.forceActiveFocus()
    }

    function login() {
        if (userField.text.length === 0) {
            userField.input.forceActiveFocus()
            return
        }
        sddm.login(userField.text, passwordField.text, panel.sessionIndex)
    }

    function showError() {
        passwordField.text = ""
        passwordField.error = true
        passwordField.input.forceActiveFocus()
    }

    Corner {
        s: panel.s
        anchors.right: parent.left
        anchors.bottom: parent.bottom
        rotation: 90
    }

    Corner {
        s: panel.s
        anchors.left: parent.right
        anchors.bottom: parent.bottom
        rotation: 180
    }

    Field {
        id: userField
        s: panel.s
        anchors.left: parent.left
        anchors.leftMargin: panel.pad
        anchors.verticalCenter: parent.verticalCenter
        icon: Qt.resolvedUrl("../assets/circle-user-round.svg")
        placeholder: "username"
        text: userModel.lastUser
        onAccepted: passwordField.input.forceActiveFocus()
    }

    Field {
        id: passwordField
        s: panel.s
        anchors.right: parent.right
        anchors.rightMargin: panel.pad
        anchors.verticalCenter: parent.verticalCenter
        icon: Qt.resolvedUrl("../assets/key-square.svg")
        placeholder: error ? "wrong password" : "password"
        password: true
        onAccepted: panel.login()
        onTextChanged: if (text.length > 0) error = false

        Image {
            visible: keyboard.capsLock
            width: Math.round(16 * panel.s)
            height: width
            source: Qt.resolvedUrl("../assets/arrow-big-up-dash.svg")
            sourceSize: Qt.size(width, height)
        }
    }

    Connections {
        target: sddm
        function onLoginFailed() { panel.showError() }
    }
}
