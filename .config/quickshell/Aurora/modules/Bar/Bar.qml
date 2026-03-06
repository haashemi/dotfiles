import QtQuick
import Quickshell
import Quickshell.Widgets
import "./components"
import "../../config"
import "../../services"
import "../../components"

Scope {
    SBattery {
        id: battery
    }
    SBrightness {
        id: brightness
    }
    SClock {
        id: clock
    }
    SKeyboardBacklight {
        id: keyboardBacklight
    }
    SPlayers {
        id: players
    }
    SVolume {
        id: volume
    }

    PanelWindow {
        anchors.top: true
        anchors.left: true
        anchors.right: true
        implicitHeight: 30
        color: "transparent"

        Row {
            anchors.left: parent.left
            anchors.leftMargin: 10
            anchors.verticalCenter: parent.verticalCenter
            spacing: 10

            Clock {
                clock: clock
            }
            Repeater {
                model: players
                Mpris {
                    required property var modelData
                    player: modelData
                }
            }
        }

        AppTitle {}

        Row {
            anchors.right: parent.right
            anchors.rightMargin: 10
            anchors.verticalCenter: parent.verticalCenter
            spacing: 10

            ClippingRectangle {
                implicitWidth: levelRows.width
                implicitHeight: 25
                radius: 10
                anchors.verticalCenter: parent.verticalCenter
                color: Appearance.background

                Row {
                    id: levelRows
                    anchors.centerIn: parent

                    TrayKeyboardBacklight {
                        keyboardBacklight: keyboardBacklight
                        implicitHeight: 25
                    }

                    Divider {
                        anchors.verticalCenter: parent.verticalCenter
                        implicitWidth: 1
                        implicitHeight: 10
                    }

                    TrayBrightness {
                        brightness: brightness
                        implicitHeight: 25
                    }

                    Divider {
                        anchors.verticalCenter: parent.verticalCenter
                        implicitWidth: 1
                        implicitHeight: 10
                    }

                    TrayVolume {
                        volume: volume
                        implicitHeight: 25
                    }
                }
            }

            Battery {
                anchors.verticalCenter: parent.verticalCenter
                battery: battery
            }
        }
    }
}
