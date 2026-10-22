import QtQuick
import Quickshell

NavButton {
    id: root

    PersistentProperties {
        id: saved
        reloadableId: "clockMode"
        property string mode: "default"
    }
    readonly property var modes: ["default", "seconds", "hidden"]
    readonly property string mode: modes.includes(saved.mode) ? saved.mode : "default"

    implicitHeight: mode === "hidden" ? 32 : mode === "seconds" ? 65 : 48

    onClicked: mouse => {
        const step = mouse.button === Qt.RightButton ? modes.length - 1 : 1;
        saved.mode = modes[(modes.indexOf(mode) + step) % modes.length];
    }

    SystemClock {
        id: clock
        enabled: root.mode !== "hidden"
        precision: root.mode === "seconds" ? SystemClock.Seconds : SystemClock.Minutes
    }

    Image {
        visible: root.mode === "hidden"
        source: Theme.lucide("clock")
        sourceSize: Qt.size(16, 16)
    }

    Column {
        visible: root.mode !== "hidden"
        spacing: 2

        Repeater {
            model: root.mode === "seconds" ? ["HH", "mm", "ss"] : ["HH", "mm"]

            Text {
                required property string modelData
                width: 16
                height: 15
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                text: Qt.formatTime(clock.date, modelData)
                color: Theme.fg
                font.family: Theme.font
                font.weight: Font.Medium
                font.pixelSize: 15
            }
        }
    }
}
