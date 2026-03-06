import QtQuick

Text {
    required property string name
    required property int size

    text: name
    font {
        family: "MaterialSymbolsRounded"
        pixelSize: size
    }
}
