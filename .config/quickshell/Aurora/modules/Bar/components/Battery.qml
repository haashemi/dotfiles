import QtQuick
import qs.config
import qs.components
import qs.services

Row {
    id: root
    spacing: 3

    required property SBattery battery

    readonly property color batteryColor: root.battery.isCharging
        ? "#73FAE9"
        : root.battery.level <= 20 ? "#ff4d4d" : Appearance.text

    readonly property string batteryIcon: {
        const level = root.battery.level;
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
        name: root.battery.isCharging ? "battery_charging_full" : root.batteryIcon

        Behavior on color {
            ColorAnimation {
                duration: 300
            }
        }
    }

    Text {
        anchors.verticalCenter: parent.verticalCenter
        text: `${root.battery.level}%`
        color: root.batteryColor
        font.pixelSize: 12
        font.family: Appearance.fontMono
        font.bold: true
    }
}