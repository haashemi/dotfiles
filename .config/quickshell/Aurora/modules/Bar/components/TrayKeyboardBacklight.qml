import QtQuick
import "../../../config"
import "../../../services"
import "../../../components"

Rectangle {
    id: root
    implicitWidth: content.width + 20
    color: Appearance.background

    required property SKeyboardBacklight keyboardBacklight

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
            name: root.keyboardBacklight === 0 ? "backlight_high_off"//
            : root.keyboardBacklight === 100 ? "backlight_high" //
            : "backlight_low"
            size: 15
            color: Appearance.text
        }
        Text {
            anchors.verticalCenter: parent.verticalCenter
            text: `${root.keyboardBacklight.level}%`
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
        target: root.keyboardBacklight

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
