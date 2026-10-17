import QtQuick
import Quickshell.Widgets
import Quickshell.Services.Mpris
import qs.config
import qs.components

// Bar pill for one player; click toggles its media card.
ClippingRectangle {
    id: root
    anchors.verticalCenter: parent.verticalCenter

    required property MprisPlayer player
    readonly property int maxWidth: 90
    readonly property int contentWidth: content.implicitWidth + 20

    color: Appearance.primaryContainer
    radius: height / 2
    implicitWidth: Math.min(maxWidth, contentWidth)
    implicitHeight: 20

    Behavior on implicitWidth {
        NumberAnimation {
            duration: Appearance.animationDuration
            easing.type: Easing.OutCubic
        }
    }

    MprisModal {
        id: card
        player: root.player
    }

    Row {
        id: content
        x: 8
        anchors.verticalCenter: parent.verticalCenter
        spacing: 4

        MaterialSymbol {
            anchors.verticalCenter: parent.verticalCenter
            name: root.player.isPlaying ? "music_note" : "pause"
            size: 14
            fill: true
            color: Appearance.textOnPrimaryContainer
        }

        Text {
            anchors.verticalCenter: parent.verticalCenter
            text: root.player.trackTitle
            color: Appearance.textOnPrimaryContainer
            font.family: Appearance.fontUi
            font.pixelSize: 13
        }
    }

    // Fade an overflowing title into the pill.
    Rectangle {
        visible: root.contentWidth > root.maxWidth
        anchors.right: parent.right
        width: 20
        height: parent.height
        gradient: Gradient {
            orientation: Gradient.Horizontal
            GradientStop {
                position: 0
                color: "transparent"
            }
            GradientStop {
                position: 0.7
                color: Appearance.primaryContainer
            }
        }
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: card.open = !card.open
    }
}
