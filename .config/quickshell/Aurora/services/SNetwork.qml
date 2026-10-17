pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Networking

Singleton {
    id: root

    readonly property bool wifiEnabled: Networking.wifiEnabled
    readonly property bool wifiConnected: root.wifiDevice?.connected ?? false
    readonly property real wifiStrength: root.activeWifi?.signalStrength ?? 0

    readonly property NetworkDevice wifiDevice: {
        for (const device of Networking.devices.values) {
            if (device.type === DeviceType.Wifi)
                return device;
        }

        return null;
    }

    readonly property WifiNetwork activeWifi: {
        if (root.wifiDevice === null)
            return null;

        for (const network of root.wifiDevice.networks.values) {
            if (network.connected)
                return network;
        }

        return null;
    }

    // Connected first, then saved, then by signal. ScriptModel keeps delegates
    // (and their expanded/password state) across rescans.
    readonly property ScriptModel networks: ScriptModel {
        values: [...(root.wifiDevice?.networks.values ?? [])].filter(network => network.name).sort((a, b) => (b.connected - a.connected) || (b.known - a.known) || (b.signalStrength - a.signalStrength))
    }

    // Scan only while someone is looking at the list.
    property bool scanning: false
    onScanningChanged: if (wifiDevice)
        wifiDevice.scannerEnabled = scanning

    function setWifiEnabled(value: bool): void {
        Networking.wifiEnabled = value;
    }

    function signalIcon(strength: real): string {
        return ["network_wifi_1_bar", "network_wifi_2_bar", "network_wifi_3_bar", "network_wifi"][Math.min(3, Math.floor(strength * 4))];
    }
}
