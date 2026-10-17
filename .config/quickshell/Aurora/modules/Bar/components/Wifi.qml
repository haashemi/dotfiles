import QtQuick
import qs.config
import qs.components
import qs.services

MaterialSymbol {
    size: 16
    color: Appearance.textOnSurface
    opacity: SNetwork.wifiEnabled ? 1 : 0.38

    name: {
        if (!SNetwork.wifiEnabled)
            return "wifi_off";
        if (SNetwork.wifiConnected)
            return ["wifi_1_bar", "wifi_2_bar", "wifi"][Math.round(SNetwork.wifiStrength * 2)];
        return "wifi";
    }

    Behavior on opacity {
        NumberAnimation {
            duration: Appearance.animationDuration
            easing.type: Easing.OutCubic
        }
    }
}
