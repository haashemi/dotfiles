import QtQuick
import Quickshell
import qs.config

Text {
    anchors.verticalCenter: parent.verticalCenter

    required property SystemClock clock

    color: Appearance.text
    text: Qt.formatDateTime(clock.date, "hh:mm")
    font.pixelSize: 16
    font.bold: true
    font.family: Appearance.fontMono
}