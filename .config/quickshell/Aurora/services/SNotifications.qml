pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Services.Notifications

// Only advertise what NotificationPopup actually renders.
Singleton {
    id: root

    readonly property alias list: server.trackedNotifications
    // Do Not Disturb. There's no history, so muted notifications are dropped;
    // critical ones still come through.
    property alias dnd: state.dnd

    PersistentProperties {
        id: state
        reloadableId: "notifications"
        property bool dnd: false
    }

    NotificationServer {
        id: server
        keepOnReload: true
        actionsSupported: true
        bodyMarkupSupported: true
        bodyHyperlinksSupported: true
        imageSupported: true
        persistenceSupported: true

        onNotification: notification => {
            // niri announces every screenshot; it's already in the clipboard history.
            if (notification.appName === "niri" && notification.summary === "Screenshot captured")
                return;
            notification.tracked = !root.dnd || notification.urgency === NotificationUrgency.Critical;
        }
    }
}
