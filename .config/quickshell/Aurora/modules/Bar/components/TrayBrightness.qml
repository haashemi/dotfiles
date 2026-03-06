import QtQuick
import "../../../config"
import "../../../services"
import "../../../components"

Rectangle {
    id: root
    implicitWidth: content.width + 20
    color: Appearance.background

    required property SBrightness brightness

    Rectangle {
        id: backgroundGradient
        opacity: 0
        anchors.fill: parent
        gradient: Gradient {
            GradientStop {
                position: 0.0
                color: "transparent"
            }
            GradientStop {
                position: 1.0
                color: Appearance.secondary
            }
        }
        Behavior on opacity {
            NumberAnimation {
                duration: 400
                easing.type: Easing.OutQuint
            }
        }
    }

    Row {
        id: content
        anchors.centerIn: parent
        spacing: 5
        MaterialSymbol {
            anchors.verticalCenter: parent.verticalCenter
            name: root.brightness === 0 ? "brightness_1" //
            : root.brightness <= 20 ? "brightness_2" //
            : root.brightness <= 40 ? "brightness_3" //
            : root.brightness <= 60 ? "brightness_4" //
            : root.brightness <= 80 ? "brightness_5" //
            : root.brightness <= 99 ? "brightness_6" //
            : "brightness_7"
            size: 15
            color: Appearance.text
        }
        Text {
            anchors.verticalCenter: parent.verticalCenter
            text: `${root.brightness.level}%`
            color: Appearance.text
            font.pixelSize: 12
        }
    }

    Timer {
        running: backgroundGradient.opacity === 1
        interval: 0
        onTriggered: backgroundGradient.opacity = 0
    }

    Connections {
        target: root.brightness

        function onLevelChanged() {
            backgroundGradient.opacity = 1;
        }
    }

    Behavior on implicitWidth {
        NumberAnimation {
            duration: 100
            easing.type: Easing.OutQuint
        }
    }
}
