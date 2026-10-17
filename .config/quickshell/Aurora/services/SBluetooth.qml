pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Bluetooth

Singleton {
    readonly property bool enabled: Bluetooth.defaultAdapter?.enabled ?? false
    readonly property int connectedDevices: Bluetooth.devices.values.filter(device => device.connected).length
}
