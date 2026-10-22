import QtQuick

Rectangle {
    id: root
    property bool active: false
    property string icon: ""
    default property alias content: holder.data
    readonly property bool hovered: area.containsMouse
    signal clicked(var mouse)
    signal wheel(var event)

    implicitWidth: 32
    implicitHeight: Math.max(32, holder.height + 16)
    radius: Theme.radius
    color: active || hovered ? Theme.surfaceHi : Theme.surface
    Behavior on color { ColorAnimation { duration: 120 } }

    Image {
        visible: root.icon !== ""
        anchors.centerIn: parent
        source: root.icon !== "" ? Theme.lucide(root.icon) : ""
        sourceSize: Qt.size(16, 16)
    }

    Item {
        id: holder
        anchors.centerIn: parent
        width: visibleChildren.reduce((w, c) => Math.max(w, c.x + c.width), 0)
        height: visibleChildren.reduce((h, c) => Math.max(h, c.y + c.height), 0)
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
