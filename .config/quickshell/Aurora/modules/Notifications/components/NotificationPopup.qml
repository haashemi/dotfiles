import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import Quickshell.Services.Notifications
import qs.config
import qs.services
import qs.components

// Android 16 heads-up card. Click runs the default action, swipe or ✕ dismisses,
// hover pauses the timeout, critical notifications stay until dismissed.
Item {
    id: root

    required property Notification modelData
    readonly property Notification notification: modelData
    readonly property var actions: notification.actions.filter(action => action.identifier !== "default")
    readonly property var defaultAction: notification.actions.find(action => action.identifier === "default") ?? null
    readonly property int timeout: {
        if (notification.urgency === NotificationUrgency.Critical)
            return 0;
        return notification.expireTimeout > 0 ? notification.expireTimeout * 1000 : 4000;
    }
    property bool closing: false
    readonly property alias card: card

    implicitHeight: card.implicitHeight
    opacity: 0

    // Enter: drop in from above. Animates card.y, not a Translate, so the blur
    // region (which tracks item geometry, not transforms) stays aligned.
    Component.onCompleted: enterAnim.start()

    ParallelAnimation {
        id: enterAnim
        NumberAnimation {
            target: card
            property: "y"
            to: 0
            duration: 350
            easing.type: Easing.OutCubic
        }
        NumberAnimation {
            target: root
            property: "opacity"
            to: 1
            duration: 250
            easing.type: Easing.OutCubic
        }
    }

    Timer {
        interval: Math.max(root.timeout, 1)
        running: root.timeout > 0 && !hover.hovered && !swipe.active && !root.closing && !SPanels.quickSettings
        onTriggered: root.close(false, 0)
    }

    // dismissed: user closed it (dismiss) vs timed out (expire).
    function close(dismissed: bool, direction: int): void {
        if (closing)
            return;
        closing = true;
        exit.to = direction === 0 ? card.x : direction * width;
        exit.dismissed = dismissed;
        exit.start();
    }

    ParallelAnimation {
        id: exit
        property real to
        property bool dismissed

        NumberAnimation {
            target: card
            property: "x"
            to: exit.to
            duration: 200
            easing.type: Easing.InCubic
        }
        NumberAnimation {
            target: root
            property: "opacity"
            to: 0
            duration: 200
            easing.type: Easing.InCubic
        }

        onFinished: exit.dismissed ? root.notification.dismiss() : root.notification.expire()
    }

    Rectangle {
        id: card
        y: -16
        width: root.width
        implicitHeight: content.implicitHeight + 32
        radius: 28
        color: Qt.alpha(Appearance.surfaceContainerHigh, 0.75)
        opacity: 1 - Math.min(1, Math.abs(x) / width)

        HoverHandler {
            id: hover
        }

        DragHandler {
            id: swipe
            target: card
            yAxis.enabled: false
            onActiveChanged: {
                if (active)
                    return;
                if (Math.abs(card.x) > card.width * 0.3)
                    root.close(true, Math.sign(card.x));
                else
                    snapBack.start();
            }
        }

        NumberAnimation {
            id: snapBack
            target: card
            property: "x"
            to: 0
            duration: 200
            easing.type: Easing.OutCubic
        }

        MouseArea {
            anchors.fill: parent
            onClicked: {
                root.defaultAction?.invoke();
                root.close(true, 0);
            }
        }

        RowLayout {
            id: content
            anchors.fill: parent
            anchors.margins: 16
            spacing: 12

            // Notification image (avatar/cover) > app icon > generic bell.
            ClippingRectangle {
                id: avatar
                Layout.alignment: Qt.AlignTop
                implicitWidth: 40
                implicitHeight: 40
                radius: 20
                color: Appearance.primaryContainer

                readonly property string appIcon: Quickshell.iconPath(root.notification.appIcon || DesktopEntries.byId(root.notification.desktopEntry)?.icon || "", true)

                Image {
                    anchors.fill: parent
                    visible: source != ""
                    source: root.notification.image
                    fillMode: Image.PreserveAspectCrop
                    sourceSize: Qt.size(80, 80)
                }

                IconImage {
                    anchors.centerIn: parent
                    implicitSize: 28
                    visible: !root.notification.image && source != ""
                    source: avatar.appIcon
                }

                MaterialSymbol {
                    anchors.centerIn: parent
                    visible: !root.notification.image && !avatar.appIcon
                    name: "notifications"
                    size: 22
                    fill: true
                    color: Appearance.textOnPrimaryContainer
                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 2

                RowLayout {
                    Layout.fillWidth: true

                    Text {
                        Layout.fillWidth: true
                        text: root.notification.appName
                        elide: Text.ElideRight
                        color: Appearance.textOnSurfaceVariant
                        font.family: Appearance.fontUi
                        font.pixelSize: 12
                    }

                    MaterialSymbol {
                        name: "close"
                        size: 18
                        color: Appearance.textOnSurfaceVariant

                        MouseArea {
                            anchors.fill: parent
                            anchors.margins: -6
                            cursorShape: Qt.PointingHandCursor
                            onClicked: root.close(true, 0)
                        }
                    }
                }

                Text {
                    Layout.fillWidth: true
                    text: root.notification.summary
                    visible: text !== ""
                    wrapMode: Text.Wrap
                    maximumLineCount: 2
                    elide: Text.ElideRight
                    color: Appearance.textOnSurface
                    font.family: Appearance.fontUi
                    font.pixelSize: 14
                    font.weight: Font.DemiBold
                }

                Text {
                    Layout.fillWidth: true
                    text: root.notification.body
                    visible: text !== ""
                    textFormat: Text.StyledText
                    wrapMode: Text.Wrap
                    maximumLineCount: 4
                    elide: Text.ElideRight
                    color: Appearance.textOnSurfaceVariant
                    linkColor: Appearance.primary
                    font.family: Appearance.fontUi
                    font.pixelSize: 14
                    onLinkActivated: link => Qt.openUrlExternally(link)
                }

                Flow {
                    Layout.fillWidth: true
                    Layout.topMargin: 8
                    visible: root.actions.length > 0
                    spacing: 8

                    Repeater {
                        model: root.actions

                        Rectangle {
                            required property NotificationAction modelData

                            implicitWidth: label.implicitWidth + 32
                            implicitHeight: 32
                            radius: 16
                            color: Appearance.secondaryContainer

                            Text {
                                id: label
                                anchors.centerIn: parent
                                text: parent.modelData.text
                                color: Appearance.textOnSecondaryContainer
                                font.family: Appearance.fontUi
                                font.pixelSize: 13
                                font.weight: Font.Medium
                            }

                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    parent.modelData.invoke();
                                    root.close(true, 0);
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
