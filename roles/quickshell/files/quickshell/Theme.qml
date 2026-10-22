pragma Singleton
import QtQuick
import Quickshell

Singleton {
    readonly property color bg: "#eff1f5"
    readonly property color surface: "#dce0e8"
    readonly property color surfaceHi: "#ccd0da"
    readonly property color fg: "#4c4f69"
    readonly property color muted: "#6c6f85"
    readonly property color faint: "#9ca0b0"
    readonly property color accent: "#04a5e5"
    readonly property color good: "#40a02b"
    readonly property color bad: "#d20f39"
    readonly property color warn: "#df8e1d"

    readonly property string font: "Iosevka Nerd Font"
    readonly property string textFont: "Inter"
    readonly property int barWidth: 48
    readonly property int frame: 16
    readonly property int menuWidth: 320
    readonly property int radius: 8

    function lucide(name) { return Qt.resolvedUrl(`icons/${name}.svg`); }
    function lucidePath(name) { return lucide(name).toString().replace(/^file:\/\//, ""); }

    function wifiIcon(strength) {
        return strength > 0.66 ? "wifi-high" : strength > 0.33 ? "wifi-medium" : "wifi-low";
    }

    function volumeIcon(volume, muted) {
        if (muted || volume <= 0) return "volume-off";
        return volume < 0.34 ? "volume" : volume < 0.67 ? "volume-1" : "volume-2";
    }

    function batteryIcon(percent, charging) {
        if (charging) return "battery-charging";
        if (percent < 25) return "battery-very-low";
        if (percent < 50) return "battery-low";
        if (percent < 75) return "battery-medium";
        return "battery-full";
    }
}
