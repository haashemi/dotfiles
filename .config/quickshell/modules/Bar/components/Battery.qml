import QtQuick
import Quickshell.Services.UPower
import Quickshell.Widgets

ClippingRectangle {
    id: root
    color: "#a1a1a1"
    radius: height / 2
    implicitWidth: batteryText.implicitWidth + 20
    implicitHeight: 20

    property int batteryLevel: Math.round(UPower.displayDevice.percentage * 100)
    property bool isCharging: [UPowerDeviceState.Charging, UPowerDeviceState.FullyCharged].includes(UPower.displayDevice.state)

    property bool colorsSwitched: false
    property color colorStep1: isCharging ? "#73FAE9" : batteryLevel <= 20 ? "#ff4d4d" : "#F1F1F1"
    property color colorStep2: isCharging ? "#4494ea" : batteryLevel <= 20 ? "#ff4d4d" : "#F1F1F1"

    Rectangle {
        id: filling
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        implicitWidth: parent.width / 100 * root.batteryLevel
        gradient: Gradient {
            orientation: Gradient.Horizontal
            GradientStop {
                position: 0.0
                color: root.colorsSwitched ? root.colorStep2 : root.colorStep1

                Behavior on color {
                    ColorAnimation {
                        duration: 1000
                    }
                }
            }
            GradientStop {
                position: 1.0
                color: root.colorsSwitched ? root.colorStep1 : root.colorStep2

                Behavior on color {
                    ColorAnimation {
                        duration: 1000
                    }
                }
            }
        }
    }

    Text {
        id: batteryText
        anchors.centerIn: parent
        text: `${root.isCharging ? "🗲 " : ""}${root.batteryLevel}`
        color: "black"
        font.bold: true
    }

    Behavior on implicitWidth {
        NumberAnimation {
            duration: 1000
            easing.type: Easing.OutExpo
        }
    }

    Timer {
        interval: 1000
        running: root.isCharging
        repeat: true
        onTriggered: root.colorsSwitched = root.isCharging ? !root.colorsSwitched : false
    }
}
