pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Services.Notifications

// Only advertise what NotificationPopup actually renders.
Singleton {
    readonly property alias list: server.trackedNotifications

    NotificationServer {
        id: server
        keepOnReload: true
        actionsSupported: true
        bodyMarkupSupported: true
        bodyHyperlinksSupported: true
        imageSupported: true
        persistenceSupported: true

        onNotification: notification => notification.tracked = true
    }
}
