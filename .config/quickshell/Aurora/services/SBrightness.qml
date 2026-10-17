pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    property string device: ""
    property int brightness: 0
    property int maxBrightness: 1
    readonly property int level: Math.round(brightness / maxBrightness * 100)

    readonly property string icon: {
        if (level === 0)
            return "brightness_1";
        if (level <= 20)
            return "brightness_2";
        if (level <= 40)
            return "brightness_3";
        if (level <= 60)
            return "brightness_4";
        if (level <= 80)
            return "brightness_5";
        if (level <= 99)
            return "brightness_6";
        return "brightness_7";
    }

    signal adjusted

    // "amdgpu_bl1,backlight,65535,100%,65535"
    Process {
        running: true
        command: ["brightnessctl", "-m", "-c", "backlight", "info"]
        stdout: StdioCollector {
            onStreamFinished: {
                const fields = this.text.trim().split(",");
                root.device = fields[0];
                root.brightness = Number(fields[2]);
                root.maxBrightness = Number(fields[4]) || 1;
            }
        }
    }

    // Re-read before every step so changes made elsewhere aren't stepped over.
    FileView {
        id: sysfs
        path: root.device ? `/sys/class/backlight/${root.device}/brightness` : ""
        blockAllReads: true
    }

    IpcHandler {
        target: "brightness"

        function increase(): void {
            root.step(5);
        }

        function decrease(): void {
            root.step(-5);
        }
    }

    function step(percent: int): void {
        sysfs.reload();
        const current = parseInt(sysfs.text());
        if (!isNaN(current))
            brightness = current;
        setBrightness(brightness + maxBrightness * percent / 100);
    }

    function setLevel(value: real): void {
        setBrightness(value * maxBrightness);
    }

    function setBrightness(value: int): void {
        brightness = Math.max(0, Math.min(maxBrightness, Math.round(value)));
        Quickshell.execDetached(["brightnessctl", "-q", "-d", device, "set", brightness.toString()]);
        adjusted();
    }
}
