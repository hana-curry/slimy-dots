import QtQuick
import Quickshell
import Quickshell.Widgets
import Quickshell.Hyprland
import Quickshell.Services.Notifications

Rectangle {
    id: root
    required property Notification modelData
    readonly property Notification notif: modelData

    readonly property int timeout: notif?.expireTimeout > 0 ? notif?.expireTimeout * 1000 : 5000
    readonly property bool critical: notif?.urgency === NotificationUrgency.Critical

    readonly property string iconSource: {
        const img = (notif?.image || notif?.appIcon || "").replace(/^image:\/\/icon\//, "");
        if (!img) return "";
        if (img.startsWith("/")) return "file://" + img;
        if (img.includes("://")) return img;
        return Quickshell.iconPath(img, true);
    }

    function open() {
        const n = notif;
        if (!n) return;

        const actions = n.actions ?? [];
        const action = actions.find(a => a.identifier === "default")
            ?? (actions.length === 1 ? actions[0] : null);
        if (action) {
            action.invoke();
        } else {
            const names = [n.desktopEntry, n.appName].filter(Boolean).map(x => x.toLowerCase());
            const win = Hyprland.toplevels.values.find(t => {
                const cls = (t.lastIpcObject?.class ?? "").toLowerCase();
                return cls !== "" && names.some(x => cls === x || cls.endsWith("." + x) || x.endsWith("." + cls));
            });
            if (win) {
                const addr = win.address.startsWith("0x") ? win.address : "0x" + win.address;
                Hyprland.dispatch(`focuswindow address:${addr}`);
            } else {
                const entry = (n.desktopEntry && DesktopEntries.byId(n.desktopEntry))
                    || DesktopEntries.heuristicLookup(n.appName);
                entry?.execute();
            }
        }
        if (!n.resident) n.dismiss();
    }

    Component.onCompleted: Hyprland.refreshToplevels()

    width: ListView.view ? ListView.view.width : 261
    implicitHeight: content.implicitHeight + 24
    radius: 12
    color: Theme.surface

    Timer {
        running: !root.critical && !area.containsMouse
        interval: root.timeout
        onTriggered: root.notif?.expire()
    }

    Column {
        id: content
        x: 12
        y: 12
        width: parent.width - 24
        spacing: 10

        Item {
            width: parent.width
            height: 24

            Row {
                anchors.verticalCenter: parent.verticalCenter
                spacing: 10

                ClippingRectangle {
                    visible: root.iconSource !== ""
                    width: 24
                    height: 24
                    radius: 4
                    color: Theme.surface

                    Image {
                        anchors.fill: parent
                        source: root.iconSource
                        sourceSize: Qt.size(48, 48)
                        fillMode: Image.PreserveAspectCrop
                        asynchronous: true
                    }
                }

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    width: Math.min(implicitWidth, content.width - 24 - 10 - 22)
                    text: root.notif?.appName || "Notification"
                    elide: Text.ElideRight
                    color: Theme.fg
                    font.family: Theme.textFont
                    font.weight: Font.Medium
                    font.pixelSize: 14
                }
            }

            Rectangle {
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                width: 12
                height: 12
                radius: 6
                color: root.critical ? Theme.bad
                    : root.notif?.urgency === NotificationUrgency.Low ? Theme.muted : Theme.accent
            }
        }

        Text {
            visible: text !== ""
            width: parent.width
            text: root.notif?.summary ?? ""
            wrapMode: Text.Wrap
            maximumLineCount: 2
            elide: Text.ElideRight
            textFormat: Text.PlainText
            color: Theme.fg
            font.family: Theme.textFont
            font.weight: Font.Medium
            font.pixelSize: 12
            lineHeight: 1.2
        }

        Text {
            visible: text !== ""
            width: parent.width
            text: root.notif?.body ?? ""
            wrapMode: Text.Wrap
            maximumLineCount: 4
            elide: Text.ElideRight
            textFormat: Text.PlainText
            color: Theme.fg
            font.family: Theme.textFont
            font.pixelSize: 12
            lineHeight: 1.2
        }
    }

    MouseArea {
        id: area
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        onClicked: mouse => {
            if (mouse.button === Qt.RightButton) root.notif?.dismiss();
            else root.open();
        }
    }
}
