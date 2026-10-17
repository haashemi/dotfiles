import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import qs.services
import qs.config
import qs.modules.OSD.components

// Android 16/17 expressive volume dialog: blurred pill docked to the right edge.
// Pops on S*.adjusted (real changes from any source), never on startup.
Scope {
    id: root

    property string kind: "volume" // volume | brightness | keyboard
    property bool shown: false
    property real progress: shown ? 1 : 0

    readonly property int margin: 12

    Behavior on progress {
        NumberAnimation {
            duration: root.shown ? 350 : 200
            easing.type: root.shown ? Easing.OutCubic : Easing.InCubic
        }
    }

    Connections {
        target: SVolume
        function onAdjusted() {
            root.show("volume");
        }
    }

    Connections {
        target: SBrightness
        function onAdjusted() {
            root.show("brightness");
        }
    }

    Connections {
        target: SKeyboardBacklight
        function onAdjusted() {
            root.show("keyboard");
        }
    }

    // Android's volume dialog timeout.
    Timer {
        id: hideTimer
        interval: 3000
        onTriggered: root.shown = false
    }

    // Quick Settings has the same sliders; don't stack the OSD on top of it.
    Connections {
        target: SPanels
        function onQuickSettingsChanged() {
            if (SPanels.quickSettings)
                root.shown = false;
        }
    }

    function show(kind: string): void {
        if (SPanels.quickSettings)
            return;
        root.kind = kind;
        root.shown = true;
        if (!hover.hovered)
            hideTimer.restart();
    }

    PanelWindow {
        visible: root.progress > 0
        anchors.right: true
        implicitWidth: dialog.width + root.margin
        implicitHeight: dialog.height
        color: "transparent"
        exclusionMode: ExclusionMode.Ignore
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.namespace: "aurora-osd"
        mask: Region {
            item: dialog
        }
        BackgroundEffect.blurRegion: Region {
            item: dialog
            radius: dialog.radius
        }

        Rectangle {
            id: dialog
            x: (1 - root.progress) * (width + root.margin)
            opacity: root.progress
            width: 60
            height: column.implicitHeight + 20
            // Pill when there are buttons; otherwise concentric with the slider.
            radius: root.kind === "volume" ? width / 2 : slider.outerRadius + column.anchors.margins
            color: Qt.alpha(Appearance.surfaceContainer, 0.6)

            Behavior on radius {
                NumberAnimation {
                    duration: 200
                    easing.type: Easing.OutCubic
                }
            }

            HoverHandler {
                id: hover
                onHoveredChanged: hovered ? hideTimer.stop() : hideTimer.restart()
            }

            ColumnLayout {
                id: column
                anchors.fill: parent
                anchors.margins: 10
                spacing: 10

                OSDButton {
                    visible: root.kind === "volume"
                    radius: width / 2
                    color: Appearance.primary
                    icon: SVolume.muted ? "volume_off" : "volume_up"
                    onClicked: SVolume.setMuted(!SVolume.muted)
                }

                OSDSlider {
                    id: slider
                    steps: root.kind === "keyboard" ? SKeyboardBacklight.maxBrightness : 0
                    value: {
                        if (root.kind === "brightness")
                            return SBrightness.level / 100;
                        if (root.kind === "keyboard")
                            return SKeyboardBacklight.level / 100;
                        return SVolume.muted ? 0 : SVolume.volume;
                    }
                    icon: {
                        if (root.kind === "brightness")
                            return SBrightness.icon;
                        if (root.kind === "keyboard")
                            return SKeyboardBacklight.icon;
                        return SVolume.muted ? "music_off" : "music_note";
                    }
                    onMoved: value => {
                        if (root.kind === "brightness")
                            SBrightness.setLevel(value);
                        else if (root.kind === "keyboard")
                            SKeyboardBacklight.setLevel(value);
                        else {
                            if (SVolume.muted)
                                SVolume.setMuted(false);
                            SVolume.setVolume(value);
                        }
                    }
                }

                // Stands in for Android's live-caption toggle.
                OSDButton {
                    visible: root.kind === "volume"
                    color: SVolume.micMuted ? Appearance.primary : Appearance.textOnPrimary
                    iconColor: SVolume.micMuted ? Appearance.textOnPrimary : Appearance.textOnPrimaryContainer
                    icon: SVolume.micMuted ? "mic_off" : "mic"
                    onClicked: SVolume.toggleMic()
                }
            }
        }
    }
}
