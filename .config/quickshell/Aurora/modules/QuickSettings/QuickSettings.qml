import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.config
import qs.services
import qs.modules.QuickSettings.components

// Android 17-style Quick Settings, top-right under the bar. Opened by the bar's
// status button or Mod+A (IPC "quicksettings"), or on the clipboard page by
// Mod+V (IPC "clipboard"); Esc, a click outside or the same button closes it.
// A full-screen transparent layer catches outside clicks.
Scope {
    id: root

    readonly property string page: SPanels.quickSettingsPage
    property real progress: SPanels.quickSettings ? 1 : 0

    // M3 emphasized motion: long gentle deceleration in, quick acceleration out.
    Behavior on progress {
        NumberAnimation {
            duration: SPanels.quickSettings ? 450 : 250
            easing.type: Easing.BezierSpline
            easing.bezierCurve: SPanels.quickSettings ? [0.05, 0.7, 0.1, 1, 1, 1] : [0.3, 0, 0.8, 0.15, 1, 1]
        }
    }

    Connections {
        target: SPanels
        function onQuickSettingsChanged() {
            if (SPanels.quickSettings)
                panel.forceActiveFocus();
        }
    }

    // Scan only while the matching list is on screen.
    Binding {
        target: SNetwork
        property: "scanning"
        value: SPanels.quickSettings && root.page === "wifi"
    }
    Binding {
        target: SBluetooth
        property: "scanning"
        value: SPanels.quickSettings && root.page === "bluetooth"
    }

    PanelWindow {
        visible: root.progress > 0
        anchors.top: true
        anchors.bottom: true
        anchors.left: true
        anchors.right: true
        exclusionMode: ExclusionMode.Ignore
        color: "transparent"
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.namespace: "aurora-quicksettings"
        WlrLayershell.keyboardFocus: SPanels.quickSettings ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None

        MouseArea {
            anchors.fill: parent
            onClicked: SPanels.quickSettings = false
        }

        Rectangle {
            id: panel

            readonly property Item current: ({
                    main: main,
                    wifi: wifi,
                    bluetooth: bluetooth,
                    battery: battery,
                    power: power,
                    clipboard: clipboard
                })[root.page]

            // Animated separately so page switches resize smoothly without
            // slowing down open/close.
            property real fullHeight: Math.min(current.implicitHeight + 32, parent.height - Appearance.barHeight - 16)

            anchors.right: parent.right
            anchors.rightMargin: 8
            y: Appearance.barHeight + 8
            width: 400
            // Open/close by revealing downward, like the Android shade. Opaque on
            // purpose: niri 26.04's non-xray blur leaves unblurred strips here
            // after rapid toggling (see .agents/docs/quickshell.md).
            height: fullHeight * root.progress
            radius: Math.min(28, height / 2)
            color: Appearance.surfaceContainer
            opacity: Math.min(1, root.progress * 2)
            clip: true
            focus: true

            Behavior on fullHeight {
                NumberAnimation {
                    duration: 350
                    easing.type: Easing.BezierSpline
                    easing.bezierCurve: [0.2, 0, 0, 1, 1, 1] // M3 emphasized
                }
            }

            Keys.forwardTo: root.page === "clipboard" ? [clipboard] : []
            Keys.onEscapePressed: {
                if (root.page === "main")
                    SPanels.quickSettings = false;
                else
                    SPanels.quickSettingsPage = "main";
            }

            // Swallow clicks so they don't reach the close-on-outside-click layer.
            MouseArea {
                anchors.fill: parent
            }

            Item {
                anchors.fill: parent
                anchors.margins: 16

                MainPage {
                    id: main
                    width: parent.width
                    opacity: root.page === "main" ? 1 : 0
                    visible: opacity > 0
                    active: SPanels.quickSettings && root.page === "main"
                    onOpen: page => SPanels.quickSettingsPage = page
                    onClose: SPanels.quickSettings = false

                    Behavior on opacity {
                        NumberAnimation {
                            duration: 200
                        }
                    }
                }

                WifiPage {
                    id: wifi
                    width: parent.width
                    opacity: root.page === "wifi" ? 1 : 0
                    visible: opacity > 0
                    onBack: SPanels.quickSettingsPage = "main"

                    Behavior on opacity {
                        NumberAnimation {
                            duration: 200
                        }
                    }
                }

                BluetoothPage {
                    id: bluetooth
                    width: parent.width
                    opacity: root.page === "bluetooth" ? 1 : 0
                    visible: opacity > 0
                    onBack: SPanels.quickSettingsPage = "main"

                    Behavior on opacity {
                        NumberAnimation {
                            duration: 200
                        }
                    }
                }

                BatteryPage {
                    id: battery
                    width: parent.width
                    opacity: root.page === "battery" ? 1 : 0
                    visible: opacity > 0
                    onBack: SPanels.quickSettingsPage = "main"

                    Behavior on opacity {
                        NumberAnimation {
                            duration: 200
                        }
                    }
                }

                PowerPage {
                    id: power
                    width: parent.width
                    opacity: root.page === "power" ? 1 : 0
                    visible: opacity > 0
                    onBack: SPanels.quickSettingsPage = "main"
                    onClose: SPanels.quickSettings = false

                    Behavior on opacity {
                        NumberAnimation {
                            duration: 200
                        }
                    }
                }

                ClipboardPage {
                    id: clipboard
                    width: parent.width
                    opacity: root.page === "clipboard" ? 1 : 0
                    visible: opacity > 0
                    shown: SPanels.quickSettings && root.page === "clipboard"
                    onBack: SPanels.quickSettingsPage = "main"
                    onClose: SPanels.quickSettings = false

                    Behavior on opacity {
                        NumberAnimation {
                            duration: 200
                        }
                    }
                }
            }
        }
    }
}
