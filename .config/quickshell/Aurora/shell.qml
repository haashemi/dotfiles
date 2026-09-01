//@ pragma UseQApplication
//@ pragma Env QS_NO_RELOAD_POPUP=1
//@ pragma Env QSG_RENDER_LOOP=threaded
//@ pragma Env QT_QUICK_FLICKABLE_WHEEL_DECELERATION=10000

//@ pragma Env QT_SCALE_FACTOR=1
//@ pragma Env QT_AUTO_SCREEN_SCALE_FACTOR=0
//@ pragma Env QT_QUICK_CONTROLS_STYLE=Material

import QtQuick
import Quickshell
import qs.modules.Bar
import qs.modules.OSD
import qs.modules.Notifications

ShellRoot {
    id: entrypoint

    Bar {}
    OSD {}
    Notifications {}
}
