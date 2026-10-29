pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Widgets
import qs.config
import qs.services
import qs.components

// App launcher in the middle of the screen (Mod+D, IPC "launcher"): a search
// bar over the apps, most launched first. Up/Down move, Enter launches; Esc or
// a click outside closes. A full-screen transparent layer catches outside clicks.
// The window exists only while shown (LazyLoader): it costs ~55ms on the first
// open but keeps tens of MB out of the idle shell. App list and usage counts
// stay loaded in SLauncher.
Scope {
    id: root

    readonly property int rowHeight: 48
    readonly property int rows: 8

    property string query: ""
    readonly property var results: SLauncher.search(query)

    readonly property int fullWidth: 560
    readonly property int fullHeight: 16 + 56 + 8 + rows * rowHeight + 16

    property real progress: SPanels.launcher ? 1 : 0

    // One curve both ways (M3 standard), short.
    Behavior on progress {
        NumberAnimation {
            duration: 200
            easing.type: Easing.BezierSpline
            easing.bezierCurve: [0.2, 0, 0, 1, 1, 1]
        }
    }

    Connections {
        target: SPanels
        function onLauncherChanged() {
            if (SPanels.launcher)
                root.query = "";
        }
    }

    function launch(entry: DesktopEntry): void {
        SPanels.launcher = false;
        SLauncher.launch(entry);
    }

    LazyLoader {
        active: root.progress > 0

        PanelWindow {
            anchors.top: true
            anchors.bottom: true
            anchors.left: true
            anchors.right: true
            exclusionMode: ExclusionMode.Ignore
            color: "transparent"
            WlrLayershell.layer: WlrLayer.Overlay
            WlrLayershell.namespace: "aurora-launcher"
            WlrLayershell.keyboardFocus: SPanels.launcher ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None
            BackgroundEffect.blurRegion: Region {
                item: panel
                radius: panel.radius
            }

            MouseArea {
                anchors.fill: parent
                onClicked: SPanels.launcher = false
            }

            // Zooms in from the center. The compositor blur can't fade, so the
            // surface never fades either: it grows by real width/height (not a
            // transform), and the blur region follows that shape every frame.
            // Only the content fades.
            Rectangle {
                id: panel

                readonly property real zoom: 0.85 + 0.15 * root.progress

                anchors.centerIn: parent
                width: Math.round(root.fullWidth * zoom)
                height: Math.round(root.fullHeight * zoom)
                radius: 28 * zoom
                color: Qt.alpha(Appearance.surfaceContainer, 0.7)

                // Swallow clicks so they don't reach the close-on-outside-click layer.
                MouseArea {
                    anchors.fill: parent
                }

                Column {
                    id: column
                    anchors.centerIn: parent
                    width: root.fullWidth - 32
                    height: root.fullHeight - 32
                    spacing: 8
                    scale: panel.zoom
                    opacity: root.progress

                    // M3 search bar.
                    Rectangle {
                        width: parent.width
                        height: 56
                        radius: height / 2
                        color: Qt.alpha(Appearance.surfaceContainerHighest, 0.7)

                        MaterialSymbol {
                            id: searchIcon
                            anchors.left: parent.left
                            anchors.leftMargin: 16
                            anchors.verticalCenter: parent.verticalCenter
                            name: "search"
                            size: 24
                            color: Appearance.textOnSurfaceVariant
                        }

                        TextInput {
                            id: input
                            anchors.left: searchIcon.right
                            anchors.right: parent.right
                            anchors.leftMargin: 16
                            anchors.rightMargin: 20
                            anchors.verticalCenter: parent.verticalCenter
                            color: Appearance.textOnSurface
                            selectionColor: Appearance.primaryContainer
                            selectedTextColor: Appearance.textOnPrimaryContainer
                            font.family: Appearance.fontUi
                            font.pixelSize: 16
                            clip: true
                            focus: true
                            text: root.query
                            onTextChanged: root.query = text

                            Keys.onUpPressed: list.decrementCurrentIndex()
                            Keys.onDownPressed: list.incrementCurrentIndex()
                            Keys.onTabPressed: list.incrementCurrentIndex()
                            Keys.onBacktabPressed: list.decrementCurrentIndex()
                            Keys.onReturnPressed: list.currentItem && root.launch(list.currentItem.modelData)
                            Keys.onEnterPressed: list.currentItem && root.launch(list.currentItem.modelData)
                            Keys.onEscapePressed: SPanels.launcher = false

                            Text {
                                anchors.verticalCenter: parent.verticalCenter
                                visible: !input.text
                                text: "Search apps"
                                color: Appearance.textOnSurfaceVariant
                                font: input.font
                            }
                        }
                    }

                    // Fixed height, so the panel keeps its shape while typing.
                    ListView {
                        id: list
                        width: parent.width
                        height: root.rows * root.rowHeight
                        clip: true
                        boundsBehavior: Flickable.StopAtBounds
                        highlightMoveDuration: 150
                        highlightResizeDuration: 0
                        model: ScriptModel {
                            values: root.results
                        }

                        // Typing reorders rows; the selection goes back to the top match.
                        Connections {
                            target: root
                            function onResultsChanged() {
                                Qt.callLater(() => {
                                    list.currentIndex = 0;
                                    list.positionViewAtBeginning();
                                });
                            }
                        }

                        highlight: Rectangle {
                            radius: root.rowHeight / 2
                            color: Appearance.primaryContainer
                        }

                        add: Transition {
                            NumberAnimation {
                                property: "opacity"
                                from: 0
                                to: 1
                                duration: 150
                            }
                        }
                        displaced: Transition {
                            NumberAnimation {
                                property: "y"
                                duration: 200
                                easing.type: Easing.BezierSpline
                                easing.bezierCurve: [0.05, 0.7, 0.1, 1, 1, 1]
                            }
                            NumberAnimation {
                                property: "opacity"
                                to: 1
                                duration: 150
                            }
                        }

                        delegate: Item {
                            id: row

                            required property DesktopEntry modelData
                            required property int index
                            readonly property bool current: ListView.isCurrentItem
                            readonly property string icon: Quickshell.iconPath(modelData.icon, true)

                            width: ListView.view.width
                            height: root.rowHeight

                            // Hover state layer; the selection pill is the list's highlight.
                            Rectangle {
                                anchors.fill: parent
                                radius: height / 2
                                color: Appearance.textOnSurface
                                opacity: mouse.containsMouse && !row.current ? 0.08 : 0
                            }

                            IconImage {
                                id: appIcon
                                anchors.left: parent.left
                                anchors.leftMargin: 12
                                anchors.verticalCenter: parent.verticalCenter
                                implicitSize: 32
                                visible: row.icon !== ""
                                source: row.icon
                            }

                            MaterialSymbol {
                                anchors.centerIn: appIcon
                                visible: row.icon === ""
                                name: "apps"
                                size: 28
                                color: row.current ? Appearance.textOnPrimaryContainer : Appearance.textOnSurfaceVariant
                            }

                            Text {
                                anchors.left: appIcon.right
                                anchors.right: parent.right
                                anchors.leftMargin: 16
                                anchors.rightMargin: 16
                                anchors.verticalCenter: parent.verticalCenter
                                text: row.modelData.name
                                elide: Text.ElideRight
                                color: row.current ? Appearance.textOnPrimaryContainer : Appearance.textOnSurface
                                font.family: Appearance.fontUi
                                font.pixelSize: 15

                                Behavior on color {
                                    ColorAnimation {
                                        duration: 150
                                    }
                                }
                            }

                            MouseArea {
                                id: mouse
                                anchors.fill: parent
                                hoverEnabled: true
                                // Only real pointer motion selects, so rows sliding under a
                                // still cursor while typing don't steal the selection.
                                onPositionChanged: list.currentIndex = row.index
                                onClicked: root.launch(row.modelData)
                            }
                        }

                        Text {
                            anchors.centerIn: parent
                            visible: list.count === 0
                            text: "No matching apps"
                            color: Appearance.textOnSurfaceVariant
                            font.family: Appearance.fontUi
                            font.pixelSize: 14
                        }
                    }
                }
            }
        }
    }
}
