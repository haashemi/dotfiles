pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

// Which shell panels are open; shared between the bar button, the panel and IPC.
Singleton {
    id: root

    property bool quickSettings: false
    property string quickSettingsPage: "main"
    property bool launcher: false

    // Both take exclusive keyboard focus, so only one is open at a time.
    onQuickSettingsChanged: if (quickSettings) launcher = false
    onLauncherChanged: if (launcher) quickSettings = false

    // Opens Quick Settings on `page`; closes it if that page is already showing.
    function toggleQuickSettings(page: string): void {
        if (quickSettings && quickSettingsPage === page) {
            quickSettings = false;
        } else {
            quickSettingsPage = page;
            quickSettings = true;
        }
    }

    IpcHandler {
        target: "quicksettings"

        function toggle(): void {
            root.toggleQuickSettings("main");
        }

        function open(): void {
            root.quickSettingsPage = "main";
            root.quickSettings = true;
        }

        function close(): void {
            root.quickSettings = false;
        }
    }

    IpcHandler {
        target: "clipboard"

        function toggle(): void {
            root.toggleQuickSettings("clipboard");
        }
    }

    IpcHandler {
        target: "launcher"

        function toggle(): void {
            root.launcher = !root.launcher;
        }

        function open(): void {
            root.launcher = true;
        }

        function close(): void {
            root.launcher = false;
        }
    }
}
