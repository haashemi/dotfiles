import QtQuick
import Quickshell
import Quickshell.Bluetooth

Scope {
    readonly property bool enabled: Bluetooth.defaultAdapter?.enabled ?? false
    readonly property int connectedDevices: Bluetooth.devices.values.length
}