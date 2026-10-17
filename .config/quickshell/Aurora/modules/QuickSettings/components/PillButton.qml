import QtQuick
import qs.config
import qs.components

// M3 filled / tonal button, 40dp.
Rectangle {
    id: root

    required property string text
    property string icon: ""
    property bool filled: false

    signal clicked

    implicitWidth: row.implicitWidth + 32
    implicitHeight: 40
    radius: 20
    color: filled ? Appearance.primary : Appearance.secondaryContainer
    opacity: enabled ? 1 : 0.38

    Rectangle {
        anchors.fill: parent
        radius: parent.radius
        color: root.filled ? Appearance.textOnPrimary : Appearance.textOnSecondaryContainer
        opacity: hover.hovered && root.enabled ? 0.08 : 0
    }

    HoverHandler {
        id: hover
    }

    Row {
        id: row
        anchors.centerIn: parent
        spacing: 8

        MaterialSymbol {
            anchors.verticalCenter: parent.verticalCenter
            visible: root.icon !== ""
            name: root.icon
            size: 18
            fill: true
            color: label.color
        }

        Text {
            id: label
            anchors.verticalCenter: parent.verticalCenter
            text: root.text
            color: root.filled ? Appearance.textOnPrimary : Appearance.textOnSecondaryContainer
            font.family: Appearance.fontUi
            font.pixelSize: 14
            font.weight: Font.Medium
        }
    }

    MouseArea {
        anchors.fill: parent
        enabled: root.enabled
        cursorShape: Qt.PointingHandCursor
        onClicked: root.clicked()
    }
}
