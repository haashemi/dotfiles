import QtQuick
import Quickshell.Widgets
import Quickshell.Services.Mpris
import "../../../components"

ClippingRectangle {
    id: root
    anchors.verticalCenter: parent.verticalCenter
    color: getColor()
    radius: height / 2
    implicitWidth: exceededMaxWidth ? maxWidth : contentWidth
    implicitHeight: 20

    required property MprisPlayer player
    property int maxWidth: 110
    property int contentWidth: 10 + musicIcon.width + 5 + musicTitle.width + 15
    property bool exceededMaxWidth: maxWidth <= contentWidth

    MprisModal {
        id: panel
        player: root.player
        showPanel: false
    }

    Row {
        id: content
        width: root.implicitWidth
        anchors.left: parent.left
        anchors.leftMargin: 10
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
            duration: 300
            easing.type: Easing.OutQuint
        }
    }

    function getColor(): string {
        if (player.identity === "Spotify")
            return "#1DB954";

        return "white";
    }
}
