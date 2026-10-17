pragma Singleton

import QtQuick
import Quickshell

// M3 dark scheme from seed #7fbbea — keep in sync with AGENTS.md.
Singleton {
    readonly property color primary: "#9ccbfb"
    readonly property color textOnPrimary: "#003352"
    readonly property color primaryContainer: "#0f4a73"
    readonly property color textOnPrimaryContainer: "#cfe5ff"
    readonly property color secondaryContainer: "#3a4857"
    readonly property color textOnSecondaryContainer: "#d6e4f7"
    readonly property color error: "#ffb4ab"
    readonly property color surface: "#101418"
    readonly property color surfaceContainer: "#1d2024"
    readonly property color surfaceContainerHigh: "#272a2f"
    readonly property color textOnSurface: "#e0e2e8"
    readonly property color textOnSurfaceVariant: "#c2c7cf"

    // Persian/Arabic + Latin in one family; its Latin is Roboto-derived, so it reads as stock M3.
    readonly property string fontUi: "Vazirmatn"
    readonly property string fontIcons: "Material Symbols Rounded"

    readonly property int barHeight: 30

    readonly property int animationDuration: 300
}
