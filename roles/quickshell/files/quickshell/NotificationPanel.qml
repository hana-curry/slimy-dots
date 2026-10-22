import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland

PanelWindow {
    id: root

    readonly property bool focusedScreen: Hyprland.focusedMonitor?.name === screen?.name
    readonly property bool shown: Notifications.count > 0 && focusedScreen

    property real heldHeight: 0
    property real heldListHeight: 0

    visible: shown || drawer.x < root.implicitWidth
    color: "transparent"
    anchors { top: true; right: true }
    exclusionMode: ExclusionMode.Ignore
    margins.top: 48
    margins.right: Theme.barWidth
    implicitWidth: 400
    implicitHeight: shown ? drawer.implicitHeight : heldHeight

    WlrLayershell.namespace: "quickshell-notifications"
    WlrLayershell.layer: WlrLayer.Overlay

    Column {
        id: drawer
        width: parent.width
        x: root.shown ? 0 : root.implicitWidth
        onImplicitHeightChanged: if (root.shown) root.heldHeight = implicitHeight

        Behavior on x {
            NumberAnimation { duration: 400; easing.type: Easing.OutCubic }
        }

        Image {
            anchors.right: parent.right
            source: Qt.resolvedUrl("icons/corner.svg")
            sourceSize: Qt.size(24, 24)
            rotation: 90
        }

        Rectangle {
            width: parent.width
            implicitHeight: body.implicitHeight + 32
            color: Theme.bg
            topLeftRadius: 16
            bottomLeftRadius: 16

            Column {
                id: body
                x: 16
                y: 16
                width: parent.width - 32
                spacing: 16

                Text {
                    text: "Notifications"
                    color: Theme.fg
                    font.family: Theme.font
                    font.weight: Font.Medium
                    font.pixelSize: 16
                }

                ListView {
                    id: list
                    width: parent.width
                    height: root.shown ? Math.min(contentHeight, 640) : root.heldListHeight
                    onHeightChanged: if (root.shown) root.heldListHeight = height
                    interactive: contentHeight > height
                    clip: true
                    spacing: 16
                    verticalLayoutDirection: ListView.BottomToTop
                    model: Notifications.list
                    delegate: NotificationCard {}

                    add: Transition {
                        NumberAnimation { property: "x"; from: list.width; to: 0; duration: 400; easing.type: Easing.OutCubic }
                    }
                    remove: Transition {
                        NumberAnimation { property: "x"; to: list.width; duration: 400; easing.type: Easing.OutCubic }
                    }
                    displaced: Transition {
                        NumberAnimation { property: "y"; duration: 180; easing.type: Easing.OutCubic }
                    }
                }
            }
        }

        Image {
            anchors.right: parent.right
            source: Qt.resolvedUrl("icons/corner.svg")
            sourceSize: Qt.size(24, 24)
        }
    }
}
