import QtQuick
import qs.config

// M3 switch: 52x32 track; the thumb grows 16 -> 24 and shows a check when on.
Rectangle {
    id: root

    required property bool checked
    signal toggled

    implicitWidth: 52
    implicitHeight: 32
    radius: height / 2
    color: checked ? Appearance.primary : Appearance.surfaceContainerHighest
    border.width: checked ? 0 : 2
    border.color: Appearance.outline

    Behavior on color {
        ColorAnimation {
            duration: 150
        }
    }

    Rectangle {
        x: root.checked ? root.width - width - 4 : 8
        anchors.verticalCenter: parent.verticalCenter
        width: root.checked ? 24 : 16
        height: width
        radius: width / 2
        color: root.checked ? Appearance.textOnPrimary : Appearance.outline

        Behavior on x {
            NumberAnimation {
                duration: 200
                easing.type: Easing.OutBack
            }
        }
        Behavior on width {
            NumberAnimation {
                duration: 200
                easing.type: Easing.OutCubic
            }
        }

        MaterialSymbol {
            anchors.centerIn: parent
            visible: root.checked
            name: "check"
            size: 16
            color: Appearance.primary
        }
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: root.toggled()
    }
}
