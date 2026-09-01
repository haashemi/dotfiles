import QtQuick
import qs.config

Text {
    required property string name
    required property int size

    text: name
    font {
        family: Appearance.fontIcons
        pixelSize: size
    }
}
