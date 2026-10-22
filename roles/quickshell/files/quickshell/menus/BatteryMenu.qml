import QtQuick
import QtQuick.Layouts
import Quickshell.Services.UPower
import ".."

ColumnLayout {
    id: root
    spacing: 12

    readonly property UPowerDevice battery: UPower.displayDevice
    readonly property int percent: Math.round(battery.percentage * 100)
    readonly property bool charging: battery.state === UPowerDeviceState.Charging
        || battery.state === UPowerDeviceState.PendingCharge

    function duration(seconds) {
        const h = Math.floor(seconds / 3600);
        const m = Math.round((seconds % 3600) / 60);
        return h > 0 ? `${h} h ${m} min` : `${m} min`;
    }

    MenuHeader {
        icon: Theme.batteryIcon(root.percent, root.charging)
        iconColor: Theme.fg
        title: "Battery"
        subtitle: {
            switch (root.battery.state) {
            case UPowerDeviceState.Charging: return "Charging";
            case UPowerDeviceState.FullyCharged: return "Fully charged";
            case UPowerDeviceState.PendingCharge: return "Plugged in, not charging";
            case UPowerDeviceState.Empty: return "Empty";
            }
            return "On battery";
        }
    }

    Text {
        Layout.fillWidth: true
        horizontalAlignment: Text.AlignHCenter
        text: `${root.percent}%`
        color: root.charging || root.percent >= 50 ? Theme.fg
            : root.percent < 25 ? Theme.bad : Theme.warn
        font.family: Theme.font
        font.pixelSize: 36
        font.bold: true
    }

    Text {
        readonly property real seconds: root.charging ? root.battery.timeToFull : root.battery.timeToEmpty
        visible: seconds > 0
        Layout.fillWidth: true
        horizontalAlignment: Text.AlignHCenter
        text: `${root.duration(seconds)} until ${root.charging ? "full" : "empty"}`
        color: Theme.muted
        font.family: Theme.font
        font.pixelSize: 12
    }
}
