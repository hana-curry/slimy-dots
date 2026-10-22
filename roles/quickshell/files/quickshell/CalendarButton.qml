import QtQuick

NavButton {
    id: root
    property date date: new Date()

    Column {
        spacing: 2

        Text {
            width: 16
            height: 15
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            text: Qt.formatDate(root.date, "dd")
            color: Theme.fg
            font.family: Theme.font
            font.weight: Font.Medium
            font.pixelSize: 15
        }
        Text {
            width: 16
            height: 15
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            text: Qt.locale().standaloneMonthName(root.date.getMonth(), Locale.ShortFormat)
                .replace(/[.\s]/g, "").slice(0, 3).toUpperCase()
            color: Theme.fg
            font.family: Theme.font
            font.bold: true
            font.pixelSize: 10
        }
    }
}
