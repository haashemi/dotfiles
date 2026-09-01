import QtQuick
import Quickshell
import Quickshell.Networking

Scope {
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
}