import QtQuick

Rectangle {
    id: root
    property bool checked
    signal toggled

    implicitWidth: 40
    implicitHeight: 22
    radius: 11
    color: checked ? Theme.accent : Theme.surfaceHi
    Behavior on color { ColorAnimation { duration: 150 } }

    Rectangle {
        width: 16; height: 16; radius: 8
        y: 3
        x: root.checked ? root.width - width - 3 : 3
        color: root.checked ? Theme.bg : Theme.fg
        Behavior on x { NumberAnimation { duration: 150; easing.type: Easing.OutCubic } }
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: root.toggled()
    }
}
