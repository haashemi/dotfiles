import QtQuick
import QtQuick.Controls.Material
import Quickshell
import qs.services
import qs.config
import qs.modules.Bar.components

Scope {
    SBattery {
        id: battery
    }
    SClock {
        id: clock
    }
    SPlayers {
        id: players
    }
    SVolume {
        id: volume
    }
    SBrightness {
        id: brightness
    }
    SNetwork {
        id: network
    }
    SBluetooth {
        id: bluetooth
    }
    SMicrophone {
        id: microphone
    }

    PanelWindow {
        anchors.top: true
        anchors.left: true
        anchors.right: true
        implicitHeight: Appearance.barHeight
        color: "transparent"

        Material.theme: Material.Dark
        Material.background: Appearance.background
        Material.primary: Appearance.primary
        Material.accent: Appearance.accent

        Rectangle {
            id: pill
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            height: Appearance.barHeight
            width: Math.max(220, leftSide.implicitWidth + rightSide.implicitWidth + 40)
            color: Appearance.barPillBackground

            Row {
                id: leftSide
                anchors.left: parent.left
                anchors.leftMargin: 12
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
                id: rightSide
                anchors.right: parent.right
                anchors.rightMargin: 12
                anchors.verticalCenter: parent.verticalCenter
                spacing: 8

                Wifi {
                    network: network
                }
                Bluetooth {
                    bluetooth: bluetooth
                }
                Brightness {
                    brightness: brightness
                }
                Volume {
                    volume: volume
                }
                Mic {
                    microphone: microphone
                }
                Battery {
                    battery: battery
                }
            }
        }
    }
}
