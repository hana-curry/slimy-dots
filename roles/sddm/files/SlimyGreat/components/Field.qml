import QtQuick

Rectangle {
    id: field

    property real s: 1
    property url icon
    property string placeholder
    property bool password: false
    property bool error: false
    property bool readOnly: false
    property real rightPadding: 32
    property alias text: input.text
    property alias input: input
    default property alias trailing: trailingRow.data

    signal accepted()

    implicitWidth: Math.round(359 * s)
    implicitHeight: Math.round(40 * s)
    radius: 8 * s
    color: Theme.crust

    Image {
        id: iconImage
        anchors.left: parent.left
        anchors.leftMargin: 16 * s
        anchors.verticalCenter: parent.verticalCenter
        width: Math.round(16 * s)
        height: width
        source: field.icon
        sourceSize: Qt.size(width, height)
    }

    TextInput {
        id: input
        visible: !field.readOnly
        readOnly: field.readOnly
        anchors.left: iconImage.right
        anchors.leftMargin: 32 * s
        anchors.right: trailingRow.left
        anchors.rightMargin: trailingRow.width > 0 ? 32 * s : 0
        anchors.verticalCenter: parent.verticalCenter
        font.family: Theme.font
        font.weight: Font.Medium
        font.pixelSize: 16 * s
        color: Theme.text
        selectionColor: Theme.surface1
        selectedTextColor: Theme.text
        echoMode: field.password ? TextInput.Password : TextInput.Normal
        passwordCharacter: "•"
        clip: true
        selectByMouse: true
        activeFocusOnTab: !readOnly
        onAccepted: field.accepted()
    }

    Text {
        anchors.fill: input
        visible: field.readOnly
        text: input.text
        font: input.font
        color: input.color
        verticalAlignment: Text.AlignVCenter
        elide: Text.ElideRight
    }

    Text {
        anchors.fill: input
        visible: input.text.length === 0
        text: field.placeholder
        font: input.font
        color: field.error ? Theme.red : Theme.overlay0
        verticalAlignment: Text.AlignVCenter
        elide: Text.ElideRight
    }

    Row {
        id: trailingRow
        anchors.right: parent.right
        anchors.rightMargin: (width > 0 ? 16 : field.rightPadding) * s
        anchors.verticalCenter: parent.verticalCenter
        spacing: 8 * s
    }

    Rectangle {
        anchors.fill: parent
        radius: parent.radius
        color: "transparent"
        border.width: Math.max(1, Math.round(2 * s))
        border.color: field.error ? Theme.red : "transparent"
        Behavior on border.color { ColorAnimation { duration: 150 } }
    }
}
