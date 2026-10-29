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

    IconButton {
        icon: "arrow_back"
        iconColor: Appearance.textOnSurface
        onClicked: root.back()
    }

    Text {
        Layout.fillWidth: true
        text: root.title
        color: Appearance.textOnSurface
        font.family: Appearance.fontUi
        font.pixelSize: 22
    }

    IconButton {
        visible: root.action !== ""
        icon: root.action
        onClicked: root.actionClicked()
    }

    M3Switch {
        visible: root.hasSwitch
        checked: root.checked
        onToggled: root.toggled()
    }
}
