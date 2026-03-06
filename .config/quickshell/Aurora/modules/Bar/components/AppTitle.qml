import QtQuick
import Quickshell
import Quickshell.Widgets
import Quickshell.Wayland

ClippingRectangle {
    id: root
    anchors.centerIn: parent
    color: "white"
    radius: height / 2
    implicitWidth: 12 + appName.implicitWidth + 12
    implicitHeight: 20

    property Toplevel topLevel: ToplevelManager.activeToplevel
    property DesktopEntry app: DesktopEntries.byId(root.topLevel?.appId)

    property string name: root.app?.name ?? root.topLevel?.title ?? "Aurora"

    Text {
        id: appName
        anchors.centerIn: parent
        text: root.name
        font.pixelSize: 14
        font.bold: true
    }

    Behavior on implicitWidth {
        NumberAnimation {
            duration: 500
            easing.type: Easing.OutQuint
        }
    }
}
