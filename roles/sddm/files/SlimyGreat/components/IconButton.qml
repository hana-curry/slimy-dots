import QtQuick

Rectangle {
    id: button

    property real s: 1
    property url icon
    property string label

    signal clicked()

    width: Math.round(40 * s)
    height: width
    radius: 8 * s
    color: mouse.pressed ? Theme.surface1
         : (mouse.containsMouse || activeFocus) ? Theme.surface0
         : Theme.crust
    activeFocusOnTab: true

    Accessible.role: Accessible.Button
    Accessible.name: label
    Accessible.onPressAction: clicked()

    Keys.onReturnPressed: clicked()
    Keys.onEnterPressed: clicked()
    Keys.onSpacePressed: clicked()

    Behavior on color { ColorAnimation { duration: 100 } }

    Image {
        anchors.centerIn: parent
        width: Math.round(16 * s)
        height: width
        source: button.icon
        sourceSize: Qt.size(width, height)
    }

    MouseArea {
        id: mouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: button.clicked()
    }
}
