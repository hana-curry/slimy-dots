import QtQuick
import Quickshell.Io

Image {
    id: root
    property string name
    property color color: Theme.fg
    property int size: 16

    width: size
    height: size
    sourceSize: Qt.size(size, size)
    source: {
        const svg = file.text();
        if (!svg) return "";
        return "data:image/svg+xml;utf8," + encodeURIComponent(svg.replace(/#4C4F69/gi, String(root.color)));
    }

    FileView {
        id: file
        path: root.name !== "" ? Theme.lucidePath(root.name) : ""
        blockLoading: true
    }
}
