pragma Singleton

import QtQuick
import Quickshell

Singleton {
    readonly property date date: clock.date

    SystemClock {
        id: clock
        precision: SystemClock.Minutes
    }
}
