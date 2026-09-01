import QtQuick
import Quickshell.Widgets
import Quickshell.Services.Mpris
import qs.config
import qs.components

ClippingRectangle {
    id: root
    anchors.verticalCenter: parent.verticalCenter
    color: getColor()
    radius: height / 2
    implicitWidth: root.exceededMaxWidth ? root.maxWidth : root.contentWidth
    implicitHeight: 20

    required property MprisPlayer player
    property int maxWidth: 90
    readonly property int contentWidth: content.implicitWidth + 25
    readonly property bool exceededMaxWidth: maxWidth <= contentWidth

    MprisModal {
        id: panel
        player: root.player
        showPanel: false
    }

    Row {
        id: content
        anchors.left: parent.left
        anchors.leftMargin: 10
        anchors.rightMargin: 15
        anchors.verticalCenter: parent.verticalCenter
        spacing: 5

        MaterialSymbol {
            id: musicIcon
            anchors.verticalCenter: parent.verticalCenter
            name: "music_note"
            size: 15
        }

        Text {
            id: musicTitle
            anchors.verticalCenter: parent.verticalCenter
            text: root.player.trackTitle
            color: "black"
            font.pixelSize: 14
        }
    }

    Rectangle {
        width: 20
        height: parent.height
        anchors.right: parent.right
        gradient: Gradient {
            orientation: Gradient.Horizontal
            GradientStop {
                position: 0
                color: 'transparent'
            }
            GradientStop {
                position: 0.7
                color: root.exceededMaxWidth ? root.getColor() : 'transparent'
            }
        }
    }

    Behavior on implicitWidth {
        NumberAnimation {
            duration: Appearance.animationDuration
            easing.type: Easing.OutQuint
        }
    }

    function getColor(): string {
        if (player.identity === "Spotify")
            return "#1DB954";

        return "white";
    }
}