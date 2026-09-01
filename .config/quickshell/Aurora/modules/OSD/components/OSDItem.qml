import QtQuick
import QtQuick.Controls
import qs.config
import qs.components

Item {
    id: root

    required property string icon
    required property real level

    readonly property int iconSize: 26
    readonly property int sliderWidth: 26
    readonly property int sliderHeight: 120
    readonly property int padding: 12

    implicitWidth: Math.max(iconSize, sliderWidth) + padding * 2
    implicitHeight: iconSize / 2 + sliderHeight + padding * 2

    MaterialSymbol {
        id: icon
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: parent.padding
        name: root.icon
        size: parent.iconSize
        color: Appearance.text

        onNameChanged: iconPop.restart()

        SequentialAnimation {
            id: iconPop
            NumberAnimation {
                target: icon
                property: "scale"
                to: 1.15
                duration: 120
                easing.type: Easing.OutQuint
            }
            NumberAnimation {
                target: icon
                property: "scale"
                to: 1.0
                duration: 160
                easing.type: Easing.OutQuint
            }
        }
    }

    Slider {
        id: slider
        orientation: Qt.Vertical
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: icon.verticalCenter
        width: parent.sliderWidth
        height: parent.sliderHeight
        padding: 6
        from: 0
        to: 1
        value: root.level

        background: Item {
            anchors.fill: parent

            Rectangle {
                id: track
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                width: 6
                radius: width / 2
                color: "#50ffffff"

                Rectangle {
                    anchors.bottom: parent.bottom
                    anchors.left: parent.left
                    anchors.right: parent.right
                    height: parent.height * slider.position
                    radius: parent.radius
                    color: Appearance.accent
                }
            }
        }

        handle: Item {
            implicitWidth: 16
            implicitHeight: 16
            x: slider.leftPadding + (slider.availableWidth - width) / 2
            y: slider.topPadding + slider.visualPosition * (slider.availableHeight - height)

            Rectangle {
                anchors.centerIn: parent
                width: 26
                height: 26
                radius: width / 2
                color: "#1f31a4fd"
            }
            Rectangle {
                anchors.fill: parent
                radius: width / 2
                color: Appearance.accent
            }
        }
    }
}