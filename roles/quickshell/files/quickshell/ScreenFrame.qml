import QtQuick
import Quickshell
import Quickshell.Wayland

Scope {
    id: root
    required property ShellScreen screen
    readonly property int thickness: Theme.frame

    component Strip: PanelWindow {
        screen: root.screen
        color: Theme.bg
        exclusiveZone: root.thickness
        WlrLayershell.namespace: "quickshell-frame"
    }

    Strip {
        anchors { top: true; left: true; right: true }
        implicitHeight: root.thickness
    }
    Strip {
        anchors { bottom: true; left: true; right: true }
        implicitHeight: root.thickness
    }
    Strip {
        anchors { left: true; top: true; bottom: true }
        implicitWidth: root.thickness
    }

    component Corner: PanelWindow {
        id: corner
        property int angle: 0
        screen: root.screen
        color: "transparent"
        exclusionMode: ExclusionMode.Normal
        exclusiveZone: 0
        implicitWidth: 24
        implicitHeight: 24
        mask: Region {}
        WlrLayershell.namespace: "quickshell-frame"

        Image {
            anchors.fill: parent
            source: Qt.resolvedUrl("icons/corner.svg")
            sourceSize: Qt.size(24, 24)
            rotation: corner.angle
        }
    }

    Corner { anchors { top: true; right: true } angle: 0 }
    Corner { anchors { bottom: true; right: true } angle: 90 }
    Corner { anchors { bottom: true; left: true } angle: 180 }
    Corner { anchors { top: true; left: true } angle: 270 }
}
