import QtQuick
import qs.config
import qs.components

// 40dp M3 icon button. `color: "transparent"` gives the standard (no container) variant.
Rectangle {
    id: root

    required property string icon
    property color iconColor: Appearance.textOnPrimary

    signal clicked

    implicitWidth: 40
    implicitHeight: 40
    radius: 12

    Behavior on color {
        ColorAnimation {
            duration: 150
        }
    }

    MaterialSymbol {
        anchors.centerIn: parent
        name: root.icon
        size: 24
        fill: true
        color: root.iconColor
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: root.clicked()
    }
}
