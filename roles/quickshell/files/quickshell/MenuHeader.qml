import QtQuick
import QtQuick.Layouts

RowLayout {
    id: root
    property string icon
    property color iconColor: Theme.accent
    property string title
    property string subtitle
    default property alias actions: actionRow.data

    spacing: 10
    Layout.fillWidth: true

    LucideIcon {
        name: root.icon
        color: root.iconColor
        size: 20
    }
    ColumnLayout {
        spacing: 0
        Layout.fillWidth: true
        Text {
            text: root.title
            color: Theme.fg
            font.family: Theme.font
            font.pixelSize: 15
            font.bold: true
        }
        Text {
            visible: root.subtitle !== ""
            text: root.subtitle
            color: Theme.muted
            font.family: Theme.font
            font.pixelSize: 11
            elide: Text.ElideRight
            Layout.fillWidth: true
        }
    }
    RowLayout {
        id: actionRow
        spacing: 6
    }
}
