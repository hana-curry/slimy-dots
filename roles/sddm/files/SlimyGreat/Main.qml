import QtQuick
import "components"

Rectangle {
    id: root

    readonly property real s: Math.min(width / Theme.designWidth, height / Theme.designHeight)
    readonly property real frame: Math.round(16 * s)
    readonly property real sideMargin: Math.round(64 * s)
    readonly property bool showPanels: typeof primaryScreen === "undefined" || primaryScreen

    width: Theme.designWidth
    height: Theme.designHeight
    color: Theme.base

    readonly property var wallpaperCandidates: ["png", "jpg", "jpeg", "gif", "webp", "bmp", "tif", "tiff", "tga", "pnm"]
        .map(ext => Qt.resolvedUrl("wallpaper/wallpaper." + ext))
    property int wallpaperCandidate: 0
    property url wallpaper: ""

    Image {
        visible: false
        asynchronous: true
        sourceSize: Qt.size(1, 1)
        source: root.wallpaperCandidate < root.wallpaperCandidates.length
            ? root.wallpaperCandidates[root.wallpaperCandidate] : ""
        onStatusChanged: {
            if (status === Image.Ready)
                root.wallpaper = source
            else if (status === Image.Error)
                root.wallpaperCandidate++
        }
    }

    Rectangle {
        anchors.fill: parent
        color: "black"
    }

    Loader {
        anchors.fill: parent
        active: root.wallpaper != ""
        sourceComponent: root.wallpaper.toString().endsWith(".gif") ? animatedWallpaper : stillWallpaper
    }

    Component {
        id: stillWallpaper
        Image {
            source: root.wallpaper
            fillMode: Image.PreserveAspectCrop
            asynchronous: true
            smooth: true
            mipmap: true
        }
    }

    Component {
        id: animatedWallpaper
        AnimatedImage {
            source: root.wallpaper
            fillMode: Image.PreserveAspectCrop
            asynchronous: true
            smooth: true
        }
    }

    Rectangle { anchors { left: parent.left; right: parent.right; top: parent.top } height: root.frame; color: Theme.base }
    Rectangle { anchors { left: parent.left; right: parent.right; bottom: parent.bottom } height: root.frame; color: Theme.base }
    Rectangle { anchors { left: parent.left; top: parent.top; bottom: parent.bottom } width: root.frame; color: Theme.base }
    Rectangle { anchors { right: parent.right; top: parent.top; bottom: parent.bottom } width: root.frame; color: Theme.base }

    Corner { s: root.s; x: root.width - root.frame - width; y: root.frame; rotation: 0 }
    Corner { s: root.s; x: root.width - root.frame - width; y: root.height - root.frame - height; rotation: 90 }
    Corner { s: root.s; x: root.frame; y: root.height - root.frame - height; rotation: 180 }
    Corner { s: root.s; x: root.frame; y: root.frame; rotation: -90 }

    MouseArea {
        anchors.fill: parent
        enabled: sessionPanel.open
        onClicked: sessionPanel.open = false
    }

    LoginPanel {
        id: loginPanel
        visible: root.showPanels
        s: root.s
        sessionIndex: sessionPanel.sessionIndex
        anchors.left: parent.left
        anchors.leftMargin: root.sideMargin
        anchors.bottom: parent.bottom
        anchors.bottomMargin: root.frame
    }

    SessionPanel {
        id: sessionPanel
        visible: root.showPanels
        s: root.s
        forcePowerButton: !!config.previewShot
        anchors.right: parent.right
        anchors.rightMargin: root.sideMargin
        anchors.bottom: parent.bottom
        anchors.bottomMargin: root.frame
    }

    Keys.onEscapePressed: sessionPanel.open = false

    Component.onCompleted: {
        if (showPanels)
            loginPanel.focusInput()
        if (config.previewShot)
            previewTimer.start()
    }

    Timer {
        id: previewTimer
        interval: 600
        onTriggered: {
            if (config.previewState === "error")
                loginPanel.showError()
            else if (config.previewState === "open")
                sessionPanel.open = true
            grabTimer.start()
        }
    }
    Timer {
        id: grabTimer
        interval: 600
        onTriggered: root.grabToImage(function (result) {
            result.saveToFile(config.previewShot)
            Qt.quit()
        })
    }
}
