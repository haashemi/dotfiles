import QtQuick
import Quickshell
import qs.services
import qs.config
import qs.modules.Bar.components

Scope {
    PanelWindow {
        anchors.top: true
        anchors.left: true
        anchors.right: true
        implicitHeight: Appearance.barHeight
        color: Qt.alpha(Appearance.surface, 0.9)

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

        Row {
            anchors.right: parent.right
            anchors.rightMargin: 12
            anchors.verticalCenter: parent.verticalCenter
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
