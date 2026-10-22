import QtQuick

Image {
    property real s: 1

    width: Math.round(24 * s)
    height: width
    source: Qt.resolvedUrl("../assets/corner.svg")
    sourceSize: Qt.size(width, height)
    smooth: true
}
