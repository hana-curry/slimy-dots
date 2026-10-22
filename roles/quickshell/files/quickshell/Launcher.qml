import QtQuick
import QtQuick.Controls.Basic
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Hyprland
import Quickshell.Widgets

PanelWindow {
    id: root

    property bool open: false
    property string query: ""

    function toggle() {
        if (open) {
            close();
            return;
        }
        const name = Hyprland.focusedMonitor?.name;
        screen = Quickshell.screens.find(s => s.name === name) ?? Quickshell.screens[0];
        query = "";
        search.text = "";
        open = true;
        search.forceActiveFocus();
    }

    function close() {
        open = false;
    }

    function launch(entry) {
        if (!entry) return;
        entry.execute();
        close();
    }

    IpcHandler {
        target: "launcher"
        function toggle(): void { root.toggle(); }
    }

    readonly property var results: {
        const q = query.trim().toLowerCase();
        if (q === "") return [];
        const matches = DesktopEntries.applications.values.filter(e => {
            if (e.noDisplay) return false;
            const fields = [e.name, e.genericName, ...(e.keywords ?? [])];
            return fields.some(f => f && f.toLowerCase().includes(q));
        });
        const starts = e => e.name.toLowerCase().startsWith(q) ? 0 : 1;
        return matches.sort((a, b) => (starts(a) - starts(b)) || a.name.localeCompare(b.name));
    }

    visible: open || panel.y > -panel.height
    color: "transparent"
    anchors { top: true; bottom: true; left: true; right: true }
    exclusionMode: ExclusionMode.Ignore
    mask: Region { item: panel }

    WlrLayershell.namespace: "quickshell-launcher"
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: open ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None

    HyprlandFocusGrab {
        active: root.open
        windows: [root]
        onCleared: root.close()
    }

    Item {
        y: Theme.frame
        width: parent.width
        height: parent.height - Theme.frame
        clip: true

        Image {
            x: panel.x - 24
            y: panel.y
            source: Qt.resolvedUrl("icons/corner.svg")
            sourceSize: Qt.size(24, 24)
        }
        Image {
            x: panel.x + panel.width
            y: panel.y
            source: Qt.resolvedUrl("icons/corner.svg")
            sourceSize: Qt.size(24, 24)
            rotation: 270
        }

        Rectangle {
            id: panel
            x: Math.round((parent.width - width) / 2)
            y: root.open ? 0 : -height
            width: 922
            height: 543
            color: Theme.bg
            bottomLeftRadius: 16
            bottomRightRadius: 16

            Behavior on y {
                NumberAnimation { duration: 400; easing.type: Easing.OutCubic }
            }

            FocusScope {
                anchors.fill: parent
                focus: true
                Keys.onEscapePressed: root.close()

                Rectangle {
                    x: 32
                    y: 32
                    width: 858
                    height: 37
                    radius: 32
                    color: "#ffffff"

                    Image {
                        id: searchIcon
                        x: 16
                        anchors.verticalCenter: parent.verticalCenter
                        source: Theme.lucide("search")
                        sourceSize: Qt.size(16, 16)
                    }

                    TextField {
                        id: search
                        anchors.left: searchIcon.right
                        anchors.leftMargin: 8
                        anchors.right: parent.right
                        anchors.rightMargin: 16
                        anchors.verticalCenter: parent.verticalCenter
                        padding: 0
                        background: null
                        placeholderText: "Rechercher"
                        placeholderTextColor: Theme.muted
                        color: Theme.fg
                        selectionColor: Theme.accent
                        font.family: Theme.textFont
                        font.pixelSize: 14
                        focus: true

                        onTextChanged: {
                            root.query = text;
                            grid.currentIndex = 0;
                        }
                        onAccepted: root.launch(root.results[0])
                        Keys.onEscapePressed: root.close()
                        Keys.onTabPressed: if (root.results.length > 0) grid.forceActiveFocus()
                        Keys.onDownPressed: if (root.results.length > 0) grid.forceActiveFocus()
                    }
                }

                Column {
                    visible: root.results.length === 0
                    anchors.horizontalCenter: parent.horizontalCenter
                    y: 205
                    spacing: 22

                    Image {
                        anchors.horizontalCenter: parent.horizontalCenter
                        source: Qt.resolvedUrl("icons/launcher-empty.svg")
                        sourceSize: Qt.size(141, 101)
                    }

                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: root.query.trim() === "" ? "Go find yourself" : "Nothing found"
                        color: Theme.surfaceHi
                        font.family: Theme.textFont
                        font.bold: true
                        font.pixelSize: 16
                    }
                }

                GridView {
                    id: grid
                    x: 32
                    y: 117
                    width: 857 + 8
                    height: parent.height - y - 32
                    visible: root.results.length > 0
                    clip: true
                    cellWidth: width / 8
                    cellHeight: 108
                    model: root.results
                    boundsBehavior: Flickable.StopAtBounds
                    keyNavigationEnabled: true
                    highlightFollowsCurrentItem: false

                    Keys.onEscapePressed: root.close()
                    Keys.onTabPressed: search.forceActiveFocus()
                    Keys.onReturnPressed: root.launch(root.results[currentIndex])
                    Keys.onEnterPressed: root.launch(root.results[currentIndex])
                    Keys.onUpPressed: {
                        if (currentIndex < 8) search.forceActiveFocus();
                        else moveCurrentIndexUp();
                    }

                    delegate: Item {
                        id: cell
                        required property var modelData
                        required property int index
                        readonly property bool selected: GridView.isCurrentItem
                        readonly property string iconSource: {
                            const icon = modelData.icon ?? "";
                            if (icon.startsWith("/")) return "file://" + icon;
                            return icon ? Quickshell.iconPath(icon, true) : "";
                        }

                        width: grid.cellWidth
                        height: grid.cellHeight

                        Rectangle {
                            width: parent.width - 8
                            height: parent.height - 8
                            radius: 8
                            color: cell.selected || area.containsMouse ? Theme.surface : "transparent"

                            Column {
                                x: 16
                                y: 16
                                width: parent.width - 32
                                spacing: 6

                                ClippingRectangle {
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    width: 48
                                    height: 48
                                    radius: 4
                                    color: cell.iconSource === "" ? Theme.surface : "transparent"

                                    Image {
                                        anchors.fill: parent
                                        source: cell.iconSource
                                        sourceSize: Qt.size(96, 96)
                                        fillMode: Image.PreserveAspectFit
                                        asynchronous: true
                                    }
                                }

                                Text {
                                    width: parent.width
                                    horizontalAlignment: Text.AlignHCenter
                                    text: cell.modelData.name
                                    elide: Text.ElideRight
                                    color: Theme.fg
                                    font.family: Theme.textFont
                                    font.pixelSize: 14
                                }
                            }

                            MouseArea {
                                id: area
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: root.launch(cell.modelData)
                            }
                        }
                    }
                }
            }
        }
    }
}
