pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import QtQuick.Effects
import Quickshell
import Quickshell.Wayland
import Quickshell.Widgets
import Quickshell.Services.Mpris
import qs.config
import qs.components

// Android 16 media card under the bar. Toggled from the bar pill; closes a
// second after the pointer leaves it.
Scope {
    id: root

    required property MprisPlayer player
    property bool open: false
    property real progress: open ? 1 : 0

    Behavior on progress {
        NumberAnimation {
            duration: root.open ? 300 : 180
            easing.type: root.open ? Easing.OutCubic : Easing.InCubic
        }
    }

    onOpenChanged: if (open)
        closeTimer.restart()

    Timer {
        id: closeTimer
        interval: 1000
        onTriggered: root.open = false
    }

    // MPRIS doesn't push position updates; poll while it's on screen.
    Timer {
        interval: 1000
        repeat: true
        running: root.open && root.player.isPlaying
        onTriggered: root.player.positionChanged()
    }

    PanelWindow {
        visible: root.progress > 0
        anchors.top: true
        anchors.left: true
        margins.top: 8
        margins.left: 8
        exclusiveZone: 0
        implicitWidth: card.width
        implicitHeight: card.height
        color: "transparent"
        WlrLayershell.namespace: "aurora-media"
        mask: Region {
            item: card
        }
        BackgroundEffect.blurRegion: Region {
            item: card
            radius: card.radius
        }

        ClippingRectangle {
            id: card
            width: 400
            height: 152
            radius: 28
            color: Qt.alpha(Appearance.surfaceContainer, 0.75)
            y: (1 - root.progress) * -16
            opacity: root.progress

            HoverHandler {
                onHoveredChanged: hovered ? closeTimer.stop() : closeTimer.restart()
            }

            // Album art backdrop, blurred and scrimmed so text stays readable.
            Image {
                anchors.fill: parent
                visible: status === Image.Ready
                source: root.player.trackArtUrl
                fillMode: Image.PreserveAspectCrop
                sourceSize: Qt.size(400, 400)
                layer.enabled: visible
                layer.effect: MultiEffect {
                    autoPaddingEnabled: false
                    blurEnabled: true
                    blur: 1
                    blurMax: 48
                }
            }

            Rectangle {
                anchors.fill: parent
                color: Qt.alpha(Appearance.surface, 0.55)
            }

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 20
                spacing: 12

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 16

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 0

                        Text {
                            Layout.fillWidth: true
                            text: root.player.identity
                            elide: Text.ElideRight
                            color: Appearance.textOnSurfaceVariant
                            font.family: Appearance.fontUi
                            font.pixelSize: 12
                        }

                        Text {
                            Layout.fillWidth: true
                            text: root.player.trackTitle
                            elide: Text.ElideRight
                            color: Appearance.textOnSurface
                            font.family: Appearance.fontUi
                            font.pixelSize: 18
                            font.weight: Font.DemiBold
                        }

                        Text {
                            Layout.fillWidth: true
                            text: root.player.trackArtist
                            visible: text !== ""
                            elide: Text.ElideRight
                            color: Appearance.textOnSurfaceVariant
                            font.family: Appearance.fontUi
                            font.pixelSize: 14
                        }
                    }

                    // Morphs circle (paused) <-> rounded square (playing), like Android 16.
                    Rectangle {
                        implicitWidth: 56
                        implicitHeight: 56
                        radius: root.player.isPlaying ? 16 : 28
                        color: Appearance.primary
                        opacity: root.player.canTogglePlaying ? 1 : 0.38

                        Behavior on radius {
                            NumberAnimation {
                                duration: 250
                                easing.type: Easing.OutBack
                            }
                        }

                        MaterialSymbol {
                            anchors.centerIn: parent
                            name: root.player.isPlaying ? "pause" : "play_arrow"
                            size: 28
                            fill: true
                            color: Appearance.textOnPrimary
                        }

                        MouseArea {
                            anchors.fill: parent
                            enabled: root.player.canTogglePlaying
                            cursorShape: Qt.PointingHandCursor
                            onClicked: root.player.togglePlaying()
                        }
                    }
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 8

                    MediaButton {
                        icon: "skip_previous"
                        enabled: root.player.canGoPrevious
                        onClicked: root.player.previous()
                    }

                    // M3 expressive track: active | gap | handle | gap | inactive.
                    Item {
                        id: seek
                        Layout.fillWidth: true
                        implicitHeight: 24

                        property real dragValue: -1
                        readonly property real value: dragValue >= 0 ? dragValue : root.player.length > 0 ? Math.min(1, root.player.position / root.player.length) : 0
                        readonly property real handleX: value * (width - 4)

                        Rectangle {
                            anchors.verticalCenter: parent.verticalCenter
                            width: Math.max(0, seek.handleX - 4)
                            height: 6
                            radius: 3
                            color: Appearance.primary
                        }

                        Rectangle {
                            x: seek.handleX
                            anchors.verticalCenter: parent.verticalCenter
                            width: 4
                            height: 20
                            radius: 2
                            color: Appearance.primary
                        }

                        Rectangle {
                            x: seek.handleX + 8
                            anchors.verticalCenter: parent.verticalCenter
                            width: Math.max(0, seek.width - x)
                            height: 6
                            radius: 3
                            color: Qt.alpha(Appearance.textOnSurface, 0.3)
                        }

                        MouseArea {
                            anchors.fill: parent
                            enabled: root.player.canSeek && root.player.length > 0
                            cursorShape: Qt.PointingHandCursor
                            onPressed: mouse => seek.dragValue = Math.max(0, Math.min(1, mouse.x / width))
                            onPositionChanged: mouse => seek.dragValue = Math.max(0, Math.min(1, mouse.x / width))
                            onReleased: {
                                root.player.position = seek.dragValue * root.player.length;
                                seek.dragValue = -1;
                            }
                        }
                    }

                    MediaButton {
                        icon: "skip_next"
                        enabled: root.player.canGoNext
                        onClicked: root.player.next()
                    }
                }
            }
        }
    }

    component MediaButton: MaterialSymbol {
        id: button
        signal clicked

        property string icon
        name: icon
        size: 24
        fill: true
        color: Appearance.textOnSurface
        opacity: enabled ? 1 : 0.38

        MouseArea {
            anchors.fill: parent
            anchors.margins: -8
            cursorShape: Qt.PointingHandCursor
            onClicked: button.clicked()
        }
    }
}
