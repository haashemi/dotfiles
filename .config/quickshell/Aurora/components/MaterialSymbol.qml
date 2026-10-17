import QtQuick
import qs.config

Text {
    required property string name
    required property int size
    property bool fill: false

    text: name
    font {
        family: Appearance.fontIcons
        pixelSize: size
        variableAxes: ({ "FILL": fill ? 1 : 0 })
    }
}
