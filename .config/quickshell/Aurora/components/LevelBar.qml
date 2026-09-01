import QtQuick
import qs.config

Item {
    id: root

    required property real level
    property color trackColor: "#50ffffff"
    property color fillColor: Appearance.accent
    property int radius: 20

    implicitWidth: 100
    implicitHeight: 10

    Rectangle {
        id: track
        anchors.fill: parent
        radius: root.radius
        color: root.trackColor

        Rectangle {
            id: fill
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            radius: parent.radius
            width: parent.width * root.level
            color: root.fillColor

            Behavior on width {
                NumberAnimation {
                    duration: Appearance.animationDuration
                    easing.type: Easing.OutQuint
                }
            }
        }
    }
}