import QtQuick
import Quickshell
import Quickshell.Services.Pipewire

Scope {
    readonly property int level: Math.round(Pipewire.defaultAudioSink?.audio.volume * 100)

    PwObjectTracker {
        objects: [Pipewire.defaultAudioSink]
    }
}
