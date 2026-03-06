//@ pragma UseQApplication
//@ pragma Env QS_NO_RELOAD_POPUP=1
//@ pragma Env QSG_RENDER_LOOP=threaded
//@ pragma Env QT_QUICK_FLICKABLE_WHEEL_DECELERATION=10000

//@ pragma Env QT_SCALE_FACTOR=1
//@ pragma Env QT_QUICK_CONTROLS_STYLE=Material
//@ pragma Env QT_WAYLAND_DISABLE_WINDOWDECORATION=1

import QtQuick
import Quickshell
import "modules/Bar"

ShellRoot {
    id: entrypoint

    readonly property bool disableWatchFiles: Quickshell.env("QS_WATCH_FILES") === "false"

    Component.onCompleted: {
        Quickshell.watchFiles = !disableWatchFiles;
    }

    Bar {}
}
