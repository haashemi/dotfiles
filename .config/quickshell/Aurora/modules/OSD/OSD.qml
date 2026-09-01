import QtQuick
import QtQuick.Controls.Material
import Quickshell
import Quickshell.Widgets
import qs.services
import qs.config
import qs.modules.OSD.components

Scope {
    id: root

    SBrightness {
        id: brightness
    }
    SKeyboardBacklight {
        id: keyboardBacklight
    }
    SVolume {
        id: volume
    }

    readonly property bool isVisible: activeDevice !== 0
    property int activeDevice: 0
    property string activeIcon: "volume_up"
    property real activeLevel: 0

    readonly property int margin: 15

    Connections {
        target: volume
        function onLevelChanged() {
            root.activeDevice = 1;
            root.activeIcon = root.volumeIcon(volume.level);
            root.activeLevel = volume.level / 100;
            root.restart();
        }
    }

    Connections {
        target: brightness
        function onLevelChanged() {
            root.activeDevice = 2;
            root.activeIcon = root.brightnessIcon(brightness.level);
            root.activeLevel = brightness.level / 100;
            root.restart();
        }
    }

    Connections {
        target: keyboardBacklight
        function onLevelChanged() {
            root.activeDevice = 3;
            root.activeIcon = root.keyboardBacklightIcon(keyboardBacklight.level);
            root.activeLevel = keyboardBacklight.level / 100;
            root.restart();
        }
    }

    Timer {
        id: autohideTimer
        interval: 1000
        onTriggered: root.activeDevice = 0
    }

    Timer {
        id: showTimer
        interval: 0
        running: root.isVisible
        onTriggered: loader.active = true
    }

    Timer {
        id: destroyTimer
        interval: 500
        running: !root.isVisible
        onTriggered: loader.active = false
    }

    function restart(): void {
        autohideTimer.restart();
    }

    function volumeIcon(level: int): string {
        if (level === 0)
            return "no_sound";
        if (level <= 35)
            return "volume_mute";
        if (level <= 65)
            return "volume_down";
        return "volume_up";
    }

    function brightnessIcon(level: int): string {
        if (level === 0)
            return "brightness_1";
        if (level <= 20)
            return "brightness_2";
        if (level <= 40)
            return "brightness_3";
        if (level <= 60)
            return "brightness_4";
        if (level <= 80)
            return "brightness_5";
        if (level <= 99)
            return "brightness_6";
        return "brightness_7";
    }

    function keyboardBacklightIcon(level: int): string {
        if (level === 0)
            return "backlight_high_off";
        if (level === 100)
            return "backlight_high";
        return "backlight_low";
    }

    LazyLoader {
        id: loader

        PanelWindow {
            id: panel
            color: "transparent"
            exclusiveZone: 0
            mask: Region {}
            anchors {
                right: true
                top: true
                bottom: true
            }
            margins {
                right: root.margin
                top: root.margin
                bottom: root.margin
            }
            implicitWidth: pill.implicitWidth
            implicitHeight: pill.implicitHeight

            Material.theme: Material.Dark
            Material.background: Appearance.background
            Material.primary: Appearance.primary
            Material.accent: Appearance.accent

            property bool viewPanel: false

            Timer {
                interval: 0
                running: loader.active
                onTriggered: panel.viewPanel = true
            }

            Connections {
                target: root
                function onIsVisibleChanged() {
                    panel.viewPanel = root.isVisible
                }
            }

            Rectangle {
                id: pill
                x: 0
                y: (parent.height - height) / 2
                implicitWidth: content.implicitWidth
                implicitHeight: content.implicitHeight
                radius: Math.min(width, height) / 2
                color: "#c0000000"
                opacity: 0.8

                Component.onCompleted: pill.x = panel.implicitWidth + root.margin + 20

                NumberAnimation {
                    running: panel.viewPanel
                    target: pill
                    property: "x"
                    from: panel.implicitWidth + root.margin + 20
                    to: 0
                    duration: Appearance.animationDuration
                    easing.type: Easing.OutQuint
                }
                NumberAnimation {
                    running: !panel.viewPanel
                    target: pill
                    property: "x"
                    from: 0
                    to: panel.implicitWidth + root.margin + 20
                    duration: 200
                    easing.type: Easing.OutQuint
                }
                NumberAnimation {
                    running: panel.viewPanel
                    target: pill
                    property: "opacity"
                    from: 0.8
                    to: 1.0
                    duration: Appearance.animationDuration
                    easing.type: Easing.OutQuint
                }
                NumberAnimation {
                    running: !panel.viewPanel
                    target: pill
                    property: "opacity"
                    from: 1.0
                    to: 0.8
                    duration: 200
                    easing.type: Easing.OutQuint
                }

                OSDItem {
                    id: content
                    anchors.centerIn: parent
                    icon: root.activeIcon
                    level: root.activeLevel
                }
            }
        }
    }
}