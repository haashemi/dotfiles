import QtQuick
import Quickshell
import Quickshell.Services.Pipewire

Scope {
    readonly property bool muted: Pipewire.defaultAudioSource?.audio.muted ?? true

    PwObjectTracker {
        objects: [Pipewire.defaultAudioSource]
    }
}