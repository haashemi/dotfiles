import QtQuick
import QtQuick.Effects
import Quickshell
import Quickshell.Widgets
import Quickshell.Wayland

ClippingRectangle {
    id: root
    color: "white"
    radius: height / 2
    implicitWidth: 12 + appIcon.implicitWidth + appName.implicitWidth + 12
    implicitHeight: 20

    property Toplevel topLevel: ToplevelManager.activeToplevel
    property DesktopEntry app: DesktopEntries.byId(root.topLevel.appId)

    Row {
        anchors.centerIn: parent
        spacing: 8
        IconImage {
            id: appIcon
            implicitSize: 15
            anchors.verticalCenter: parent.verticalCenter
            source: Quickshell.iconPath(root.app?.icon ?? root.topLevel.appId)
            layer.enabled: true
            layer.effect: MultiEffect {
                colorization: 1
                colorizationColor: "black"
            }
        }

        Text {
            id: appName
            anchors.verticalCenter: parent.verticalCenter
            text: root.app?.name ?? root.topLevel.title
            color: "black"
            font.bold: true
        }
    }

    Behavior on implicitWidth {
        NumberAnimation {
            duration: 500
            easing.type: Easing.OutExpo
        }
    }
}
