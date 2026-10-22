import QtQuick

Rectangle {
    id: root
    property string icon
    property bool active: false
    property color iconColor: active ? Theme.bg : Theme.fg
    property int size: 32
    property int iconSize: 16
    signal clicked(var mouse)
    signal wheel(var event)

    implicitWidth: size
    implicitHeight: size
    radius: size / 2
    color: active ? Theme.accent : area.containsMouse ? Theme.surfaceHi : "transparent"
    Behavior on color { ColorAnimation { duration: 120 } }

    LucideIcon {
        anchors.centerIn: parent
        name: root.icon
        color: root.iconColor
        size: root.iconSize
    }

    MouseArea {
        id: area
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton
        onClicked: mouse => root.clicked(mouse)
        onWheel: event => root.wheel(event)
    }
}
