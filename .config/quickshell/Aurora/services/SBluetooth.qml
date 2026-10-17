pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Bluetooth

Singleton {
    id: root

    readonly property BluetoothAdapter adapter: Bluetooth.defaultAdapter
    readonly property bool enabled: adapter?.enabled ?? false
    readonly property var connected: Bluetooth.devices.values.filter(device => device.connected)
    readonly property int connectedDevices: connected.length

    // Paired first (connected on top), then nearby devices that have a real name.
    readonly property ScriptModel paired: ScriptModel {
        values: Bluetooth.devices.values.filter(device => device.paired || device.bonded).sort((a, b) => b.connected - a.connected)
    }
    readonly property ScriptModel available: ScriptModel {
        values: Bluetooth.devices.values.filter(device => !device.paired && !device.bonded && device.deviceName)
    }

    // Discover only while someone is looking at the list.
    property bool scanning: false
    onScanningChanged: if (adapter?.enabled)
        adapter.discovering = scanning

    function setEnabled(value: bool): void {
        if (adapter)
            adapter.enabled = value;
    }

    // Freedesktop icon name (BlueZ) -> Material Symbol.
    function deviceIcon(icon: string): string {
        if (icon.includes("headset") || icon.includes("headphone"))
            return "headphones";
        if (icon.includes("audio"))
            return "speaker";
        if (icon.includes("mouse"))
            return "mouse";
        if (icon.includes("keyboard"))
            return "keyboard";
        if (icon.includes("gaming"))
            return "sports_esports";
        if (icon.includes("phone"))
            return "smartphone";
        if (icon.includes("computer"))
            return "computer";
        return "bluetooth";
    }
}
