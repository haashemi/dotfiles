import QtQuick
import QtQuick.Effects
import QtQuick.Controls
import Quickshell
import Quickshell.Widgets
import Quickshell.Services.Mpris

AbstractButton {
    id: button
    required property MprisPlayer modelData

    contentItem: ClippingRectangle {
        id: root
        color: getColor()
        radius: height / 2
        implicitWidth: 15 + musicIcon.implicitWidth + musicTitle.implicitWidth + 15
        implicitHeight: 20

        property alias modelData: button.modelData

        MprisModal {
            id: panel
            player: button.modelData
            showPanel: false
        }

        Row {
            anchors.centerIn: parent
            spacing: 8
            IconImage {
                id: musicIcon
                implicitSize: 15
                anchors.verticalCenter: parent.verticalCenter
                source: Quickshell.iconPath(root.getIconPath())
                layer.enabled: true
                layer.effect: MultiEffect {
                    colorization: 1
                    colorizationColor: "black"
                }
            }

            Text {
                id: musicTitle
                anchors.verticalCenter: parent.verticalCenter
                text: root.modelData.trackTitle + " - " + root.modelData.trackArtist
                color: "black"
                font.bold: true
            }
        }

        Behavior on implicitWidth {
            NumberAnimation {
                duration: 500
                easing.type: Easing.OutExpo
            }
        }

        function getColor(): string {
            if (modelData.identity === "Spotify")
                return "#1DB954";

            return "white";
        }

        function getIconPath(): string {
            if (modelData.identity === "Spotify")
                return "spotify";

            return "folder-music-symbolic";
        }
    }
    onHoveredChanged: panel.showPanel = this.hovered || panel.showPanel
}
