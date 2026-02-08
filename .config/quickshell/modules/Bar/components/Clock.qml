import QtQuick
import Quickshell

Text {
    required property SystemClock clock

    color: "white"
    text: Qt.formatDateTime(clock.date, "hh:mm")
    font.pixelSize: 16
    font.bold: true
}
