import QtQuick
import QtQuick.Layouts
import ".."

ColumnLayout {
    id: root
    spacing: 10

    property date today: new Date()
    property int year: today.getFullYear()
    property int month: today.getMonth()
    property int direction: 0

    readonly property bool isCurrentMonth: year === today.getFullYear() && month === today.getMonth()

    function shift(delta) {
        direction = delta;
        const d = new Date(year, month + delta, 1);
        year = d.getFullYear();
        month = d.getMonth();
        slide.restart();
    }

    function goToday() {
        if (isCurrentMonth) return;
        direction = (year * 12 + month) > (today.getFullYear() * 12 + today.getMonth()) ? -1 : 1;
        year = today.getFullYear();
        month = today.getMonth();
        slide.restart();
    }

    Keys.onLeftPressed: shift(-1)
    Keys.onRightPressed: shift(1)

    RowLayout {
        Layout.fillWidth: true

        NavButton {
            icon: "chevron-left"
            onClicked: root.shift(-1)
        }

        Item {
            Layout.fillWidth: true
            implicitHeight: monthTitle.implicitHeight

            Text {
                id: monthTitle
                anchors.centerIn: parent
                text: Qt.locale().standaloneMonthName(root.month) + " " + root.year
                color: titleArea.containsMouse && !root.isCurrentMonth ? Theme.accent : Theme.fg
                font.family: Theme.font
                font.pixelSize: 16
                font.bold: true
                font.capitalization: Font.Capitalize
            }
            MouseArea {
                id: titleArea
                anchors.fill: monthTitle
                hoverEnabled: true
                cursorShape: root.isCurrentMonth ? Qt.ArrowCursor : Qt.PointingHandCursor
                onClicked: root.goToday()
            }
        }

        NavButton {
            icon: "chevron-right"
            onClicked: root.shift(1)
        }
    }

    GridLayout {
        Layout.fillWidth: true
        columns: 7
        columnSpacing: 0
        rowSpacing: 0

        Repeater {
            model: 7
            Text {
                required property int index
                Layout.fillWidth: true
                Layout.preferredWidth: 1
                horizontalAlignment: Text.AlignHCenter
                text: Qt.locale().dayName((index + 1) % 7, Locale.ShortFormat).slice(0, 2)
                color: index >= 5 ? Theme.bad : Theme.muted
                font.family: Theme.font
                font.pixelSize: 11
                font.bold: true
            }
        }
    }

    Item {
        Layout.fillWidth: true
        implicitHeight: days.implicitHeight
        clip: true

        WheelHandler {
            acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchPad
            onWheel: event => root.shift(event.angleDelta.y > 0 ? -1 : 1)
        }

        GridLayout {
            id: days
            width: parent.width
            columns: 7
            columnSpacing: 0
            rowSpacing: 2

            readonly property int offset: (new Date(root.year, root.month, 1).getDay() + 6) % 7

            Repeater {
                model: 42

                Item {
                    id: cell
                    required property int index
                    readonly property date date: new Date(root.year, root.month, 1 - days.offset + index)
                    readonly property bool inMonth: date.getMonth() === root.month
                    readonly property bool isToday: date.getFullYear() === root.today.getFullYear()
                        && date.getMonth() === root.today.getMonth()
                        && date.getDate() === root.today.getDate()

                    Layout.fillWidth: true
                    Layout.preferredWidth: 1
                    implicitHeight: 34

                    Rectangle {
                        anchors.centerIn: parent
                        width: 30
                        height: 30
                        radius: 15
                        color: cell.isToday ? Theme.accent : "transparent"
                    }

                    Text {
                        anchors.centerIn: parent
                        text: cell.date.getDate()
                        color: cell.isToday ? Theme.bg
                            : !cell.inMonth ? Theme.faint
                            : cell.index % 7 >= 5 ? Theme.bad : Theme.fg
                        font.family: Theme.font
                        font.pixelSize: 13
                        font.bold: cell.isToday
                    }
                }
            }
        }

        ParallelAnimation {
            id: slide
            NumberAnimation {
                target: days; property: "x"
                from: root.direction * days.width * 0.4; to: 0
                duration: 220; easing.type: Easing.OutCubic
            }
            NumberAnimation {
                target: days; property: "opacity"
                from: 0; to: 1
                duration: 220
            }
        }
    }

    Text {
        Layout.fillWidth: true
        horizontalAlignment: Text.AlignHCenter
        text: Qt.formatDate(root.today, "dddd d MMMM yyyy")
        color: Theme.muted
        font.family: Theme.font
        font.pixelSize: 12
    }
}
