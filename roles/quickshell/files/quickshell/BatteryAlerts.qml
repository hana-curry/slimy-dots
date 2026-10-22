import QtQuick
import Quickshell
import Quickshell.Services.UPower

Scope {
    id: root

    readonly property UPowerDevice battery: UPower.displayDevice
    readonly property bool hasBattery: battery.ready && battery.isLaptopBattery && battery.isPresent
    readonly property int percent: Math.round(battery.percentage * 100)
    readonly property bool charging: battery.state === UPowerDeviceState.Charging
        || battery.state === UPowerDeviceState.PendingCharge
        || battery.state === UPowerDeviceState.FullyCharged

    property bool lowSent: false
    property bool criticalSent: false

    function notify(urgency, icon, summary, body) {
        Quickshell.execDetached(["notify-send", "-a", "Batterie", "-u", urgency,
                                 "-i", Theme.lucidePath(icon), summary, body]);
    }

    function check() {
        if (!hasBattery) return;
        if (charging) {
            lowSent = false;
            criticalSent = false;
            return;
        }
        if (percent <= 10 && !criticalSent) {
            criticalSent = true;
            lowSent = true;
            notify("critical", "battery-very-low", "Batterie SUPER FAIBLE!!", "Plus que 10% de batterie!");
        } else if (percent <= 25 && !lowSent) {
            lowSent = true;
            notify("normal", "battery-low", "Batterie faible", "Plus que 25% de batterie.");
        }
    }

    onPercentChanged: check()
    onChargingChanged: check()
    onHasBatteryChanged: check()
}
