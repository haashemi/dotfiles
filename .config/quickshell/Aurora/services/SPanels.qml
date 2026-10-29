pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

// Which shell panels are open; shared between the bar button, the panel and IPC.
Singleton {
    id: root

    property bool quickSettings: false
    property string quickSettingsPage: "main"

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
}
