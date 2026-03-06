import QtQuick
import Quickshell.Widgets
import "../../../services"

ClippingRectangle {
    id: root
    color: "#a1a1a1"
    radius: height / 2
    implicitWidth: batteryText.implicitWidth + 20
    implicitHeight: 20

    required property SBattery battery

    property bool colorsSwitched: false
    property color colorStep1: battery.isCharging ? "#73FAE9" : battery.level <= 20 ? "#ff4d4d" : "#F1F1F1"
    property color colorStep2: battery.isCharging ? "#4494ea" : battery.level <= 20 ? "#ff4d4d" : "#F1F1F1"

    Rectangle {
        id: filling
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        implicitWidth: parent.width / 100 * root.battery.level
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
        text: `${root.battery.isCharging ? "🗲 " : ""}${root.battery.level}`
        color: "black"
        font.bold: true
    }

    Behavior on implicitWidth {
        NumberAnimation {
            duration: 1000
            easing.type: Easing.OutQuint
        }
    }

    Timer {
        interval: 1000
        running: root.battery.isCharging
        repeat: true
        onTriggered: root.colorsSwitched = root.battery.isCharging ? !root.colorsSwitched : false
    }
}
