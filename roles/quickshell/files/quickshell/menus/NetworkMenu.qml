import QtQuick
import QtQuick.Layouts
import QtQuick.Controls.Basic
import Quickshell.Networking
import ".."

ColumnLayout {
    id: root
    spacing: 12

    readonly property var wifi: Networking.devices.values.find(d => d.type === DeviceType.Wifi) ?? null
    readonly property bool enabled: Networking.wifiEnabled

    readonly property var networks: (wifi?.networks.values ?? [])
        .filter(n => n.name !== "")
        .sort((a, b) => (b.connected - a.connected) || (b.signalStrength - a.signalStrength))

    property string passwordFor: ""
    property string error: ""

    Component.onCompleted: if (wifi) wifi.scannerEnabled = true
    Component.onDestruction: if (wifi) wifi.scannerEnabled = false

    function connectTo(net) {
        error = "";
        if (net.known || net.security === WifiSecurityType.Open) {
            passwordFor = "";
            net.connect();
        } else {
            passwordFor = net.name;
        }
    }

    MenuHeader {
        icon: !root.enabled ? "wifi-off" : Theme.wifiIcon(1)
        title: "Wi-Fi"
        subtitle: !root.wifi ? "No wireless device"
            : !root.enabled ? "Off"
            : (root.networks.find(n => n.connected)?.name ?? "Not connected")

        Toggle {
            visible: Networking.wifiHardwareEnabled
            checked: root.enabled
            onToggled: Networking.wifiEnabled = !Networking.wifiEnabled
        }
    }

    Text {
        visible: root.error !== ""
        Layout.fillWidth: true
        wrapMode: Text.Wrap
        text: root.error
        color: Theme.bad
        font.family: Theme.font
        font.pixelSize: 12
    }

    Text {
        visible: root.enabled && root.networks.length === 0
        Layout.fillWidth: true
        horizontalAlignment: Text.AlignHCenter
        text: "Scanning…"
        color: Theme.muted
        font.family: Theme.font
        font.pixelSize: 12
    }

    ListView {
        visible: root.enabled
        Layout.fillWidth: true
        Layout.preferredHeight: Math.min(contentHeight, 380)
        clip: true
        spacing: 4
        model: root.networks
        boundsBehavior: Flickable.StopAtBounds

        delegate: Rectangle {
            id: row
            required property WifiNetwork modelData
            readonly property WifiNetwork net: modelData
            readonly property bool secured: net.security !== WifiSecurityType.Open
            readonly property bool askingPassword: root.passwordFor === net.name

            width: ListView.view.width
            implicitHeight: content.implicitHeight + 16
            radius: Theme.radius
            color: net.connected || askingPassword ? Theme.surface : "transparent"

            Connections {
                target: row.net
                function onConnectionFailed(reason) {
                    if (reason === ConnectionFailReason.NoSecrets) {
                        root.error = row.net.known ? "Wrong password, try again." : "";
                        root.passwordFor = row.net.name;
                    } else {
                        root.error = `Could not connect to ${row.net.name}: ${ConnectionFailReason.toString(reason)}`;
                    }
                }
                function onConnectedChanged() {
                    if (row.net.connected && root.passwordFor === row.net.name) {
                        root.passwordFor = "";
                        root.error = "";
                    }
                }
            }

            ColumnLayout {
                id: content
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                anchors.leftMargin: 10
                anchors.rightMargin: 8
                spacing: 8

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 10

                    LucideIcon {
                        name: Theme.wifiIcon(row.net.signalStrength)
                        color: row.net.connected ? Theme.accent : Theme.muted
                        size: 18
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 0
                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 6
                            Text {
                                Layout.fillWidth: true
                                Layout.maximumWidth: implicitWidth
                                text: row.net.name
                                color: Theme.fg
                                elide: Text.ElideRight
                                font.family: Theme.font
                                font.pixelSize: 13
                            }
                            LucideIcon {
                                visible: row.secured
                                name: "lock"
                                color: Theme.muted
                                size: 12
                            }
                            Item { Layout.fillWidth: true }
                        }
                        Text {
                            Layout.fillWidth: true
                            color: Theme.muted
                            font.family: Theme.font
                            font.pixelSize: 11
                            text: {
                                switch (row.net.state) {
                                case ConnectionState.Connecting: return "Connecting…";
                                case ConnectionState.Disconnecting: return "Disconnecting…";
                                }
                                if (row.net.connected) return "Connected";
                                return `${row.net.known ? "Saved · " : ""}${Math.round(row.net.signalStrength * 100)}%`;
                            }
                        }
                    }

                    TextButton {
                        enabled: !row.net.stateChanging
                        text: row.net.connected ? "Disconnect" : "Connect"
                        accent: row.net.connected ? Theme.bad : Theme.accent
                        onClicked: row.net.connected ? row.net.disconnect() : root.connectTo(row.net)
                    }

                    IconButton {
                        visible: row.net.known && !row.net.connected
                        size: 26
                        iconSize: 14
                        icon: "trash-2"
                        iconColor: Theme.muted
                        onClicked: row.net.forget()
                    }
                }

                RowLayout {
                    visible: row.askingPassword
                    Layout.fillWidth: true
                    spacing: 6

                    TextField {
                        id: password
                        Layout.fillWidth: true
                        placeholderText: "Password"
                        placeholderTextColor: Theme.muted
                        echoMode: showPw.active ? TextInput.Normal : TextInput.Password
                        color: Theme.fg
                        font.family: Theme.font
                        font.pixelSize: 13
                        background: Rectangle {
                            radius: 8
                            color: Theme.bg
                            border.width: 1
                            border.color: password.activeFocus ? Theme.accent : Theme.surfaceHi
                        }
                        onAccepted: submit.clicked()
                        Keys.onEscapePressed: root.passwordFor = ""

                        Connections {
                            target: row
                            function onAskingPasswordChanged() {
                                password.text = "";
                                if (row.askingPassword) password.forceActiveFocus();
                            }
                        }
                    }

                    IconButton {
                        id: showPw
                        size: 28
                        iconSize: 14
                        icon: active ? "eye-off" : "eye"
                        active: false
                        onClicked: active = !active
                    }

                    TextButton {
                        id: submit
                        text: "Join"
                        enabled: password.text.length >= 8
                        onClicked: {
                            root.error = "";
                            row.net.connectWithPsk(password.text);
                        }
                    }
                }
            }
        }
    }
}
