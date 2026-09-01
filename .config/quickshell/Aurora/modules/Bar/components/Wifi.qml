import QtQuick
import qs.config
import qs.components
import qs.services

MaterialSymbol {
    id: root
    required property SNetwork network

    size: 16
    color: Appearance.text
    opacity: root.network.wifiEnabled ? 1 : 0.4

    name: {
        if (!root.network.wifiEnabled)
            return "wifi_off";
        if (root.network.wifiConnected)
            return ["wifi_1_bar", "wifi_2_bar", "wifi"][Math.round(root.network.wifiStrength * 2)];
        return "wifi";
    }

    Behavior on opacity {
        NumberAnimation {
            duration: Appearance.animationDuration
            easing.type: Easing.OutQuint
        }
    }
}
