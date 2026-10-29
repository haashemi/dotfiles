pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

// Clipboard history (14 newest) plus pinned entries, stored on disk by
// scripts/clipboard.sh under ~/.local/share/aurora/clipboard. Sensitive copies
// (password managers) are never stored.
Singleton {
    id: root

    readonly property string script: Quickshell.shellPath("scripts/clipboard.sh")

    // Pinned first, then history; newest first in each.
    property var entries: []
    readonly property ScriptModel model: ScriptModel {
        values: root.entries
        objectProp: "path"
    }

    // Commands run one at a time, so list output never interleaves with a mutation.
    property var queue: []

    function copy(entry: var): void {
        run(["copy", entry.path]);
    }

    function togglePin(entry: var): void {
        run([entry.pinned ? "unpin" : "pin", entry.path]);
    }

    function remove(entry: var): void {
        run(["delete", entry.path]);
    }

    function clear(): void {
        run(["clear"]);
    }

    function run(args: list<string>): void {
        queue.push(args);
        next();
    }

    function next(): void {
        if (ops.running || queue.length === 0)
            return;
        ops.command = ["sh", script, ...queue.shift()];
        ops.running = true;
    }

    function parse(text: string): void {
        entries = text.split("\n").filter(line => line !== "").map(path => ({
                    path: path,
                    pinned: path.includes("/pinned/"),
                    image: !path.endsWith(".txt")
                }));
    }

    Component.onCompleted: run(["list"])

    Process {
        id: ops
        stdout: StdioCollector {
            // Everything but copy prints the list (empty when nothing is stored).
            onStreamFinished: {
                if (ops.command[2] !== "copy")
                    root.parse(this.text);
            }
        }
        // Let the collector finish with this output before the next command starts.
        onExited: Qt.callLater(root.next)
    }

    Process {
        id: watcher
        running: true
        command: ["wl-paste", "--watch", "sh", root.script, "store"]
        stdout: SplitParser {
            onRead: root.run(["list"])
        }
        onExited: restart.start()
    }

    Timer {
        id: restart
        interval: 2000
        onTriggered: watcher.running = true
    }
}
