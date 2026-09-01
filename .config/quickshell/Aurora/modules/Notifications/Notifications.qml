import QtQuick
import QtQuick.Controls.Material
import Quickshell
import Quickshell.Services.Notifications
import qs.config
import qs.services
import qs.modules.Notifications.components

Scope {
    id: root

    SNotifications {
        id: notifications
    }

    readonly property bool shown: notifications.showNotification

    PanelWindow {
        id: panel
        color: "transparent"
        anchors.top: true
        margins.top: 15
        exclusiveZone: 0
        implicitWidth: popup.implicitWidth + 5
        implicitHeight: 35

        Material.theme: Material.Dark
        Material.background: Appearance.background
        Material.primary: Appearance.primary
        Material.accent: Appearance.accent

        NotificationPopup {
            id: popup
            width: parent.width - 5
            height: parent.height - 5
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.top
            anchors.topMargin: root.shown ? 2.5 : -30
            notification: notifications.notification
            shown: root.shown
        }
    }

    Timer {
        running: root.shown
        onTriggered: notifications.dismiss(notifications.notification)
        interval: notifications.notificationCount > 1 ? 1000 : 2000
    }
}