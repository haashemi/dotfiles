pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import qs.config
import qs.services
import qs.components

// Battery details (UPower) + power mode and charge limit (asusd).
ColumnLayout {
    id: root

    signal back

    spacing: 16

    PageHeader {
        title: "Battery"
        onBack: root.back()
    }

    // Big level + status.
    RowLayout {
        Layout.fillWidth: true
        Layout.leftMargin: 8
        spacing: 16

        Text {
            text: `${SBattery.level}%`
            color: Appearance.textOnSurface
            font.family: Appearance.fontUi
            font.pixelSize: 48
            font.weight: Font.Light
            font.features: {
                "tnum": 1
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 0

            Text {
                Layout.fillWidth: true
                text: SBattery.status
                color: SBattery.isCharging ? Appearance.primary : Appearance.textOnSurface
                font.family: Appearance.fontUi
                font.pixelSize: 16
                font.weight: Font.Medium
            }

            Text {
                Layout.fillWidth: true
                visible: text !== ""
                text: SBattery.timeLeft
                color: Appearance.textOnSurfaceVariant
                font.family: Appearance.fontUi
                font.pixelSize: 13
            }
        }
    }

    // Grouped M3 list: rounded ends, 4dp gaps.
    ColumnLayout {
        Layout.fillWidth: true
        spacing: 2

        InfoRow {
            first: true
            icon: "bolt"
            label: SBattery.isCharging ? "Charging rate" : "Power draw"
            value: SBattery.rate > 0 ? `${SBattery.rate.toFixed(1)} W` : "—"
        }

        InfoRow {
            icon: "battery_full"
            label: "Energy"
            value: `${SBattery.energy.toFixed(1)} / ${SBattery.energyFull.toFixed(1)} Wh`
        }

        InfoRow {
            last: true
            icon: "health_and_safety"
            label: "Health"
            value: SBattery.health > 0 ? `${SBattery.health.toFixed(0)}% · ${SBattery.energyDesign.toFixed(1)} Wh new` : "Unknown"
        }
    }

    SectionLabel {
        visible: SAsus.available
        text: "Power mode"
    }

    // M3 expressive connected button group.
    RowLayout {
        Layout.fillWidth: true
        visible: SAsus.available
        spacing: 2

        Repeater {
            model: SAsus.profiles

            Rectangle {
                id: segment

                required property var modelData
                required property int index
                readonly property bool selected: SAsus.profile === modelData.value

                Layout.fillWidth: true
                implicitHeight: 48
                // Outer ends fully round; inner corners small, selected one fully round.
                topLeftRadius: index === 0 || selected ? 24 : 8
                bottomLeftRadius: topLeftRadius
                topRightRadius: index === SAsus.profiles.length - 1 || selected ? 24 : 8
                bottomRightRadius: topRightRadius
                color: selected ? Appearance.primary : Appearance.surfaceContainerHighest

                Behavior on color {
                    ColorAnimation {
                        duration: 150
                    }
                }

                Row {
                    anchors.centerIn: parent
                    spacing: 6

                    MaterialSymbol {
                        anchors.verticalCenter: parent.verticalCenter
                        name: segment.modelData.icon
                        size: 18
                        fill: true
                        color: segment.selected ? Appearance.textOnPrimary : Appearance.textOnSurface
                    }

                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        text: segment.modelData.name
                        color: segment.selected ? Appearance.textOnPrimary : Appearance.textOnSurface
                        font.family: Appearance.fontUi
                        font.pixelSize: 13
                        font.weight: Font.Medium
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: SAsus.setProfile(segment.modelData.value)
                }
            }
        }
    }

    SectionLabel {
        visible: SAsus.available
        text: `Charge limit · ${SAsus.chargeLimit}%`
    }

    // 50..100% in 5% steps; lower limits are kinder to the cells.
    HSlider {
        Layout.fillWidth: true
        visible: SAsus.available
        value: (SAsus.chargeLimit - 50) / 50
        steps: 10
        icon: "battery_charging_full"
        onMoved: value => {
            const limit = Math.round(50 + value * 50);
            if (limit !== SAsus.chargeLimit)
                SAsus.setChargeLimit(limit);
        }
    }

    PillButton {
        Layout.alignment: Qt.AlignRight
        visible: SAsus.available && SAsus.chargeLimit < 100
        text: "Charge to 100% once"
        icon: "battery_full"
        onClicked: SAsus.chargeFullOnce()
    }

    component SectionLabel: Text {
        Layout.fillWidth: true
        Layout.leftMargin: 8
        Layout.bottomMargin: -8
        color: Appearance.primary
        font.family: Appearance.fontUi
        font.pixelSize: 13
        font.weight: Font.Medium
    }

    component InfoRow: Rectangle {
        id: row

        required property string icon
        required property string label
        required property string value
        property bool first: false
        property bool last: false

        Layout.fillWidth: true
        implicitHeight: 52
        topLeftRadius: first ? 16 : 4
        topRightRadius: topLeftRadius
        bottomLeftRadius: last ? 16 : 4
        bottomRightRadius: bottomLeftRadius
        color: Appearance.surfaceContainerHighest

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 16
            anchors.rightMargin: 16
            spacing: 16

            MaterialSymbol {
                name: row.icon
                size: 20
                fill: true
                color: Appearance.textOnSurfaceVariant
            }

            Text {
                Layout.fillWidth: true
                text: row.label
                color: Appearance.textOnSurface
                font.family: Appearance.fontUi
                font.pixelSize: 14
            }

            Text {
                text: row.value
                color: Appearance.textOnSurfaceVariant
                font.family: Appearance.fontUi
                font.pixelSize: 14
                font.features: {
                    "tnum": 1
                }
            }
        }
    }
}
