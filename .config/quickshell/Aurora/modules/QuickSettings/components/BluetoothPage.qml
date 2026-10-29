pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell.Bluetooth
import qs.config
import qs.services
import qs.components

// Paired devices (tap to connect/disconnect, expand to forget) and nearby
// devices (tap to pair + connect). Discovery runs while this page is open.
ColumnLayout {
    id: root

    signal back

    spacing: 12

    PageHeader {
        title: "Bluetooth"
        hasSwitch: true
        checked: SBluetooth.enabled
        onBack: root.back()
        onToggled: SBluetooth.setEnabled(!SBluetooth.enabled)
    }

    Text {
        Layout.fillWidth: true
        Layout.margins: 8
        visible: !SBluetooth.enabled
        text: "Bluetooth is off"
        color: Appearance.textOnSurfaceVariant
        font.family: Appearance.fontUi
        font.pixelSize: 14
    }

    Flickable {
        Layout.fillWidth: true
        Layout.preferredHeight: Math.min(contentHeight, 440)
        visible: SBluetooth.enabled
        clip: true
        contentHeight: sections.implicitHeight
        boundsBehavior: Flickable.StopAtBounds

        ColumnLayout {
            id: sections
            width: parent.width
            spacing: 4

            SectionLabel {
                visible: SBluetooth.paired.values.length > 0
                text: "Paired devices"
            }

            Repeater {
                model: SBluetooth.paired
                delegate: DeviceItem {}
            }

            SectionLabel {
                Layout.topMargin: 8
                text: SBluetooth.adapter?.discovering ? "Available devices · searching…" : "Available devices"
            }

            Repeater {
                model: SBluetooth.available
                delegate: DeviceItem {}
            }
        }
    }

    component SectionLabel: Text {
        Layout.fillWidth: true
        Layout.leftMargin: 8
        Layout.bottomMargin: 4
        color: Appearance.primary
        font.family: Appearance.fontUi
        font.pixelSize: 13
        font.weight: Font.Medium
    }

    component DeviceItem: Rectangle {
        id: item

        required property BluetoothDevice modelData
        readonly property BluetoothDevice device: modelData
        readonly property bool known: device.paired || device.bonded
        readonly property bool busy: device.pairing || device.state === BluetoothDeviceState.Connecting || device.state === BluetoothDeviceState.Disconnecting
        property bool expanded: false

        Layout.fillWidth: true
        implicitHeight: content.implicitHeight
        radius: 16
        color: device.connected ? Appearance.primaryContainer : Appearance.surfaceContainerHighest

        // Freshly paired from the "available" list: connect right away.
        Connections {
            target: item.device
            function onPairedChanged() {
                if (item.device.paired && !item.device.connected)
                    item.device.connect();
            }
        }

        ColumnLayout {
            id: content
            width: parent.width
            spacing: 0

            Item {
                Layout.fillWidth: true
                implicitHeight: 56

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        if (item.busy)
                            return;
                        if (!item.known) {
                            item.device.trusted = true;
                            item.device.pair();
                        } else if (item.device.connected) {
                            item.device.disconnect();
                        } else {
                            item.device.connect();
                        }
                    }
                }

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 16
                    anchors.rightMargin: 8
                    spacing: 16

                    MaterialSymbol {
                        name: SBluetooth.deviceIcon(item.device.icon)
                        size: 24
                        fill: true
                        color: item.device.connected ? Appearance.textOnPrimaryContainer : Appearance.textOnSurface
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 0

                        Text {
                            Layout.fillWidth: true
                            text: item.device.name || item.device.address
                            elide: Text.ElideRight
                            color: item.device.connected ? Appearance.textOnPrimaryContainer : Appearance.textOnSurface
                            font.family: Appearance.fontUi
                            font.pixelSize: 14
                            font.weight: Font.Medium
                        }

                        Text {
                            Layout.fillWidth: true
                            visible: text !== ""
                            text: {
                                if (item.device.pairing)
                                    return "Pairing…";
                                if (item.device.state === BluetoothDeviceState.Connecting)
                                    return "Connecting…";
                                if (item.device.state === BluetoothDeviceState.Disconnecting)
                                    return "Disconnecting…";
                                if (item.device.connected)
                                    return item.device.batteryAvailable ? `Connected · ${Math.round(item.device.battery * 100)}% battery` : "Connected";
                                return item.known ? "Paired" : "";
                            }
                            color: item.device.connected ? Appearance.textOnPrimaryContainer : Appearance.textOnSurfaceVariant
                            font.family: Appearance.fontUi
                            font.pixelSize: 12
                        }
                    }

                    // Overflow: reveals Forget.
                    IconButton {
                        visible: item.known
                        icon: item.expanded ? "expand_less" : "expand_more"
                        iconColor: item.device.connected ? Appearance.textOnPrimaryContainer : Appearance.textOnSurfaceVariant
                        onClicked: item.expanded = !item.expanded
                    }
                }
            }

            RowLayout {
                Layout.alignment: Qt.AlignRight
                Layout.rightMargin: 12
                Layout.bottomMargin: 12
                visible: item.expanded && item.known
                spacing: 8

                PillButton {
                    text: "Forget"
                    onClicked: item.device.forget()
                }

                PillButton {
                    text: item.device.connected ? "Disconnect" : "Connect"
                    filled: true
                    enabled: !item.busy
                    onClicked: item.device.connected ? item.device.disconnect() : item.device.connect()
                }
            }
        }
    }
}
