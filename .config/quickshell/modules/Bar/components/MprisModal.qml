pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import QtQuick.Effects
import QtQuick.Controls
import Quickshell
import Quickshell.Widgets
import Quickshell.Services.Mpris

Scope {
    id: root
    required property bool showPanel
    required property MprisPlayer player

    Timer {
        interval: 0
        running: root.showPanel
        onTriggered: loader.active = true
    }

    Timer {
        interval: 100
        running: !root.showPanel
        onTriggered: loader.active = false
    }

    LazyLoader {
        id: loader

        PanelWindow {
            id: panel
            implicitWidth: panel.viewPanel ? 450 : 0
            implicitHeight: panel.viewPanel ? 140 : 0
            anchors.top: true
            anchors.left: true
            margins.top: 11
            margins.left: 10
            color: "transparent"

            property bool viewPanel: false

            Timer {
                interval: 0
                running: loader.active
                onTriggered: panel.viewPanel = true
            }
            Timer {
                interval: 0
                running: !root.showPanel
                onTriggered: panel.viewPanel = false
            }

            ClippingRectangle {
                anchors.fill: parent
                radius: 10

                ClippingRectangle {
                    anchors.fill: parent

                    Image {
                        width: panel.implicitWidth
                        height: panel.implicitWidth
                        anchors.verticalCenter: parent.verticalCenter
                        scale: 1.3
                        source: Qt.resolvedUrl(root.player.trackArtUrl)
                        layer.enabled: true
                        layer.effect: MultiEffect {
                            autoPaddingEnabled: true
                            blur: 0.8
                            blurEnabled: true
                            colorization: 1
                            colorizationColor: '#9d000000'
                        }
                    }
                }

                Row {
                    anchors.fill: parent
                    anchors.leftMargin: 5
                    anchors.rightMargin: 5
                    spacing: 10
                    ClippingRectangle {
                        anchors.verticalCenter: parent.verticalCenter
                        width: parent.height - 10
                        height: parent.height - 10
                        radius: 16
                        Image {
                            width: parent.height
                            height: parent.height
                            source: Qt.resolvedUrl(root.player.trackArtUrl)
                        }
                    }
                    ClippingRectangle {
                        width: parent.width - parent.height - 10
                        height: 120
                        color: "transparent"

                        Column {
                            anchors.fill: parent
                            anchors.topMargin: 10
                            anchors.bottomMargin: 10
                            spacing: 15
                            Column {
                                Text {
                                    text: root.player.trackTitle
                                    color: "white"
                                    font.pixelSize: 16
                                }

                                Text {
                                    text: root.player.trackArtists
                                    color: '#c7c7c7'
                                }
                            }

                            Slider {
                                id: control
                                width: parent.width
                                onMoved: root.player.position = control.value

                                from: 0
                                value: root.player.position
                                to: root.player.length

                                background: Rectangle {
                                    height: control.hovered ? 16 : 6
                                    radius: height / 2
                                    anchors.verticalCenter: parent.verticalCenter
                                    opacity: 0.5
                                    color: '#000000'

                                    Behavior on height {
                                        NumberAnimation {
                                            duration: 100
                                            easing: Easing.OutCubic
                                        }
                                    }
                                }
                                handle: Rectangle {
                                    width: control.hovered ? 6 : 4
                                    height: 20
                                    radius: 2

                                    x: control.leftPadding + control.visualPosition * (control.availableWidth - width)
                                    y: control.topPadding + control.availableHeight / 2 - height / 2

                                    anchors.verticalCenter: parent.verticalCenter
                                    color: "white"

                                    Behavior on width {
                                        NumberAnimation {
                                            duration: 100
                                            easing: Easing.OutCubic
                                        }
                                    }
                                }

                                FrameAnimation {
                                    running: root.player.playbackState == MprisPlaybackState.Playing
                                    onTriggered: root.player.positionChanged()
                                }
                            }

                            FlexboxLayout {
                                width: parent.width
                                anchors.horizontalCenter: parent.horizontalCenter
                                direction: FlexboxLayout.Row
                                justifyContent: FlexboxLayout.JustifySpaceEvenly

                                RoundButton {
                                    implicitWidth: 25
                                    implicitHeight: 25
                                    contentItem: IconImage {
                                        implicitSize: 10
                                        source: Quickshell.iconPath("media-skip-backward-symbolic")
                                    }
                                    onClicked: root.player.previous()
                                }

                                RoundButton {
                                    implicitWidth: 25
                                    implicitHeight: 25
                                    contentItem: IconImage {
                                        implicitSize: 10
                                        source: Quickshell.iconPath(root.player.isPlaying ? "media-playback-pause-symbolic" : "media-playback-start-symbolic")
                                    }
                                    onClicked: root.player.isPlaying ? root.player.pause() : root.player.play()
                                }

                                RoundButton {
                                    implicitWidth: 25
                                    implicitHeight: 25
                                    contentItem: IconImage {
                                        implicitSize: 10
                                        source: Quickshell.iconPath("media-skip-forward-symbolic")
                                    }
                                    onClicked: root.player.next()
                                }
                            }
                        }
                    }
                }

                AbstractButton {
                    anchors.top: parent.top
                    anchors.right: parent.right
                    anchors.topMargin: 10
                    anchors.rightMargin: 10
                    width: 25
                    height: 25
                    contentItem: Rectangle {
                        anchors.fill: parent
                        radius: 10
                        color: '#8e000000'
                        IconImage {
                            anchors.fill: parent
                            source: Quickshell.iconPath("window-close-symbolic")
                        }
                    }
                    onClicked: root.showPanel = false
                }
            }

            Behavior on implicitWidth {
                NumberAnimation {
                    duration: 100
                    easing.type: Easing.OutQuart
                }
            }
            Behavior on implicitHeight {
                NumberAnimation {
                    duration: 100
                    easing.type: Easing.OutQuart
                }
            }
        }
    }
}
