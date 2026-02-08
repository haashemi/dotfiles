import QtQuick
import Quickshell
import Quickshell.Io

Scope {
    id: root

    property int brightness: 0
    property int maxBrightness: 100
    readonly property int level: brightness / maxBrightness * 100

    Process {
        running: true
        command: ["brightnessctl", "g"]
        stdout: StdioCollector {
            onStreamFinished: root.brightness = this.text.trim()
        }
    }

    Process {
        running: true
        command: ["brightnessctl", "m"]
        stdout: StdioCollector {
            onStreamFinished: root.maxBrightness = this.text.trim()
        }
    }

    IpcHandler {
        target: "brightness"

        function increase(): void {
            root.applyBrightness(Math.min(root.maxBrightness, root.brightness + (root.maxBrightness / 100 * 5)));
        }

        function decrease(): void {
            root.applyBrightness(Math.max(0, root.brightness - (root.maxBrightness / 100 * 5)));
        }
    }

    function applyBrightness(value: int): void {
        root.brightness = value;
        Quickshell.execDetached(["brightnessctl", "s", Math.round(value).toString()]);
    }
}
