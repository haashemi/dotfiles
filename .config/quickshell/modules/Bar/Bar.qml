import QtQuick
import Quickshell
import Quickshell.Services.Mpris
import "./components"

Scope {
    SystemClock {
        id: clock
        precision: SystemClock.Seconds
    }

    PanelWindow {
        color: "transparent"
        anchors.top: true
        anchors.left: true
        anchors.right: true
        implicitHeight: 30

        Row {
            anchors.left: parent.left
            anchors.leftMargin: 10
            anchors.verticalCenter: parent.verticalCenter
            spacing: 10

            Clock {
                clock: clock
            }
            Repeater {
                model: Mpris.players
                Mpris {}
            }
        }

        Row {
            anchors.centerIn: parent

            AppTitle {}
        }

        Row {
            anchors.right: parent.right
            anchors.rightMargin: 10
            anchors.verticalCenter: parent.verticalCenter
            spacing: 10

            Battery {}
        }
    }
}
