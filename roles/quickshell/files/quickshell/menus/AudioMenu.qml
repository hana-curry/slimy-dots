import QtQuick
import QtQuick.Layouts
import QtQuick.Controls.Basic
import Quickshell.Services.Pipewire
import ".."

ColumnLayout {
    id: root
    spacing: 14

    readonly property PwNode sink: Pipewire.defaultAudioSink
    readonly property real volume: sink?.audio?.volume ?? 0
    readonly property bool muted: sink?.audio?.muted ?? false

    PwObjectTracker { objects: [root.sink] }

    MenuHeader {
        icon: Theme.volumeIcon(root.volume, root.muted)
        title: "Audio"
        subtitle: root.sink ? (root.sink.description || root.sink.nickname || root.sink.name) : "No output device"
    }

    RowLayout {
        Layout.fillWidth: true
        spacing: 10

        IconButton {
            icon: Theme.volumeIcon(root.volume, root.muted)
            iconColor: root.muted ? Theme.bad : Theme.fg
            onClicked: if (root.sink?.audio) root.sink.audio.muted = !root.muted
        }

        Slider {
            id: slider
            Layout.fillWidth: true
            enabled: root.sink?.audio != null
            from: 0
            to: 1
            stepSize: 0.01
            value: root.volume
            onMoved: root.sink.audio.volume = value

            background: Rectangle {
                x: slider.leftPadding
                y: slider.topPadding + slider.availableHeight / 2 - height / 2
                width: slider.availableWidth
                height: 6
                radius: 3
                color: Theme.surfaceHi

                Rectangle {
                    width: slider.visualPosition * parent.width
                    height: parent.height
                    radius: 3
                    color: root.muted ? Theme.muted : Theme.accent
                }
            }

            handle: Rectangle {
                x: slider.leftPadding + slider.visualPosition * (slider.availableWidth - width)
                y: slider.topPadding + slider.availableHeight / 2 - height / 2
                width: 16
                height: 16
                radius: 8
                color: slider.pressed ? Theme.accent : Theme.fg
            }
        }

        Text {
            Layout.preferredWidth: 38
            horizontalAlignment: Text.AlignRight
            text: `${Math.round(root.volume * 100)}%`
            color: Theme.fg
            font.family: Theme.font
            font.pixelSize: 13
        }
    }
}
