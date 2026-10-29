pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell.Networking
import qs.config
import qs.services
import qs.components

// Network list: tap to connect (asks for a password when needed), tap a
// saved/connected one for Disconnect/Forget.
ColumnLayout {
    id: root

    signal back

    spacing: 12

    PageHeader {
        title: "Wi-Fi"
        hasSwitch: true
        checked: SNetwork.wifiEnabled
        onBack: root.back()
        onToggled: SNetwork.setWifiEnabled(!SNetwork.wifiEnabled)
    }

    Text {
        Layout.fillWidth: true
        Layout.margins: 8
        visible: !SNetwork.wifiEnabled || list.count === 0
        text: SNetwork.wifiEnabled ? "Searching for networks…" : "Wi-Fi is off"
        color: Appearance.textOnSurfaceVariant
        font.family: Appearance.fontUi
        font.pixelSize: 14
    }

    ListView {
        id: list
        Layout.fillWidth: true
        Layout.preferredHeight: Math.min(contentHeight, 440)
        visible: SNetwork.wifiEnabled
        clip: true
        spacing: 4
        boundsBehavior: Flickable.StopAtBounds
        model: SNetwork.networks

        delegate: Rectangle {
            id: item

            required property WifiNetwork modelData
            // Null for a moment while the page unloads, hence the ?. below.
            readonly property WifiNetwork network: modelData
            readonly property bool secured: network?.security !== WifiSecurityType.Open
            property bool expanded: false
            property string error: ""

            width: ListView.view.width
            implicitHeight: content.implicitHeight
            radius: 16
            color: network?.connected ? Appearance.primaryContainer : Appearance.surfaceContainerHighest

            Connections {
                target: item.network
                function onConnectionFailed(reason) {
                    item.error = reason === ConnectionFailReason.NoSecrets ? "Wrong password" : "Couldn't connect";
                    item.expanded = true;
                }
                function onConnectedChanged() {
                    if (item.network?.connected) {
                        item.error = "";
                        item.expanded = false;
                    }
                }
            }

            ColumnLayout {
                id: content
                width: parent.width
                spacing: 0

                // Summary row.
                Item {
                    Layout.fillWidth: true
                    implicitHeight: 56

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            // One tap joins open/saved networks; everything else expands.
                            if (!item.network?.connected && (item.network?.known || !item.secured) && !item.network?.stateChanging)
                                item.network.connect();
                            else
                                item.expanded = !item.expanded;
                        }
                    }

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 16
                        anchors.rightMargin: 16
                        spacing: 16

                        MaterialSymbol {
                            name: SNetwork.signalIcon(item.network?.signalStrength ?? 0)
                            size: 24
                            fill: true
                            color: item.network?.connected ? Appearance.textOnPrimaryContainer : Appearance.textOnSurface
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 0

                            Text {
                                Layout.fillWidth: true
                                text: item.network?.name ?? ""
                                elide: Text.ElideRight
                                color: item.network?.connected ? Appearance.textOnPrimaryContainer : Appearance.textOnSurface
                                font.family: Appearance.fontUi
                                font.pixelSize: 14
                                font.weight: Font.Medium
                            }

                            Text {
                                Layout.fillWidth: true
                                visible: text !== ""
                                text: {
                                    if (item.network?.stateChanging)
                                        return "Connecting…";
                                    if (item.network?.connected)
                                        return "Connected";
                                    if (item.network?.known)
                                        return "Saved";
                                    return "";
                                }
                                color: item.network?.connected ? Appearance.textOnPrimaryContainer : Appearance.textOnSurfaceVariant
                                font.family: Appearance.fontUi
                                font.pixelSize: 12
                            }
                        }

                        MaterialSymbol {
                            visible: item.secured
                            name: "lock"
                            size: 16
                            fill: true
                            color: item.network?.connected ? Appearance.textOnPrimaryContainer : Appearance.textOnSurfaceVariant
                        }
                    }
                }

                // Password entry for new secured networks.
                RowLayout {
                    Layout.fillWidth: true
                    Layout.leftMargin: 16
                    Layout.rightMargin: 16
                    Layout.bottomMargin: 12
                    visible: item.expanded && !item.network?.known && !item.network?.connected
                    spacing: 8

                    Rectangle {
                        Layout.fillWidth: true
                        implicitHeight: 44
                        radius: 12
                        color: "transparent"
                        border.width: password.activeFocus ? 2 : 1
                        border.color: item.error ? Appearance.error : password.activeFocus ? Appearance.primary : Appearance.outline

                        TextInput {
                            id: password
                            anchors.fill: parent
                            anchors.leftMargin: 14
                            anchors.rightMargin: 40
                            verticalAlignment: TextInput.AlignVCenter
                            echoMode: reveal.shown ? TextInput.Normal : TextInput.Password
                            color: Appearance.textOnSurface
                            selectionColor: Appearance.primaryContainer
                            font.family: Appearance.fontUi
                            font.pixelSize: 14
                            clip: true
                            onAccepted: join.clicked()

                            Text {
                                anchors.verticalCenter: parent.verticalCenter
                                visible: !password.text
                                text: "Password"
                                color: Appearance.textOnSurfaceVariant
                                font: password.font
                            }
                        }

                        MaterialSymbol {
                            id: reveal
                            property bool shown: false
                            anchors.right: parent.right
                            anchors.rightMargin: 12
                            anchors.verticalCenter: parent.verticalCenter
                            name: shown ? "visibility_off" : "visibility"
                            size: 20
                            color: Appearance.textOnSurfaceVariant

                            MouseArea {
                                anchors.fill: parent
                                anchors.margins: -6
                                cursorShape: Qt.PointingHandCursor
                                onClicked: reveal.shown = !reveal.shown
                            }
                        }
                    }

                    PillButton {
                        id: join
                        text: "Connect"
                        filled: true
                        enabled: password.text.length >= 8
                        onClicked: {
                            item.error = "";
                            item.network.connectWithPsk(password.text);
                        }
                    }
                }

                Text {
                    Layout.leftMargin: 16
                    Layout.bottomMargin: 12
                    visible: item.expanded && item.error !== ""
                    text: item.error
                    color: Appearance.error
                    font.family: Appearance.fontUi
                    font.pixelSize: 12
                }

                // Saved / connected actions.
                RowLayout {
                    Layout.alignment: Qt.AlignRight
                    Layout.rightMargin: 12
                    Layout.bottomMargin: 12
                    visible: item.expanded && (item.network?.known || item.network?.connected)
                    spacing: 8

                    PillButton {
                        text: "Forget"
                        onClicked: item.network.forget()
                    }

                    PillButton {
                        text: item.network?.connected ? "Disconnect" : "Connect"
                        filled: true
                        onClicked: item.network?.connected ? item.network.disconnect() : item.network.connect()
                    }
                }
            }
        }
    }
}
