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

    MaterialSymbol {
        anchors.verticalCenter: parent.verticalCenter
        size: 16
        color: root.batteryColor
        name: SBattery.icon

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
