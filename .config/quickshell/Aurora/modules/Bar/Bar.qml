import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.services
import qs.config
import qs.modules.Bar.components

Scope {
    PanelWindow {
        anchors.top: true
        anchors.left: true
        anchors.right: true
        implicitHeight: Appearance.barHeight
        color: "transparent"
        WlrLayershell.namespace: "aurora-bar"
        BackgroundEffect.blurRegion: Region {
            item: background
        }

        Rectangle {
            id: background
            anchors.fill: parent
            color: Qt.alpha(Appearance.surface, 0.75)
        }

        Row {
            anchors.left: parent.left
            anchors.leftMargin: 12
            anchors.verticalCenter: parent.verticalCenter
            spacing: 10

            Clock {}

            Repeater {
                model: SPlayers.players

                Mpris {
                    required property var modelData
                    player: modelData
                }
            }
        }

        AppTitle {}

        // Status icons double as the Quick Settings button.
        Rectangle {
            anchors.right: parent.right
            anchors.rightMargin: 6
            anchors.verticalCenter: parent.verticalCenter
            implicitWidth: status.implicitWidth + 20
            implicitHeight: 24
            radius: height / 2
            color: SPanels.quickSettings ? Appearance.secondaryContainer : hover.hovered ? Qt.alpha(Appearance.textOnSurface, 0.08) : "transparent"

            Behavior on color {
                ColorAnimation {
                    duration: 150
                }
            }

            HoverHandler {
                id: hover
            }

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: SPanels.toggleQuickSettings("main")
            }

            Row {
                id: status
                anchors.centerIn: parent
                spacing: 8

                Wifi {}
                Bluetooth {}
                Brightness {}
                Volume {}
                Mic {}
                Battery {}
            }
        }
    }
}
