import QtQuick
import qs.config
import qs.components

// Android 16/17 QS tile. Wide: icon container (toggles) + label/sublabel (opens
// details when hasDetails). Small: icon only. "On" morphs the tile from a pill
// to a rounded square; small tiles also fill primary, wide ones fill their icon container.
Rectangle {
    id: root

    required property string icon
    property string label: ""
    property string sublabel: ""
    property bool active: false
    property bool hasDetails: false
    readonly property bool wide: label !== ""

    signal toggled
    signal opened

    implicitHeight: 64
    radius: active ? 20 : height / 2
    color: !wide && active ? Appearance.primary : Qt.alpha(Appearance.surfaceContainerHighest, 0.8)

    Behavior on radius {
        NumberAnimation {
            duration: 250
            easing.type: Easing.OutBack
        }
    }
    Behavior on color {
        ColorAnimation {
            duration: 150
        }
    }

    // M3 hover state layer.
    Rectangle {
        anchors.fill: parent
        radius: parent.radius
        color: Appearance.textOnSurface
        opacity: hover.hovered ? 0.08 : 0
    }

    HoverHandler {
        id: hover
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: root.hasDetails ? root.opened() : root.toggled()
    }

    Rectangle {
        id: iconBox
        visible: root.wide
        x: 8
        anchors.verticalCenter: parent.verticalCenter
        width: 48
        height: 48
        radius: root.active ? 16 : 24
        color: root.active ? Appearance.primary : Qt.alpha(Appearance.textOnSurface, 0.08)

        Behavior on radius {
            NumberAnimation {
                duration: 250
                easing.type: Easing.OutBack
            }
        }
        Behavior on color {
            ColorAnimation {
                duration: 150
            }
        }

        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: root.toggled()
        }
    }

    MaterialSymbol {
        anchors.centerIn: root.wide ? iconBox : parent
        name: root.icon
        size: 24
        fill: true
        color: root.active ? Appearance.textOnPrimary : Appearance.textOnSurface
    }

    Column {
        visible: root.wide
        anchors.left: iconBox.right
        anchors.leftMargin: 12
        anchors.right: parent.right
        anchors.rightMargin: 16
        anchors.verticalCenter: parent.verticalCenter

        Text {
            width: parent.width
            text: root.label
            elide: Text.ElideRight
            color: Appearance.textOnSurface
            font.family: Appearance.fontUi
            font.pixelSize: 14
            font.weight: Font.Medium
        }

        Text {
            width: parent.width
            visible: text !== ""
            text: root.sublabel
            elide: Text.ElideRight
            color: Appearance.textOnSurfaceVariant
            font.family: Appearance.fontUi
            font.pixelSize: 12
        }
    }
}
