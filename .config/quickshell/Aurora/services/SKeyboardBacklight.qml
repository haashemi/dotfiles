pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

// Goes through UPower: the firmware handles the Fn hotkeys itself, and UPower is
// the only thing that reports those changes (BrightnessChangedWithSource "internal").
Singleton {
    id: root

    property int brightness: 0
    property int maxBrightness: 1
    readonly property int level: Math.round(brightness / maxBrightness * 100)

    readonly property string icon: {
        if (level === 0)
            return "backlight_high_off";
        if (level === 100)
            return "backlight_high";
        return "backlight_low";
    }

    signal adjusted

    readonly property list<string> upower: ["gdbus", "call", "--system", "--dest", "org.freedesktop.UPower", "--object-path", "/org/freedesktop/UPower/KbdBacklight", "--method"]

    Process {
        running: true
        command: [...root.upower, "org.freedesktop.UPower.KbdBacklight.GetMaxBrightness"]
        stdout: StdioCollector {
            onStreamFinished: root.maxBrightness = root.parseReply(this.text) || 1
        }
    }

    Process {
        running: true
        command: [...root.upower, "org.freedesktop.UPower.KbdBacklight.GetBrightness"]
        stdout: StdioCollector {
            onStreamFinished: root.brightness = root.parseReply(this.text)
        }
    }

    Process {
        running: true
        command: ["gdbus", "monitor", "--system", "--dest", "org.freedesktop.UPower", "--object-path", "/org/freedesktop/UPower/KbdBacklight"]
        stdout: SplitParser {
            onRead: line => {
                const match = line.match(/BrightnessChangedWithSource \((\d+),/);
                if (!match)
                    return;
                root.brightness = Number(match[1]);
                root.adjusted();
            }
        }
    }

    IpcHandler {
        target: "keyboard-backlight"

        function increase(): void {
            root.setBrightness(root.brightness + 1);
        }

        function decrease(): void {
            root.setBrightness(root.brightness - 1);
        }
    }

    function setLevel(value: real): void {
        setBrightness(Math.round(value * maxBrightness));
    }

    function setBrightness(value: int): void {
        value = Math.max(0, Math.min(maxBrightness, value));
        // UPower only signals real changes; still pop the OSD at the limits.
        if (value === brightness)
            return adjusted();
        Quickshell.execDetached([...upower, "org.freedesktop.UPower.KbdBacklight.SetBrightness", value.toString()]);
    }

    // gdbus replies look like "(3,)".
    function parseReply(text: string): int {
        return Number(text.match(/\((\d+),\)/)?.[1] ?? 0);
    }
}
