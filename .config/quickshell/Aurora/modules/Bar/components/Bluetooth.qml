import QtQuick
import qs.config
import qs.components
import qs.services

MaterialSymbol {
    id: root
    required property SBluetooth bluetooth

    size: 16
    visible: root.bluetooth.enabled
    color: root.bluetooth.connectedDevices > 0 ? Appearance.accent : Appearance.text
    name: "bluetooth"

    Behavior on color {
        ColorAnimation {
            duration: Appearance.animationDuration
        }
    }
}