import QtQuick
import QtQuick.Effects
import Quickshell
import Quickshell.Widgets
import Quickshell.Services.Notifications

Scope {
    id: root
    NotificationServer {
        id: notificationServer
        keepOnReload: true
        actionsSupported: true
        actionIconsSupported: true
        bodyHyperlinksSupported: true
        bodyImagesSupported: true
        bodyMarkupSupported: true
        imageSupported: true
        inlineReplySupported: true
        persistenceSupported: true

        onNotification: not => not.tracked = true
    }

    property Notification notification: notificationServer.trackedNotifications.values[0]
    property int notificationCount: notificationServer.trackedNotifications.values.length
    property bool showNotification: !!notification

    PanelWindow {
        id: panel
        color: "transparent"
        anchors.top: true
        margins.top: 15
        exclusiveZone: 0
        implicitWidth: content.width + 35
        implicitHeight: 35

        ClippingRectangle {
            id: rect
            width: parent.width - 5 // remove shadow length
            height: parent.height - 5 // remove shadow length
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.top
            anchors.topMargin: root.showNotification ? 2.5 : -30
            color: '#303030'
            radius: 15

            Behavior on implicitWidth {
                NumberAnimation {
                    duration: 300
                    easing.type: Easing.OutQuint
                }
            }

            Row {
                id: content
                anchors.left: parent.left
                anchors.leftMargin: 15
                anchors.rightMargin: 15
                anchors.verticalCenter: parent.verticalCenter
                spacing: 10

                Text {
                    text: root.notification?.summary ?? null
                    color: "white"
                    font.family: "Vazirmatn"
                    font.pixelSize: 14
                    font.bold: true
                }

                Text {
                    id: xContent
                    text: root.notification?.body ?? null
                    color: "white"
                    font.family: "Vazirmatn"
                    font.pixelSize: 14
                }
            }

            MouseArea {
                anchors.fill: parent
                onClicked: root.notification.tracked = false
            }

            MultiEffect {
                enabled: root.showNotification
                source: parent
                anchors.fill: parent
                shadowBlur: 0.25
                shadowEnabled: true
                shadowColor: '#96000000'
            }
        }
    }

    Timer {
        running: root.showNotification
        onTriggered: root.notification.tracked = false
        interval: root.notificationCount > 1 ? 1000 : 2000
    }
}
