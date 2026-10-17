import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.services
import qs.modules.Notifications.components

// Heads-up stack, top-right under the bar. The window only exists while there
// are popups, and only the cards take input or get blurred.
Scope {
    PanelWindow {
        id: window

        // Cards register themselves so each gets its own rounded blur region.
        property list<Item> cards: []

        visible: (SNotifications.list?.values.length ?? 0) > 0
        anchors.top: true
        anchors.right: true
        margins.top: 8
        margins.right: 8
        exclusiveZone: 0
        implicitWidth: 400
        implicitHeight: Math.max(1, column.implicitHeight)
        color: "transparent"
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.namespace: "aurora-notifications"
        mask: Region {
            item: column
        }
        BackgroundEffect.blurRegion: Region {
            regions: blurRegions.instances
        }

        Variants {
            id: blurRegions
            model: window.cards

            Region {
                required property Item modelData
                item: modelData
                radius: 28
            }
        }

        Column {
            id: column
            width: parent.width
            spacing: 8

            move: Transition {
                NumberAnimation {
                    properties: "y"
                    duration: 250
                    easing.type: Easing.OutCubic
                }
            }

            Repeater {
                model: SNotifications.list

                NotificationPopup {
                    width: column.width
                    Component.onCompleted: window.cards = [...window.cards, card]
                    Component.onDestruction: window.cards = window.cards.filter(item => item !== card)
                }
            }
        }
    }
}
