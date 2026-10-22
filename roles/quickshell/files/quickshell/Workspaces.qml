import QtQuick
import Quickshell.Hyprland

Rectangle {
    id: root
    readonly property int focusedId: Hyprland.focusedWorkspace?.id ?? -1

    implicitWidth: 32
    implicitHeight: dots.implicitHeight + 16
    radius: Theme.radius
    color: Theme.surface

    Column {
        id: dots
        anchors.centerIn: parent
        spacing: 6

        Repeater {
            model: 10

            delegate: Item {
                id: slot
                required property int index
                readonly property int wsId: index + 1
                readonly property bool focused: root.focusedId === wsId
                readonly property bool occupied: Hyprland.workspaces.values.some(w => w.id === wsId)

                width: 32
                height: 10

                Rectangle {
                    anchors.centerIn: parent
                    readonly property int size: area.containsMouse && !slot.focused ? 12 : 10
                    width: size
                    height: size
                    radius: size / 2
                    color: slot.focused ? Theme.accent : slot.occupied ? Theme.muted : Theme.bg
                    Behavior on color { ColorAnimation { duration: 150 } }
                    Behavior on width { NumberAnimation { duration: 100 } }
                    Behavior on height { NumberAnimation { duration: 100 } }
                }

                MouseArea {
                    id: area
                    anchors.fill: parent
                    anchors.margins: -3
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: Hyprland.dispatch(`workspace ${slot.wsId}`)
                }
            }
        }
    }

    WheelHandler {
        acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchPad
        onWheel: event => {
            const next = root.focusedId + (event.angleDelta.y > 0 ? -1 : 1);
            if (next >= 1 && next <= 10) Hyprland.dispatch(`workspace ${next}`);
        }
    }
}
