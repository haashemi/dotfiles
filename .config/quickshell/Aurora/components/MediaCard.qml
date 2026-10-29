pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import QtQuick.Shapes
import Quickshell
import Quickshell.Widgets
import Quickshell.Services.Mpris
import qs.config
import qs.services

// Android 16 media player: album art backdrop, app icon + output chip,
// title/artist with a big play button, wavy progress, shuffle/repeat, and
// page dots + arrows to flip between players.
ClippingRectangle {
    id: root

    required property var players // list<MprisPlayer>
    // Bind to the card's on-screen state; drives the wave animation and position polling.
    property bool active: true
    property int index: 0
    readonly property MprisPlayer player: players[Math.min(index, players.length - 1)] ?? null
    readonly property bool paged: players.length > 1

    implicitWidth: 368
    implicitHeight: 176
    radius: 28
    color: Appearance.surfaceContainerHigh

    onPlayersChanged: index = Math.min(index, Math.max(0, players.length - 1))

    // MPRIS doesn't push position updates; poll while visible and playing.
    Timer {
        interval: 1000
        repeat: true
        running: root.active && (root.player?.isPlaying ?? false)
        onTriggered: root.player.positionChanged()
    }

    Image {
        anchors.fill: parent
        visible: status === Image.Ready
        source: root.player?.trackArtUrl ?? ""
        fillMode: Image.PreserveAspectCrop
        sourceSize: Qt.size(root.width, root.width)
        asynchronous: true
    }

    Rectangle {
        anchors.fill: parent
        gradient: Gradient {
            orientation: Gradient.Horizontal
            GradientStop {
                position: 0
                color: Qt.alpha(Appearance.surface, 0.75)
            }
            GradientStop {
                position: 1
                color: Qt.alpha(Appearance.surface, 0.45)
            }
        }
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 16
        anchors.bottomMargin: root.paged ? 8 : 12
        spacing: 0

        // App icon + output device chip.
        RowLayout {
            Layout.fillWidth: true

            ClippingRectangle {
                id: appBadge
                implicitWidth: 28
                implicitHeight: 28
                radius: 14
                color: Appearance.textOnPrimaryContainer

                readonly property string appIcon: Quickshell.iconPath(DesktopEntries.byId(root.player?.desktopEntry ?? "")?.icon ?? "", true)

                IconImage {
                    anchors.fill: parent
                    visible: source != ""
                    source: appBadge.appIcon
                }

                MaterialSymbol {
                    anchors.centerIn: parent
                    visible: !appBadge.appIcon
                    name: "music_note"
                    size: 16
                    fill: true
                    color: Appearance.textOnPrimary
                }
            }

            Item {
                Layout.fillWidth: true
            }

            Rectangle {
                id: outputChip
                readonly property string output: SVolume.sink?.description || "Speakers"

                implicitWidth: Math.min(180, chip.implicitWidth + 24)
                implicitHeight: 28
                radius: 14
                color: Appearance.textOnPrimaryContainer

                Row {
                    id: chip
                    anchors.centerIn: parent
                    width: Math.min(implicitWidth, parent.width - 24)
                    spacing: 6

                    MaterialSymbol {
                        anchors.verticalCenter: parent.verticalCenter
                        name: /head|buds|pods/i.test(outputChip.output) ? "headphones" : "speaker"
                        size: 16
                        fill: true
                        color: Appearance.textOnPrimary
                    }

                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        width: Math.min(implicitWidth, 180 - 24 - 22)
                        text: outputChip.output
                        elide: Text.ElideRight
                        color: Appearance.textOnPrimary
                        font.family: Appearance.fontUi
                        font.pixelSize: 12
                        font.weight: Font.Medium
                    }
                }
            }
        }

        Item {
            Layout.fillHeight: true
        }

        // Title/artist + play button, with player arrows when there are several.
        RowLayout {
            Layout.fillWidth: true
            spacing: 8

            TransportButton {
                visible: root.paged
                icon: "chevron_left"
                enabled: root.index > 0
                onClicked: root.index--
            }

            ColumnLayout {
                Layout.fillWidth: true
                Layout.leftMargin: root.paged ? 0 : 4
                spacing: 0

                Text {
                    Layout.fillWidth: true
                    text: root.player?.trackTitle ?? ""
                    elide: Text.ElideRight
                    color: Appearance.textOnSurface
                    font.family: Appearance.fontUi
                    font.pixelSize: 18
                    font.weight: Font.Medium
                }

                Text {
                    Layout.fillWidth: true
                    text: root.player?.trackArtist ?? ""
                    visible: text !== ""
                    elide: Text.ElideRight
                    color: Appearance.textOnSurfaceVariant
                    font.family: Appearance.fontUi
                    font.pixelSize: 14
                }
            }

            // Morphs rounded square (playing) <-> pill (paused).
            Rectangle {
                implicitWidth: 64
                implicitHeight: 44
                radius: root.player?.isPlaying ? 16 : 22
                color: Appearance.textOnPrimaryContainer
                opacity: root.player?.canTogglePlaying ? 1 : 0.38

                Behavior on radius {
                    NumberAnimation {
                        duration: 250
                        easing.type: Easing.OutBack
                    }
                }

                MaterialSymbol {
                    anchors.centerIn: parent
                    name: root.player?.isPlaying ? "pause" : "play_arrow"
                    size: 26
                    fill: true
                    color: Appearance.textOnPrimary
                }

                MouseArea {
                    anchors.fill: parent
                    enabled: root.player?.canTogglePlaying ?? false
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.player.togglePlaying()
                }
            }

            TransportButton {
                visible: root.paged
                icon: "chevron_right"
                enabled: root.index < root.players.length - 1
                onClicked: root.index++
            }
        }

        Item {
            Layout.fillHeight: true
        }

        // Transport row.
        RowLayout {
            Layout.fillWidth: true
            spacing: 4

            TransportButton {
                icon: "skip_previous"
                enabled: root.player?.canGoPrevious ?? false
                onClicked: root.player.previous()
            }

            WavyProgress {
                Layout.fillWidth: true
                Layout.leftMargin: 4
                Layout.rightMargin: 4
            }

            TransportButton {
                icon: "skip_next"
                enabled: root.player?.canGoNext ?? false
                onClicked: root.player.next()
            }

            TransportButton {
                visible: root.player?.shuffleSupported ?? false
                icon: "shuffle"
                dimmed: !root.player?.shuffle
                onClicked: root.player.shuffle = !root.player.shuffle
            }

            TransportButton {
                visible: root.player?.loopSupported ?? false
                icon: root.player?.loopState === MprisLoopState.Track ? "repeat_one" : "repeat"
                dimmed: root.player?.loopState === MprisLoopState.None
                onClicked: {
                    const order = [MprisLoopState.None, MprisLoopState.Playlist, MprisLoopState.Track];
                    root.player.loopState = order[(order.indexOf(root.player.loopState) + 1) % order.length];
                }
            }
        }

        Row {
            Layout.alignment: Qt.AlignHCenter
            Layout.topMargin: 6
            visible: root.paged
            spacing: 6

            Repeater {
                model: root.players.length

                Rectangle {
                    required property int index
                    width: 6
                    height: 6
                    radius: 3
                    color: Appearance.textOnSurface
                    opacity: index === root.index ? 1 : 0.4
                }
            }
        }
    }

    // Wave over the played part (flattens when paused), tall handle, flat line for the rest.
    component WavyProgress: Item {
        id: seek

        property real dragValue: -1
        readonly property real length: root.player?.length ?? 0
        readonly property real value: dragValue >= 0 ? dragValue : length > 0 ? Math.min(1, (root.player?.position ?? 0) / length) : 0
        readonly property real handleX: value * (width - 4)
        readonly property int wavelength: 20
        property real phase: 0
        property real amplitude: root.player?.isPlaying ? 3 : 0

        implicitHeight: 28

        Behavior on amplitude {
            NumberAnimation {
                duration: 300
            }
        }

        FrameAnimation {
            running: root.active && seek.amplitude > 0
            onTriggered: seek.phase = (seek.phase + frameTime * 2 * Math.PI) % (2 * Math.PI)
        }

        Shape {
            anchors.fill: parent
            preferredRendererType: Shape.CurveRenderer

            ShapePath {
                strokeColor: Appearance.textOnSurface
                strokeWidth: 3
                fillColor: "transparent"
                capStyle: ShapePath.RoundCap
                joinStyle: ShapePath.RoundJoin

                PathPolyline {
                    path: {
                        const points = [];
                        const end = seek.handleX - 6;
                        const mid = seek.height / 2;
                        for (let x = 2; x <= end; x += 2)
                            points.push(Qt.point(x, mid + seek.amplitude * Math.sin(2 * Math.PI * x / seek.wavelength - seek.phase)));
                        return points.length > 1 ? points : [Qt.point(0, mid), Qt.point(0, mid)];
                    }
                }
            }
        }

        Rectangle {
            x: seek.handleX
            anchors.verticalCenter: parent.verticalCenter
            width: 4
            height: 18
            radius: 2
            color: Appearance.textOnSurface
        }

        Rectangle {
            x: seek.handleX + 10
            anchors.verticalCenter: parent.verticalCenter
            width: Math.max(0, seek.width - x)
            height: 2
            radius: 1
            color: Qt.alpha(Appearance.textOnSurface, 0.4)
        }

        MouseArea {
            anchors.fill: parent
            enabled: (root.player?.canSeek ?? false) && seek.length > 0
            cursorShape: Qt.PointingHandCursor
            onPressed: mouse => seek.dragValue = Math.max(0, Math.min(1, mouse.x / width))
            onPositionChanged: mouse => seek.dragValue = Math.max(0, Math.min(1, mouse.x / width))
            onReleased: {
                root.player.position = seek.dragValue * seek.length;
                seek.dragValue = -1;
            }
        }
    }

    component TransportButton: Item {
        id: button

        required property string icon
        property bool dimmed: false
        signal clicked

        implicitWidth: 32
        implicitHeight: 32
        opacity: !enabled ? 0.3 : dimmed ? 0.5 : 1

        MaterialSymbol {
            anchors.centerIn: parent
            name: button.icon
            size: 24
            fill: true
            color: Appearance.textOnSurface
        }

        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: button.clicked()
        }
    }
}
