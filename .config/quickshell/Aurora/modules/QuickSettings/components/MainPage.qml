import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.config
import qs.services
import qs.components

// Header (clock, date, battery, power) / sliders / tiles / media.
ColumnLayout {
    id: root

    property bool active: false

    signal open(string page)
    signal close

    spacing: 16

    RowLayout {
        Layout.fillWidth: true
        spacing: 8

        ColumnLayout {
            spacing: -4

            Text {
                text: Qt.formatDateTime(SClock.date, "hh:mm")
                color: Appearance.textOnSurface
                font.family: Appearance.fontUi
                font.pixelSize: 44
                font.weight: Font.Light
                font.features: {
                    "tnum": 1
                }
            }

            Text {
                text: Qt.formatDateTime(SClock.date, "dddd, MMMM d")
                color: Appearance.textOnSurfaceVariant
                font.family: Appearance.fontUi
                font.pixelSize: 14
            }
        }

        Item {
            Layout.fillWidth: true
        }

        HeaderButton {
            visible: SBattery.present
            icon: SBattery.icon
            text: `${SBattery.level}%`
            onClicked: root.open("battery")
        }

        HeaderButton {
            icon: "power_settings_new"
            filled: true
            onClicked: root.open("power")
        }
    }

    ColumnLayout {
        Layout.fillWidth: true
        spacing: 12

        HSlider {
            Layout.fillWidth: true
            value: SBrightness.level / 100
            icon: "brightness_medium"
            onMoved: value => SBrightness.setLevel(value)
        }

        HSlider {
            Layout.fillWidth: true
            value: SVolume.muted ? 0 : SVolume.volume
            icon: SVolume.icon
            onMoved: value => {
                if (SVolume.muted)
                    SVolume.setMuted(false);
                SVolume.setVolume(value);
            }
        }

        HSlider {
            Layout.fillWidth: true
            value: SKeyboardBacklight.level / 100
            steps: SKeyboardBacklight.maxBrightness
            icon: "keyboard"
            onMoved: value => SKeyboardBacklight.setLevel(value)
        }
    }

    GridLayout {
        Layout.fillWidth: true
        columns: 4
        columnSpacing: 8
        rowSpacing: 8
        uniformCellWidths: true

        Tile {
            Layout.fillWidth: true
            Layout.columnSpan: 2
            icon: !SNetwork.wifiEnabled ? "wifi_off" : SNetwork.wifiConnected ? SNetwork.signalIcon(SNetwork.wifiStrength) : "wifi"
            label: "Wi-Fi"
            sublabel: !SNetwork.wifiEnabled ? "Off" : SNetwork.activeWifi?.name ?? "Not connected"
            active: SNetwork.wifiEnabled
            hasDetails: true
            onToggled: SNetwork.setWifiEnabled(!SNetwork.wifiEnabled)
            onOpened: root.open("wifi")
        }

        Tile {
            readonly property var device: SBluetooth.connected[0] ?? null

            Layout.fillWidth: true
            Layout.columnSpan: 2
            icon: !SBluetooth.enabled ? "bluetooth_disabled" : device ? "bluetooth_connected" : "bluetooth"
            label: "Bluetooth"
            sublabel: {
                if (!SBluetooth.enabled)
                    return "Off";
                if (!device)
                    return "On";
                const battery = device.batteryAvailable ? ` · ${Math.round(device.battery * 100)}%` : "";
                const more = SBluetooth.connectedDevices > 1 ? ` +${SBluetooth.connectedDevices - 1}` : "";
                return device.name + battery + more;
            }
            active: SBluetooth.enabled
            hasDetails: true
            onToggled: SBluetooth.setEnabled(!SBluetooth.enabled)
            onOpened: root.open("bluetooth")
        }

        Tile {
            Layout.fillWidth: true
            Layout.columnSpan: 2
            visible: SAsus.available
            icon: SAsus.currentProfile?.icon ?? "balance"
            label: "Power mode"
            sublabel: SAsus.currentProfile?.name ?? ""
            active: SAsus.profile !== 0 // anything but Balanced
            hasDetails: true
            onToggled: SAsus.nextProfile()
            onOpened: root.open("battery")
        }

        Tile {
            Layout.fillWidth: true
            Layout.columnSpan: 2
            icon: "do_not_disturb_on"
            label: "Do Not Disturb"
            sublabel: SNotifications.dnd ? "On" : "Off"
            active: SNotifications.dnd
            onToggled: SNotifications.dnd = !SNotifications.dnd
        }

        Tile {
            Layout.fillWidth: true
            icon: SVolume.micMuted ? "mic_off" : "mic"
            active: !SVolume.micMuted
            onToggled: SVolume.toggleMic()
        }

        Tile {
            readonly property bool airplane: !SNetwork.wifiEnabled && !SBluetooth.enabled

            Layout.fillWidth: true
            icon: "flight"
            active: airplane
            onToggled: {
                SNetwork.setWifiEnabled(airplane);
                SBluetooth.setEnabled(airplane);
            }
        }

        Tile {
            Layout.fillWidth: true
            icon: "screenshot_region"
            onToggled: {
                root.close();
                // Let the panel animate away before niri's picker freezes the screen.
                Quickshell.execDetached(["sh", "-c", "sleep 0.3; niri msg action screenshot"]);
            }
        }
    }

    MediaCard {
        Layout.fillWidth: true
        visible: players.length > 0
        players: SPlayers.players.values
        active: root.active
    }

    component HeaderButton: Rectangle {
        id: button

        required property string icon
        property string text: ""
        property bool filled: false

        signal clicked

        implicitWidth: text ? label.implicitWidth + 48 : 40
        implicitHeight: 40
        radius: 20
        color: filled ? Appearance.primary : Appearance.surfaceContainerHighest

        Row {
            id: label
            anchors.centerIn: parent
            spacing: 4

            MaterialSymbol {
                anchors.verticalCenter: parent.verticalCenter
                name: button.icon
                size: 20
                fill: true
                color: button.filled ? Appearance.textOnPrimary : Appearance.textOnSurface
            }

            Text {
                anchors.verticalCenter: parent.verticalCenter
                visible: button.text !== ""
                text: button.text
                color: Appearance.textOnSurface
                font.family: Appearance.fontUi
                font.pixelSize: 14
                font.weight: Font.Medium
                font.features: {
                    "tnum": 1
                }
            }
        }

        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: button.clicked()
        }
    }
}
