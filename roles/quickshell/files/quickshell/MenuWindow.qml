import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import "menus"

PanelWindow {
    id: root
    required property var barWindow
    property string current: ""
    property real anchorY: 0
    property date today: new Date()
    signal closeRequested

    property string shown: ""
    onCurrentChanged: if (current !== "") shown = current

    visible: current !== ""
    color: "transparent"
    anchors { top: true; bottom: true; right: true }
    exclusionMode: ExclusionMode.Ignore
    margins.right: Theme.barWidth + 8
    implicitWidth: Theme.menuWidth
    mask: Region { item: card }

    WlrLayershell.namespace: "quickshell-bar-menu"
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand

    HyprlandFocusGrab {
        active: root.visible
        windows: [root, root.barWindow]
        onCleared: root.closeRequested()
    }

    Rectangle {
        id: card
        readonly property int edge: Theme.frame + 8
        width: parent.width
        height: content.implicitHeight + 28
        y: Math.max(edge, Math.min(root.anchorY - height / 2, root.height - height - edge))
        radius: Theme.radius + 4
        color: Theme.bg
        border.width: 1
        border.color: Theme.surfaceHi

        FocusScope {
            anchors.fill: parent
            anchors.margins: 14
            focus: true
            Keys.onEscapePressed: root.closeRequested()

            Loader {
                id: content
                width: parent.width
                focus: true
                active: root.visible
                sourceComponent: {
                    switch (root.shown) {
                    case "audio": return audio;
                    case "bluetooth": return bluetooth;
                    case "network": return network;
                    case "calendar": return calendar;
                    case "battery": return battery;
                    }
                    return null;
                }
            }
        }
    }

    Component { id: audio; AudioMenu {} }
    Component { id: bluetooth; BluetoothMenu {} }
    Component { id: network; NetworkMenu {} }
    Component { id: calendar; CalendarMenu { today: root.today } }
    Component { id: battery; BatteryMenu {} }
}
