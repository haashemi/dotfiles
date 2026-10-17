import QtQuick
import Quickshell
import Quickshell.Widgets
import Quickshell.Wayland
import qs.config

ClippingRectangle {
    id: root
    anchors.centerIn: parent
    color: Appearance.secondaryContainer
    radius: height / 2
    implicitWidth: appName.implicitWidth + 24
    implicitHeight: 20

    readonly property Toplevel topLevel: ToplevelManager.activeToplevel
    readonly property DesktopEntry app: DesktopEntries.byId(root.topLevel?.appId)
    readonly property string name: root.app?.name ?? root.topLevel?.title ?? "Aurora"

    Behavior on implicitWidth {
        NumberAnimation {
            duration: Appearance.animationDuration
            easing.type: Easing.OutCubic
        }
    }

    Text {
        id: appName
        anchors.centerIn: parent
        text: root.name
        font.pixelSize: 14
        font.bold: true
        font.family: Appearance.fontUi
        color: Appearance.textOnSecondaryContainer
    }
}
