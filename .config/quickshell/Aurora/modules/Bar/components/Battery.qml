import QtQuick
import qs.config
import qs.components
import qs.services

Row {
    id: root
    visible: SBattery.present
    spacing: 3

    readonly property color batteryColor: {
        if (SBattery.isCharging)
            return Appearance.primary;
        if (SBattery.level <= 20)
            return Appearance.error;
        return Appearance.textOnSurface;
    }

    readonly property string batteryIcon: {
        const level = SBattery.level;
        if (level >= 95)
            return "battery_full";
        if (level >= 80)
            return "battery_6_bar";
        if (level >= 65)
            return "battery_5_bar";
        if (level >= 50)
            return "battery_4_bar";
        if (level >= 35)
            return "battery_3_bar";
        if (level >= 20)
            return "battery_2_bar";
        if (level >= 10)
            return "battery_1_bar";
        return "battery_0_bar";
    }

    MaterialSymbol {
        anchors.verticalCenter: parent.verticalCenter
        size: 16
        color: root.batteryColor
        name: SBattery.isCharging ? "battery_charging_full" : root.batteryIcon

        Behavior on color {
            ColorAnimation {
                duration: Appearance.animationDuration
            }
        }
    }

    Text {
        anchors.verticalCenter: parent.verticalCenter
        text: `${SBattery.level}%`
        color: root.batteryColor
        font.pixelSize: 12
        font.family: Appearance.fontUi
        font.features: { "tnum": 1 }
        font.bold: true
    }
}
