import QtQuick

Rectangle {
    id: root
    property string icon
    property color iconColor: Theme.fg
    property bool active: false
    readonly property bool hovered: area.containsMouse
    signal clicked(var mouse)
    signal wheel(var event)

    implicitWidth: 32
    implicitHeight: 24
    radius: Theme.radius
    color: active || hovered ? Theme.surface : "transparent"
    Behavior on color { ColorAnimation { duration: 120 } }

    LucideIcon {
        anchors.centerIn: parent
        name: root.icon
        color: root.iconColor
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
