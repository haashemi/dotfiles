import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Services.Mpris
import qs.config
import qs.components

// Media card for one player, under the bar. Toggled from the bar pill; closes
// a second after the pointer leaves it.
Scope {
    id: root

    required property MprisPlayer player
    property bool open: false
    property real progress: open ? 1 : 0

    Behavior on progress {
        NumberAnimation {
            duration: root.open ? 300 : 180
            easing.type: root.open ? Easing.OutCubic : Easing.InCubic
        }
    }

    onOpenChanged: if (open)
        closeTimer.restart()

    Timer {
        id: closeTimer
        interval: 1000
        onTriggered: root.open = false
    }

    PanelWindow {
        visible: root.progress > 0
        anchors.top: true
        anchors.left: true
        margins.top: 8
        margins.left: 8
        exclusiveZone: 0
        implicitWidth: card.width
        implicitHeight: card.height
        color: "transparent"
        WlrLayershell.namespace: "aurora-media"
        mask: Region {
            item: card
        }

        MediaCard {
            id: card
            width: 400
            y: (1 - root.progress) * -16
            opacity: root.progress
            players: [root.player]
            active: root.open

            HoverHandler {
                onHoveredChanged: hovered ? closeTimer.stop() : closeTimer.restart()
            }
        }
    }
}
