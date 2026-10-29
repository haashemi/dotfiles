pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Widgets
import qs.config
import qs.services
import qs.components

// Clipboard history: pinned entries, then the 14 newest copies. Click or Enter
// copies an entry back and closes the panel; Up/Down move, Delete removes.
// Keys arrive via Keys.forwardTo from the panel, which keeps focus.
ColumnLayout {
    id: root

    property bool shown: false
    readonly property int rowHeight: 64

    signal back
    signal close

    function activate(entry: var): void {
        SClipboard.copy(entry);
        root.close();
    }

    spacing: 12

    onShownChanged: {
        if (shown) {
            list.currentIndex = 0;
            list.positionViewAtBeginning();
        }
    }

    Keys.onUpPressed: list.decrementCurrentIndex()
    Keys.onDownPressed: list.incrementCurrentIndex()
    Keys.onReturnPressed: list.currentItem && activate(list.currentItem.modelData)
    Keys.onEnterPressed: list.currentItem && activate(list.currentItem.modelData)
    Keys.onDeletePressed: list.currentItem && SClipboard.remove(list.currentItem.modelData)

    PageHeader {
        title: "Clipboard"
        action: SClipboard.entries.some(entry => !entry.pinned) ? "delete_sweep" : ""
        onBack: root.back()
        onActionClicked: SClipboard.clear()
    }

    Text {
        Layout.fillWidth: true
        Layout.margins: 8
        visible: list.count === 0
        text: "Copied text and images show up here"
        color: Appearance.textOnSurfaceVariant
        font.family: Appearance.fontUi
        font.pixelSize: 14
    }

    ListView {
        id: list
        Layout.fillWidth: true
        Layout.preferredHeight: Math.min(contentHeight, 8 * root.rowHeight + 7 * spacing)
        visible: count > 0
        clip: true
        spacing: 4
        boundsBehavior: Flickable.StopAtBounds
        highlightMoveDuration: 0
        model: SClipboard.model

        delegate: Rectangle {
            id: item

            required property var modelData
            required property int index

            width: ListView.view.width
            height: root.rowHeight
            radius: 16
            color: Appearance.surfaceContainerHighest

            // State layer; hovering moves the keyboard selection too.
            Rectangle {
                anchors.fill: parent
                radius: parent.radius
                color: Appearance.textOnSurface
                opacity: item.ListView.isCurrentItem ? 0.08 : 0
            }

            MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onEntered: list.currentIndex = item.index
                onClicked: root.activate(item.modelData)
            }

            FileView {
                id: file
                path: item.modelData.image ? "" : item.modelData.path
            }

            Text {
                visible: !item.modelData.image
                anchors.left: parent.left
                anchors.leftMargin: 16
                anchors.right: buttons.left
                anchors.rightMargin: 8
                anchors.verticalCenter: parent.verticalCenter
                // Big copies are only previewed.
                text: file.text().slice(0, 400).trim()
                textFormat: Text.PlainText
                wrapMode: Text.Wrap
                maximumLineCount: 2
                elide: Text.ElideRight
                color: Appearance.textOnSurface
                font.family: Appearance.fontUi
                font.pixelSize: 14
            }

            ClippingRectangle {
                id: thumb
                visible: item.modelData.image
                x: 8
                y: 8
                width: buttons.x - 16
                height: parent.height - 16
                radius: 8 // concentric with the row
                color: Appearance.surfaceContainer

                Image {
                    anchors.fill: parent
                    source: item.modelData.image ? `file://${item.modelData.path}` : ""
                    sourceSize.width: thumb.width * 2
                    fillMode: Image.PreserveAspectCrop
                    asynchronous: true
                }
            }

            Row {
                id: buttons
                anchors.right: parent.right
                anchors.rightMargin: 8
                anchors.verticalCenter: parent.verticalCenter

                IconButton {
                    icon: "push_pin"
                    filled: item.modelData.pinned
                    onClicked: SClipboard.togglePin(item.modelData)
                }

                IconButton {
                    icon: "close"
                    onClicked: SClipboard.remove(item.modelData)
                }
            }
        }
    }

    component IconButton: Rectangle {
        id: button

        required property string icon
        property bool filled: false

        signal clicked

        width: 40
        height: 40
        radius: 20
        color: hover.hovered ? Qt.alpha(Appearance.textOnSurface, 0.08) : "transparent"

        HoverHandler {
            id: hover
        }

        MaterialSymbol {
            anchors.centerIn: parent
            name: button.icon
            size: 20
            fill: button.filled
            color: button.filled ? Appearance.primary : Appearance.textOnSurfaceVariant
        }

        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: button.clicked()
        }
    }
}
