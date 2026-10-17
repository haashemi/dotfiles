import QtQuick
import QtQuick.Layouts
import qs.config
import qs.components

// Detail page header: back arrow, title, optional master switch.
RowLayout {
    id: root

    required property string title
    property bool hasSwitch: false
    property bool checked: false

    signal back
    signal toggled

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

    M3Switch {
        visible: root.hasSwitch
        checked: root.checked
        onToggled: root.toggled()
    }
}
