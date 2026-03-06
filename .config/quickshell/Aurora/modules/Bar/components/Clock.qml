import QtQuick
import Quickshell

Text {
    anchors.verticalCenter: parent.verticalCenter

    required property SystemClock clock

    color: "white"
    text: Qt.formatDateTime(clock.date, "hh:mm")
    font.pixelSize: 16
    font.bold: true
}
