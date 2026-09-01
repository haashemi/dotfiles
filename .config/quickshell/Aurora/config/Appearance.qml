pragma Singleton

import QtQuick
import Quickshell

// https://www.realtimecolors.com/?colors=deeaf3-050d14-7fbbea-0c5a95-31a4fd&fonts=Inter-Inter
Singleton {
    readonly property color text: 'white'
    readonly property color background: "#050d14"
    readonly property color primary: "#7fbbea"
    readonly property color secondary: "#0c5a95"
    readonly property color accent: "#31a4fd"

    readonly property string fontMono: "JetBrains Mono"
    readonly property string fontUi: "JetBrains Mono"
    readonly property string fontIcons: "MaterialSymbolsRounded"
    readonly property string fontPersian: "Vazirmatn"

    readonly property int barHeight: 30
    readonly property int barPillRadius: 15
    readonly property color barPillBackground: "#e6050d14"

    readonly property int animationDuration: 300
}
