import QtQuick
import QtQuick.Layouts
import Quickshell.Bluetooth
import ".."

ColumnLayout {
    id: root
    spacing: 12

    readonly property BluetoothAdapter adapter: Bluetooth.defaultAdapter
    readonly property bool powered: adapter?.enabled ?? false

    readonly property var devices: (adapter?.devices.values ?? [])
        .filter(d => d.paired || d.deviceName !== "")
        .sort((a, b) => (b.connected - a.connected) || (b.paired - a.paired) || a.name.localeCompare(b.name))

    function setScanning(on) {
        if (!adapter || !adapter.enabled) return;
        adapter.pairable = on;
        adapter.discovering = on;
    }
    Component.onCompleted: setScanning(true)
    Component.onDestruction: setScanning(false)
    onPoweredChanged: setScanning(powered)

    MenuHeader {
        icon: root.powered ? "bluetooth" : "bluetooth-off"
        title: "Bluetooth"
        subtitle: !root.adapter ? "No adapter found"
            : !root.powered ? "Off"
            : root.adapter.discovering ? "Scanning for devices…" : root.adapter.name

        IconButton {
            visible: root.powered
            size: 28
            iconSize: 16
            icon: "refresh-cw"
            active: root.adapter?.discovering ?? false
            onClicked: root.adapter.discovering = !root.adapter.discovering
        }
        Toggle {
            visible: root.adapter !== null
            checked: root.powered
            onToggled: root.adapter.enabled = !root.adapter.enabled
        }
    }

    Text {
        visible: root.powered && root.devices.length === 0
        Layout.fillWidth: true
        horizontalAlignment: Text.AlignHCenter
        text: "No devices found"
        color: Theme.muted
        font.family: Theme.font
        font.pixelSize: 12
    }

    ListView {
        visible: root.powered
        Layout.fillWidth: true
        Layout.preferredHeight: Math.min(contentHeight, 340)
        clip: true
        spacing: 4
        model: root.devices
        boundsBehavior: Flickable.StopAtBounds

        delegate: Rectangle {
            id: row
            required property BluetoothDevice modelData
            readonly property BluetoothDevice device: modelData
            readonly property bool busy: device.pairing
                || device.state === BluetoothDeviceState.Connecting
                || device.state === BluetoothDeviceState.Disconnecting

            width: ListView.view.width
            implicitHeight: 48
            radius: Theme.radius
            color: device.connected ? Theme.surface : "transparent"

            Connections {
                target: row.device
                function onPairedChanged() {
                    if (row.device.paired) row.device.trusted = true;
                }
            }

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 10
                anchors.rightMargin: 8
                spacing: 10

                LucideIcon {
                    name: row.device.connected ? "bluetooth-connected" : "bluetooth"
                    color: row.device.connected ? Theme.accent : Theme.muted
                    size: 18
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 0
                    Text {
                        Layout.fillWidth: true
                        text: row.device.name
                        color: Theme.fg
                        elide: Text.ElideRight
                        font.family: Theme.font
                        font.pixelSize: 13
                    }
                    Text {
                        Layout.fillWidth: true
                        color: Theme.muted
                        font.family: Theme.font
                        font.pixelSize: 11
                        text: {
                            const d = row.device;
                            if (d.pairing) return "Pairing…";
                            if (d.state === BluetoothDeviceState.Connecting) return "Connecting…";
                            if (d.state === BluetoothDeviceState.Disconnecting) return "Disconnecting…";
                            if (d.connected)
                                return d.batteryAvailable ? `Connected · ${Math.round(d.battery * 100)}%` : "Connected";
                            return d.paired ? "Paired" : "Not paired";
                        }
                    }
                }

                TextButton {
                    enabled: !row.busy || row.device.pairing
                    text: row.device.pairing ? "Cancel"
                        : !row.device.paired ? "Pair"
                        : row.device.connected ? "Disconnect" : "Connect"
                    accent: row.device.connected || row.device.pairing ? Theme.bad : Theme.accent
                    onClicked: {
                        const d = row.device;
                        if (d.pairing) d.cancelPair();
                        else if (!d.paired) d.pair();
                        else if (d.connected) d.disconnect();
                        else d.connect();
                    }
                }

                IconButton {
                    visible: row.device.paired && !row.device.connected
                    size: 26
                    iconSize: 14
                    icon: "trash-2"
                    iconColor: Theme.muted
                    onClicked: row.device.forget()
                }
            }
        }
    }
}
