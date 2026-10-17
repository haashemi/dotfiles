pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Services.UPower

Singleton {
    readonly property bool present: UPower.displayDevice.isLaptopBattery
    readonly property int level: Math.round(UPower.displayDevice.percentage * 100)
    readonly property bool isCharging: [UPowerDeviceState.Charging, UPowerDeviceState.FullyCharged].includes(UPower.displayDevice.state)
}
