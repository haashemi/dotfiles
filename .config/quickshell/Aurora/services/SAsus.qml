pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

// asusd (xyz.ljones.Platform): performance profile and battery charge limit.
Singleton {
    id: root

    // asusd's PlatformProfile values, in cycling order.
    readonly property var profiles: [
        {
            value: 2,
            name: "Quiet",
            icon: "eco"
        },
        {
            value: 0,
            name: "Balanced",
            icon: "balance"
        },
        {
            value: 1,
            name: "Performance",
            icon: "speed"
        }
    ]

    property int profile: -1
    property int chargeLimit: 100
    readonly property var currentProfile: profiles.find(p => p.value === profile) ?? null
    readonly property bool available: profile >= 0

    readonly property list<string> busctl: ["busctl", "--system"]
    readonly property list<string> target: ["xyz.ljones.Asusd", "/xyz/ljones", "xyz.ljones.Platform"]

    // "u 0" / "y 85"
    Process {
        running: true
        command: [...root.busctl, "get-property", ...root.target, "PlatformProfile"]
        stdout: StdioCollector {
            onStreamFinished: root.profile = Number(this.text.trim().split(" ")[1] ?? -1)
        }
    }

    Process {
        running: true
        command: [...root.busctl, "get-property", ...root.target, "ChargeControlEndThreshold"]
        stdout: StdioCollector {
            onStreamFinished: root.chargeLimit = Number(this.text.trim().split(" ")[1] ?? 100)
        }
    }

    // ... {'PlatformProfile': <uint32 1>} / {'ChargeControlEndThreshold': <byte 0x55>}
    Process {
        running: true
        command: ["gdbus", "monitor", "--system", "--dest", "xyz.ljones.Asusd", "--object-path", "/xyz/ljones"]
        stdout: SplitParser {
            onRead: line => {
                const profile = line.match(/'PlatformProfile': <uint32 (\d+)>/);
                if (profile)
                    root.profile = Number(profile[1]);
                const limit = line.match(/'ChargeControlEndThreshold': <byte (0x[0-9a-f]+)>/);
                if (limit)
                    root.chargeLimit = parseInt(limit[1], 16);
            }
        }
    }

    function setProfile(value: int): void {
        Quickshell.execDetached([...busctl, "set-property", ...target, "PlatformProfile", "u", value.toString()]);
    }

    function nextProfile(): void {
        const index = profiles.findIndex(p => p.value === profile);
        setProfile(profiles[(index + 1) % profiles.length].value);
    }

    function setChargeLimit(value: int): void {
        Quickshell.execDetached([...busctl, "set-property", ...target, "ChargeControlEndThreshold", "y", value.toString()]);
    }

    function chargeFullOnce(): void {
        Quickshell.execDetached([...busctl, "call", ...target, "OneShotFullCharge"]);
    }
}
