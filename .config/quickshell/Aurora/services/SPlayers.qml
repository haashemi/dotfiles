import Quickshell
import Quickshell.Services.Mpris

ScriptModel {
    values: Mpris.players.values.filter(player => player.trackTitle)
}
