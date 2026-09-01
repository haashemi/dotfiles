import QtQuick
import Quickshell
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

    readonly property Notification notification: notificationServer.trackedNotifications.values[0]
    readonly property int notificationCount: notificationServer.trackedNotifications.values.length
    readonly property bool showNotification: !!notification

    function dismiss(not): void {
        not.tracked = false;
    }
}