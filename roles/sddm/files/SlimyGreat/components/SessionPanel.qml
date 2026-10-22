import QtQuick

Item {
    id: panel

    property real s: 1
    property bool open: false
    property int sessionIndex: sessionModel.lastIndex >= 0 ? sessionModel.lastIndex : 0
    property string sessionName: ""
    property bool forcePowerButton: false

    readonly property real pad: Math.round(24 * s)
    readonly property real padY: Math.round(20 * s)
    readonly property real rowHeight: Math.round(40 * s)
    readonly property real rowGap: Math.round(8 * s)
    readonly property real listHeight: sessionModel.count * (rowHeight + rowGap)

    width: pad * 2 + bottomRow.width
    height: Math.round(80 * s) + (open ? listHeight : 0)

    Behavior on height { NumberAnimation { duration: 180; easing.type: Easing.OutCubic } }

    function select(i) {
        sessionIndex = i
        open = false
        selector.forceActiveFocus()
    }

    Corner {
        s: panel.s
        anchors.right: parent.left
        anchors.bottom: parent.bottom
        rotation: 90
    }

    Corner {
        s: panel.s
        anchors.left: parent.right
        anchors.bottom: parent.bottom
        rotation: 180
    }

    Rectangle {
        id: bg
        anchors.fill: parent
        color: Theme.base
        topLeftRadius: 16 * s
        topRightRadius: 16 * s
        clip: true

        Column {
            id: list
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.margins: panel.pad
            anchors.bottom: bottomRow.top
            anchors.bottomMargin: panel.rowGap
            spacing: panel.rowGap
            opacity: panel.open ? 1 : 0
            Behavior on opacity { NumberAnimation { duration: 150 } }

            Repeater {
                model: sessionModel

                delegate: Rectangle {
                    id: row
                    required property int index
                    required property string name
                    readonly property bool current: index === panel.sessionIndex

                    onCurrentChanged: if (current) panel.sessionName = name
                    Component.onCompleted: if (current) panel.sessionName = name

                    width: list.width
                    height: panel.rowHeight
                    radius: 8 * panel.s
                    color: rowMouse.containsMouse ? Theme.surface0 : Theme.crust
                    Behavior on color { ColorAnimation { duration: 100 } }

                    Image {
                        visible: row.current
                        anchors.left: parent.left
                        anchors.leftMargin: 16 * panel.s
                        anchors.verticalCenter: parent.verticalCenter
                        width: Math.round(16 * panel.s)
                        height: width
                        source: Qt.resolvedUrl("../assets/picture-in-picture-2.svg")
                        sourceSize: Qt.size(width, height)
                    }

                    Text {
                        anchors.left: parent.left
                        anchors.leftMargin: 64 * panel.s
                        anchors.right: parent.right
                        anchors.rightMargin: 16 * panel.s
                        anchors.verticalCenter: parent.verticalCenter
                        text: row.name
                        font.family: Theme.font
                        font.weight: Font.Medium
                        font.pixelSize: 16 * panel.s
                        color: Theme.text
                        elide: Text.ElideRight
                    }

                    MouseArea {
                        id: rowMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        enabled: panel.open
                        onClicked: panel.select(row.index)
                    }
                }
            }
        }

        Row {
            id: bottomRow
            anchors.left: parent.left
            anchors.leftMargin: panel.pad
            anchors.bottom: parent.bottom
            anchors.bottomMargin: panel.padY
            spacing: Math.round(10 * s)

            Field {
                id: selector
                s: panel.s
                rightPadding: 16
                icon: Qt.resolvedUrl("../assets/picture-in-picture-2.svg")
                text: panel.sessionName
                readOnly: true
                color: selectorMouse.containsMouse || activeFocus ? Theme.surface0 : Theme.crust
                activeFocusOnTab: true

                Accessible.role: Accessible.ComboBox
                Accessible.name: "Session: " + panel.sessionName

                Keys.onSpacePressed: panel.open = !panel.open
                Keys.onReturnPressed: panel.open = !panel.open
                Keys.onEnterPressed: panel.open = !panel.open
                Keys.onEscapePressed: panel.open = false
                Keys.onUpPressed: panel.sessionIndex = Math.max(0, panel.sessionIndex - 1)
                Keys.onDownPressed: panel.sessionIndex = Math.min(sessionModel.count - 1, panel.sessionIndex + 1)

                Image {
                    width: Math.round(16 * panel.s)
                    height: width
                    source: Qt.resolvedUrl("../assets/chevron-down.svg")
                    sourceSize: Qt.size(width, height)
                    rotation: panel.open ? 180 : 0
                    Behavior on rotation { NumberAnimation { duration: 180; easing.type: Easing.OutCubic } }
                }

                MouseArea {
                    id: selectorMouse
                    parent: selector
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        panel.open = !panel.open
                        selector.forceActiveFocus()
                    }
                }
            }

            IconButton {
                s: panel.s
                visible: panel.forcePowerButton || sddm.canPowerOff
                label: "Power off"
                icon: Qt.resolvedUrl("../assets/power.svg")
                onClicked: sddm.powerOff()
            }
        }
    }
}
