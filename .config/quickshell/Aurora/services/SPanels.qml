pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

// Which shell panels are open; shared between the bar button, the panel and IPC.
Singleton {
    id: root

    property bool quickSettings: false

    IpcHandler {
        target: "quicksettings"

        function toggle(): void {
            root.quickSettings = !root.quickSettings;
        }

        function open(): void {
            root.quickSettings = true;
        }

        function close(): void {
            root.quickSettings = false;
        }
    }
}
