import QtQuick
import qs.config
import qs.components
import qs.services

MaterialSymbol {
    size: 16
    visible: SBluetooth.enabled
    color: SBluetooth.connectedDevices > 0 ? Appearance.primary : Appearance.textOnSurface
    name: SBluetooth.connectedDevices > 0 ? "bluetooth_connected" : "bluetooth"

    Behavior on color {
        ColorAnimation {
            duration: Appearance.animationDuration
        }
    }
}
