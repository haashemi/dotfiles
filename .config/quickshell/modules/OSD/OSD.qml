import QtQuick
import QtQuick.Effects
import Quickshell
import Quickshell.Wayland
import Quickshell.Widgets

import "./services"

Scope {
    id: root

    property bool initialized: false
    property bool shouldShowOsd: false
    property bool shouldShrinkOsd: false

    Brightness {
        id: brightness
        onLevelChanged: root.showOsd("brightness")
    }
    KeyboardBacklight {
        id: keyboardBacklight
        onLevelChanged: root.showOsd("keyboard-backlight")
    }
    Volume {
        id: volume
        onLevelChanged: root.showOsd("volume")
    }

    property string activeOsd: "volume"
    property int level: getLevel(activeOsd)

    PanelWindow {
        id: panel
        anchors.right: true
        margins.right: 20
        exclusiveZone: 0

        implicitWidth: 50
        implicitHeight: 250
        color: "transparent"

        WlrLayershell.layer: WlrLayer.Overlay

        ClippingRectangle {
            id: rect
            anchors.fill: parent
            color: '#cc323232'
            radius: height / 2
            transform: Scale {
                origin.x: panel.width / 2
                origin.y: panel.height / 2
                xScale: root.shouldShowOsd ? root.shouldShrinkOsd ? 0.96 : 1 : 0
                yScale: root.shouldShowOsd ? root.shouldShrinkOsd ? 0.98 : 1 : 0

                Behavior on xScale {
                    NumberAnimation {
                        duration: 300
                        easing.type: Easing.OutQuart
                    }
                }
                Behavior on yScale {
                    NumberAnimation {
                        duration: 300
                        easing.type: Easing.OutQuart
                    }
                }
            }

            Rectangle {
                anchors {
                    left: parent.left
                    right: parent.right
                    bottom: parent.bottom
                }
                gradient: Gradient {
                    GradientStop {
                        position: 0.0
                        color: "#F9F8FE"
                    }
                    GradientStop {
                        position: 1.0
                        color: root.level === 100 ? "#F9F8FE" : '#908F94'
                        Behavior on color {
                            ColorAnimation {
                                duration: 300
                            }
                        }
                    }
                }

                height: parent.height / 100 * root.level
                width: parent.width
                radius: parent.width / 2
                Behavior on height {
                    NumberAnimation {
                        duration: 500
                        easing.type: Easing.OutExpo
                    }
                }
            }

            IconImage {
                implicitSize: 25
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 12
                anchors.horizontalCenter: parent.horizontalCenter
                source: Quickshell.iconPath(root.getIconPath(root.activeOsd))
                layer.enabled: true
                layer.effect: MultiEffect {
                    colorization: 1
                    colorizationColor: "black"
                }
            }
        }
    }

    Timer {
        id: hideOsdTimer
        interval: 2000
        running: root.shouldShowOsd
        onTriggered: root.shouldShowOsd = false
    }

    Timer {
        id: expandOsdTimer
        interval: 500
        running: root.shouldShrinkOsd
        onTriggered: root.shouldShrinkOsd = false
    }

    function getLevel(activeOsd: string): string {
        switch (activeOsd) {
        case "brightness":
            return brightness.level;
        case "keyboard-backlight":
            return keyboardBacklight.level;
        case "volume":
            return volume.level;
        }
    }

    function getIconPath(activeOsd: string): string {
        switch (activeOsd) {
        case "brightness":
            return "display-brightness-symbolic";
        case "keyboard-backlight":
            return "keyboard-brightness-symbolic";
        case "volume":
            return root.level === 0 ? "audio-volume-muted-symbolic" : root.level <= 35 ? "audio-volume-low-symbolic" : root.level <= 65 ? "audio-volume-medium-symbolic" : "audio-volume-high-symbolic";
        }
    }

    function showOsd(osdType: string) {
        activeOsd = osdType;

        if (root.shouldShowOsd) {
            root.shouldShrinkOsd = true;
            expandOsdTimer.restart();
        }
        root.shouldShowOsd = true;
        hideOsdTimer.restart();
    }
}
