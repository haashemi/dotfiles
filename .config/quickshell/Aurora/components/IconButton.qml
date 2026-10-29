import QtQuick
import qs.config

// M3 standard icon button: 40dp circle, no container, 8% hover state layer.
// `filled` fills the icon and tints it primary (a selected toggle, e.g. a pin).
Rectangle {
    id: root

    required property string icon
    property int iconSize: 24
    property bool filled: false
    property color iconColor: Appearance.textOnSurfaceVariant

    signal clicked

    implicitWidth: 40
    implicitHeight: 40
    radius: 20
    color: hover.hovered ? Qt.alpha(Appearance.textOnSurface, 0.08) : "transparent"

    HoverHandler {
        id: hover
    }

    MaterialSymbol {
        anchors.centerIn: parent
        name: root.icon
        size: root.iconSize
        fill: root.filled
        color: root.filled ? Appearance.primary : root.iconColor
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: root.clicked()
    }
}
