pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Services.Mpris

Singleton {
    // ScriptModel diffs updates, so delegates (and their open media cards) survive track changes.
    readonly property ScriptModel players: ScriptModel {
        values: Mpris.players.values.filter(player => player.trackTitle)
    }
}
