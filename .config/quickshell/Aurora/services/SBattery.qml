pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.UPower

Singleton {
    id: root

    readonly property UPowerDevice device: UPower.displayDevice
    readonly property bool present: device.isLaptopBattery
    readonly property int level: Math.round(device.percentage * 100)
    readonly property bool isCharging: [UPowerDeviceState.Charging, UPowerDeviceState.FullyCharged].includes(device.state)
    readonly property bool onAc: !UPower.onBattery

    readonly property real energy: device.energy // Wh
    readonly property real energyFull: device.energyCapacity // Wh
    readonly property real rate: Math.abs(device.changeRate) // W
    // UPower's display device is a composite without health; read the real
    // battery's design capacity from sysfs instead (µWh).
    readonly property UPowerDevice battery: UPower.devices.values.find(d => d.isLaptopBattery) ?? null
    readonly property real energyDesign: Number(designFile.text().trim()) / 1e6 || -1
    readonly property real health: energyDesign > 0 ? energyFull / energyDesign * 100 : -1

    FileView {
        id: designFile
        path: root.battery?.nativePath ? `/sys/class/power_supply/${root.battery.nativePath}/energy_full_design` : ""
    }

    readonly property string icon: {
        if (isCharging)
            return "battery_charging_full";
        if (level >= 95)
            return "battery_full";
        return `battery_${Math.max(0, Math.min(6, Math.floor(level / 14)))}_bar`;
    }

    readonly property string status: {
        switch (device.state) {
        case UPowerDeviceState.Charging:
            return "Charging";
        case UPowerDeviceState.Discharging:
            return "On battery";
        case UPowerDeviceState.FullyCharged:
            return "Fully charged";
        case UPowerDeviceState.PendingCharge:
            return "Not charging";
        case UPowerDeviceState.Empty:
            return "Empty";
        default:
            return onAc ? "Plugged in" : "On battery";
        }
    }

    // "1 h 20 min until full" / "3 h 5 min left" / ""
    readonly property string timeLeft: {
        if (device.state === UPowerDeviceState.Charging && device.timeToFull > 0)
            return `${formatDuration(device.timeToFull)} until full`;
        if (device.state === UPowerDeviceState.Discharging && device.timeToEmpty > 0)
            return `${formatDuration(device.timeToEmpty)} left`;
        return "";
    }

    function formatDuration(seconds: real): string {
        const hours = Math.floor(seconds / 3600);
        const minutes = Math.round(seconds % 3600 / 60);
        return hours > 0 ? `${hours} h ${minutes} min` : `${minutes} min`;
    }
}
