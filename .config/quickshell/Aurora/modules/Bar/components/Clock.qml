import QtQuick
import qs.config
import qs.services

Text {
    anchors.verticalCenter: parent.verticalCenter
    text: Qt.formatDateTime(SClock.date, "hh:mm")
    color: Appearance.textOnSurface
    font.pixelSize: 16
    font.bold: true
    font.family: Appearance.fontUi
    font.features: { "tnum": 1 }
}
