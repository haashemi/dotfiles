import QtQuick
import QtQuick.Effects
import Quickshell.Widgets
import Quickshell.Services.Notifications
import qs.config

ClippingRectangle {
    id: root

    required property Notification notification
    required property bool shown

    color: '#303030'
    radius: 15
    implicitWidth: content.implicitWidth + 30
    implicitHeight: 35

    Row {
        id: content
        anchors.left: parent.left
        anchors.leftMargin: 15
        anchors.rightMargin: 15
        anchors.verticalCenter: parent.verticalCenter
        spacing: 10

        Text {
            text: root.notification?.summary ?? ""
            color: Appearance.text
            font.family: Appearance.fontPersian
            font.pixelSize: 14
            font.bold: true
        }

        Text {
            text: root.notification?.body ?? ""
            color: Appearance.text
            font.family: Appearance.fontPersian
            font.pixelSize: 14
        }
    }

    MouseArea {
        anchors.fill: parent
        onClicked: {
            if (root.notification)
                root.notification.tracked = false;
        }
    }

    MultiEffect {
        enabled: root.shown
        source: parent
        anchors.fill: parent
        shadowBlur: 0.25
        shadowEnabled: true
        shadowColor: '#96000000'
    }
}