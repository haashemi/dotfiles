import QtQuick
import Quickshell.Services.UPower

QtObject {
    property int level: Math.round(UPower.displayDevice.percentage * 100)
    property bool isCharging: [UPowerDeviceState.Charging, UPowerDeviceState.FullyCharged].includes(UPower.displayDevice.state)
}
