import QtQuick
import QtQuick.Layouts
import qs.config
import qs.components

// Detail page header: back arrow, title, optional action button and master switch.
RowLayout {
    id: root

    required property string title
    property bool hasSwitch: false
    property bool checked: false
    property string action: "" // trailing icon button

    signal back
    signal toggled
    signal actionClicked

    Layout.fillWidth: true
    spacing: 8

    Rectangle {
        implicitWidth: 40
        implicitHeight: 40
        radius: 20
        color: hover.hovered ? Qt.alpha(Appearance.textOnSurface, 0.08) : "transparent"

        HoverHandler {
            id: hover
        }

        MaterialSymbol {
            anchors.centerIn: parent
            name: "arrow_back"
            size: 24
            color: Appearance.textOnSurface
        }

        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: root.back()
        }
    }

    Text {
        Layout.fillWidth: true
        text: root.title
        color: Appearance.textOnSurface
        font.family: Appearance.fontUi
        font.pixelSize: 22
    }

    Rectangle {
        visible: root.action !== ""
        implicitWidth: 40
        implicitHeight: 40
        radius: 20
        color: actionHover.hovered ? Qt.alpha(Appearance.textOnSurface, 0.08) : "transparent"

        HoverHandler {
            id: actionHover
        }

        MaterialSymbol {
            anchors.centerIn: parent
            name: root.action
            size: 24
            color: Appearance.textOnSurfaceVariant
        }

        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: root.actionClicked()
        }
    }

    M3Switch {
        visible: root.hasSwitch
        checked: root.checked
        onToggled: root.toggled()
    }
}
