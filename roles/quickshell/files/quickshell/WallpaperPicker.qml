import QtQuick
import Qt.labs.folderlistmodel
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Hyprland
import Quickshell.Widgets

PanelWindow {
    id: root

    property bool open: false
    readonly property string folder: Quickshell.env("HOME") + "/Pictures/wallpapers"
    readonly property string sddmFolder: "/usr/share/sddm/themes/SlimyGreat/wallpaper"
    property string applied: ""
    property var files: []
    readonly property int slots: files.length === 0 ? 0 : files.length * Math.ceil(6 / files.length)

    function toggle() {
        if (open) {
            close();
            return;
        }
        const name = Hyprland.focusedMonitor?.name;
        screen = Quickshell.screens.find(s => s.name === name) ?? Quickshell.screens[0];
        open = true;
        carousel.forceActiveFocus();
        query.running = true;
    }

    function close() {
        open = false;
    }

    function fileAt(slot) {
        return files.length > 0 ? files[((slot % files.length) + files.length) % files.length] : "";
    }

    function apply() {
        const path = fileAt(carousel.currentIndex);
        if (path === "") return;
        applied = path;
        setter.command = ["awww", "img", path,
                          "--transition-type", "wipe", "--transition-angle", "30",
                          "--transition-fps", "60", "--transition-duration", "1"];
        setter.running = true;
        close();
    }

    function rebuild() {
        const list = [];
        for (let i = 0; i < folderModel.count; i++)
            list.push(folderModel.get(i, "filePath"));
        files = list;
    }

    IpcHandler {
        target: "wallpapers"
        function toggle(): void { root.toggle(); }
    }

    FolderListModel {
        id: folderModel
        folder: "file://" + root.folder
        nameFilters: ["*.jpg", "*.jpeg", "*.png", "*.gif", "*.webp", "*.bmp", "*.tif", "*.tiff", "*.tga", "*.pnm", "*.ff"]
        caseSensitive: false
        showDirs: false
        sortCaseSensitive: false
        onCountChanged: root.rebuild()
        onStatusChanged: if (status === FolderListModel.Ready) root.rebuild()
    }

    Process {
        id: query
        command: ["awww", "query"]
        stdout: StdioCollector {
            onStreamFinished: {
                const match = text.match(/image: (.+)/);
                const current = match ? match[1].trim().split("/").pop() : "";
                const index = root.files.findIndex(f => f.split("/").pop() === current);
                if (index >= 0) {
                    carousel.currentIndex = index;
                    carousel.positionViewAtIndex(index, PathView.Center);
                }
            }
        }
    }

    Process {
        id: setter
        onExited: code => {
            if (code === 0) {
                sddmCopy.running = true;
                return;
            }
            Quickshell.execDetached(["notify-send", "-a", "Fond d'écran", "-u", "normal",
                                     "Impossible de changer le fond d'écran",
                                     "awww n'a pas pu appliquer l'image. awww-daemon est-il lancé ?"]);
        }
    }

    Process {
        id: sddmCopy
        command: ["sh", "-c", `
            dir=$1; ext=$(printf %s "\${2##*.}" | tr A-Z a-z)
            tmp=$(mktemp "$dir/.new.XXXXXX") || exit 1
            cp -- "$2" "$tmp" && mv -f -- "$tmp" "$dir/wallpaper.$ext" || { rm -f -- "$tmp"; exit 1; }
            for e in png jpg jpeg gif webp bmp tif tiff tga pnm ff; do
                [ "$e" = "$ext" ] || rm -f -- "$dir/wallpaper.$e"
            done`, "sh", root.sddmFolder, root.applied]
        onExited: code => {
            if (code !== 0)
                Quickshell.execDetached(["notify-send", "-a", "Fond d'écran", "-u", "normal",
                                         "Fond d'écran de connexion inchangé",
                                         "Impossible de copier l'image dans " + root.sddmFolder]);
        }
    }

    visible: open || panel.y < area.height
    color: "transparent"
    anchors { top: true; bottom: true; left: true; right: true }
    exclusionMode: ExclusionMode.Ignore
    mask: Region { item: panel }

    WlrLayershell.namespace: "quickshell-wallpapers"
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: open ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None

    HyprlandFocusGrab {
        active: root.open
        windows: [root]
        onCleared: root.close()
    }

    Item {
        id: area
        width: parent.width
        height: parent.height - Theme.frame
        clip: true

        Image {
            x: panel.x - 24
            y: panel.y + panel.height - 24
            source: Qt.resolvedUrl("icons/corner.svg")
            sourceSize: Qt.size(24, 24)
            rotation: 90
        }
        Image {
            x: panel.x + panel.width
            y: panel.y + panel.height - 24
            source: Qt.resolvedUrl("icons/corner.svg")
            sourceSize: Qt.size(24, 24)
            rotation: 180
        }

        Rectangle {
            id: panel
            x: Math.round((parent.width - width) / 2)
            y: root.open ? parent.height - height : parent.height
            width: 705
            height: 216
            color: Theme.bg
            topLeftRadius: 16
            topRightRadius: 16
            clip: true

            Behavior on y {
                NumberAnimation { duration: 400; easing.type: Easing.OutCubic }
            }

            Repeater {
                model: [-82, 82]

                Rectangle {
                    required property int modelData
                    visible: root.files.length > 0
                    x: (panel.width - width) / 2
                    y: panel.height / 2 + modelData - height / 2
                    width: 258
                    height: 4
                    radius: 8
                    color: Theme.surface

                    Rectangle {
                        anchors.centerIn: parent
                        width: 95
                        height: 4
                        radius: 8
                        color: Theme.accent
                    }
                }
            }

            Text {
                visible: root.files.length === 0
                anchors.centerIn: parent
                text: "Aucun fond d'écran dans ~/Pictures/wallpapers"
                color: Theme.surfaceHi
                font.family: Theme.textFont
                font.bold: true
                font.pixelSize: 16
            }

            PathView {
                id: carousel
                anchors.fill: parent
                visible: root.files.length > 0
                model: root.slots
                pathItemCount: 5
                preferredHighlightBegin: 0.5
                preferredHighlightEnd: 0.5
                highlightRangeMode: PathView.StrictlyEnforceRange
                highlightMoveDuration: 250
                interactive: false
                focus: true

                Keys.onLeftPressed: decrementCurrentIndex()
                Keys.onRightPressed: incrementCurrentIndex()
                Keys.onReturnPressed: root.apply()
                Keys.onEnterPressed: root.apply()
                Keys.onEscapePressed: root.close()
                Keys.onPressed: event => {
                    if (event.key === Qt.Key_H) {
                        decrementCurrentIndex();
                        event.accepted = true;
                    } else if (event.key === Qt.Key_L) {
                        incrementCurrentIndex();
                        event.accepted = true;
                    }
                }

                readonly property real step: 238.5
                readonly property real cx: width / 2
                readonly property real cy: height / 2

                path: Path {
                    startX: carousel.cx - 2.5 * carousel.step
                    startY: carousel.cy
                    PathAttribute { name: "t"; value: 0 }
                    PathLine { x: carousel.cx - carousel.step; y: carousel.cy }
                    PathAttribute { name: "t"; value: 0 }
                    PathLine { x: carousel.cx; y: carousel.cy }
                    PathAttribute { name: "t"; value: 1 }
                    PathLine { x: carousel.cx + carousel.step; y: carousel.cy }
                    PathAttribute { name: "t"; value: 0 }
                    PathLine { x: carousel.cx + 2.5 * carousel.step; y: carousel.cy }
                    PathAttribute { name: "t"; value: 0 }
                }

                delegate: Item {
                    id: slot
                    required property int index
                    readonly property real t: PathView.t ?? 0
                    readonly property real w: 186 + (258 - 186) * t
                    readonly property real h: 104 + (144 - 104) * t

                    width: 258
                    height: 144
                    z: t

                    ClippingRectangle {
                        x: (parent.width - width) / 2
                        y: parent.height - height
                        width: slot.w
                        height: slot.h
                        radius: 8
                        color: Theme.surface

                        Image {
                            anchors.fill: parent
                            source: "file://" + root.fileAt(slot.index)
                            sourceSize: Qt.size(516, 288)
                            fillMode: Image.PreserveAspectCrop
                            asynchronous: true
                        }
                    }
                }
            }
        }
    }
}
