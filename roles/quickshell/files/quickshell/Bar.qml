import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Services.Pipewire
import Quickshell.Bluetooth
import Quickshell.Networking
import Quickshell.Services.UPower

Scope {
    id: root
    required property ShellScreen modelData

    property string openMenu: ""
    property real menuAnchorY: 0

    function toggleMenu(name, item) {
        if (openMenu === name) {
            openMenu = "";
            return;
        }
        menuAnchorY = item.mapToItem(null, 0, item.height / 2).y;
        openMenu = name;
    }

    readonly property PwNode sink: Pipewire.defaultAudioSink
    PwObjectTracker { objects: [root.sink] }

    readonly property var wifiDevice: Networking.devices.values.find(d => d.type === DeviceType.Wifi) ?? null
    readonly property var wiredDevice: Networking.devices.values.find(d => d.type === DeviceType.Wired && d.connected) ?? null
    readonly property var activeWifi: wifiDevice?.networks.values.find(n => n.connected) ?? null
    readonly property var btAdapter: Bluetooth.defaultAdapter

    readonly property UPowerDevice battery: UPower.displayDevice
    readonly property bool hasBattery: battery.ready && battery.isLaptopBattery && battery.isPresent
    readonly property bool charging: battery.state === UPowerDeviceState.Charging
        || battery.state === UPowerDeviceState.PendingCharge

    SystemClock {
        id: clock
        precision: SystemClock.Minutes
    }

    readonly property string wifiIcon: {
        if (wiredDevice) return "ethernet";
        if (!Networking.wifiEnabled || !wifiDevice) return "wifi-off";
        if (wifiDevice.networks.values.some(n => n.stateChanging)) return "wifi-sync";
        if (!activeWifi) return "wifi-off";
        return Theme.wifiIcon(activeWifi.signalStrength);
    }

    PanelWindow {
        id: bar
        screen: root.modelData
        anchors { top: true; bottom: true; right: true }
        implicitWidth: Theme.barWidth
        color: Theme.bg

        Workspaces {
            anchors.top: parent.top
            anchors.topMargin: 16
            anchors.horizontalCenter: parent.horizontalCenter
        }

        Column {
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 16
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 16

            Column {
                spacing: 8

                QuickButton {
                    id: netButton
                    icon: root.wifiIcon
                    active: root.openMenu === "network"
                    onClicked: root.toggleMenu("network", netButton)
                }

                QuickButton {
                    id: btButton
                    icon: root.btAdapter?.enabled ? "bluetooth" : "bluetooth-off"
                    active: root.openMenu === "bluetooth"
                    onClicked: root.toggleMenu("bluetooth", btButton)
                }

                QuickButton {
                    id: audioButton
                    icon: Theme.volumeIcon(root.sink?.audio?.volume ?? 0, root.sink?.audio?.muted ?? false)
                    active: root.openMenu === "audio"
                    onClicked: mouse => {
                        if (mouse.button === Qt.MiddleButton && root.sink?.audio)
                            root.sink.audio.muted = !root.sink.audio.muted;
                        else
                            root.toggleMenu("audio", audioButton);
                    }
                    onWheel: event => {
                        if (!root.sink?.audio) return;
                        const step = event.angleDelta.y > 0 ? 0.05 : -0.05;
                        root.sink.audio.volume = Math.max(0, Math.min(1, root.sink.audio.volume + step));
                    }
                }

                QuickButton {
                    id: batteryButton
                    visible: root.hasBattery
                    icon: Theme.batteryIcon(root.battery.percentage * 100, root.charging)
                    active: root.openMenu === "battery"
                    onClicked: root.toggleMenu("battery", batteryButton)
                }
            }

            Column {
                spacing: 8

                CalendarButton {
                    id: calendarButton
                    implicitHeight: 48
                    date: clock.date
                    active: root.openMenu === "calendar"
                    onClicked: root.toggleMenu("calendar", calendarButton)
                }

                ClockButton {}
            }
        }
    }

    NotificationPanel {
        screen: root.modelData
    }

    ScreenFrame {
        screen: root.modelData
    }

    MenuWindow {
        screen: root.modelData
        barWindow: bar
        current: root.openMenu
        anchorY: root.menuAnchorY
        today: clock.date
        onCloseRequested: root.openMenu = ""
    }
}
