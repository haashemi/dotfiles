pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.Pipewire

Singleton {
    id: root

    readonly property PwNode sink: Pipewire.defaultAudioSink
    readonly property PwNode source: Pipewire.defaultAudioSource
    readonly property real volume: sink?.audio?.volume ?? 0
    readonly property int level: Math.round(volume * 100)
    readonly property bool muted: sink?.audio?.muted ?? false
    readonly property bool micMuted: source?.audio?.muted ?? true

    readonly property string icon: {
        if (muted || level === 0)
            return "no_sound";
        if (level <= 35)
            return "volume_mute";
        if (level <= 65)
            return "volume_down";
        return "volume_up";
    }

    // Any volume/mute/mic change, from anywhere (keys, headset buttons, other
    // apps). Drives the OSD.
    signal adjusted

    // A freshly bound or switched device reports its initial state as changes;
    // don't pop the OSD for that.
    property bool settled: false

    onSinkChanged: settle()
    onSourceChanged: settle()

    function settle(): void {
        settled = false;
        settleTimer.restart();
    }

    Timer {
        id: settleTimer
        interval: 500
        running: true
        onTriggered: root.settled = true
    }

    Connections {
        target: root.sink?.audio ?? null
        ignoreUnknownSignals: true

        function onVolumesChanged() {
            if (root.settled)
                root.adjusted();
        }

        function onMutedChanged() {
            if (root.settled)
                root.adjusted();
        }
    }

    Connections {
        target: root.source?.audio ?? null
        ignoreUnknownSignals: true

        function onMutedChanged() {
            if (root.settled)
                root.adjusted();
        }
    }

    PwObjectTracker {
        objects: [root.sink, root.source]
    }

    function setVolume(value: real): void {
        if (sink?.ready)
            sink.audio.volume = Math.max(0, Math.min(1, value));
    }

    function setMuted(value: bool): void {
        if (sink?.ready)
            sink.audio.muted = value;
    }

    function toggleMic(): void {
        if (source?.ready)
            source.audio.muted = !source.audio.muted;
    }

    // 25 steps, same as Android's media stream. Each call also emits adjusted
    // directly: at 0%/100% nothing changes, but the OSD should still show.
    IpcHandler {
        target: "volume"

        function increase(): void {
            if (root.muted)
                root.setMuted(false);
            root.setVolume(root.volume + 0.04);
            root.adjusted();
        }

        function decrease(): void {
            root.setVolume(root.volume - 0.04);
            root.adjusted();
        }

        function toggleMute(): void {
            root.setMuted(!root.muted);
            root.adjusted();
        }
    }
}
