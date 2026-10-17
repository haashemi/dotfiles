pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.config
import qs.components

// Session actions. No lock: there's no screen locker installed yet.
ColumnLayout {
    id: root

    signal back
    signal close

    readonly property var actions: [
        {
            icon: "logout",
            label: "Log out",
            command: ["niri", "msg", "action", "quit", "--skip-confirmation"]
        },
        {
            icon: "bedtime",
            label: "Suspend",
            command: ["systemctl", "suspend"]
        },
        {
            icon: "restart_alt",
            label: "Restart",
            command: ["systemctl", "reboot"]
        },
        {
            icon: "power_settings_new",
            label: "Power off",
            command: ["systemctl", "poweroff"]
        }
    ]

    spacing: 16

    PageHeader {
        title: "Power"
        onBack: root.back()
    }

    GridLayout {
        Layout.fillWidth: true
        columns: 2
        columnSpacing: 8
        rowSpacing: 8
        uniformCellWidths: true

        Repeater {
            model: root.actions

            Tile {
                required property var modelData

                Layout.fillWidth: true
                icon: modelData.icon
                label: modelData.label
                onToggled: {
                    root.close();
                    Quickshell.execDetached(modelData.command);
                }
            }
        }
    }
}
