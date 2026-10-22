import QtQuick

Rectangle {
    id: root
    property string text
    property color accent: Theme.accent
    property bool enabled: true
    signal clicked

    implicitWidth: label.implicitWidth + 20
    implicitHeight: 26
    radius: 13
    opacity: enabled ? 1 : 0.4
    color: area.containsMouse && enabled ? accent : Theme.surfaceHi
    Behavior on color { ColorAnimation { duration: 120 } }

    Text {
        id: label
        anchors.centerIn: parent
        text: root.text
        color: area.containsMouse && root.enabled ? Theme.bg : Theme.fg
        font.family: Theme.font
        font.pixelSize: 12
        font.bold: true
    }

    MouseArea {
        id: area
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: root.enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
        onClicked: if (root.enabled) root.clicked()
    }
}
