import QtQuick
import qs.config
import qs.components
import qs.services

MaterialSymbol {
    required property SBrightness brightness

    size: 16
    color: Appearance.text

    name: {
        const level = brightness.level;
        if (level === 0)
            return "brightness_1";
        if (level <= 20)
            return "brightness_2";
        if (level <= 40)
            return "brightness_3";
        if (level <= 60)
            return "brightness_4";
        if (level <= 80)
            return "brightness_5";
        if (level <= 99)
            return "brightness_6";
        return "brightness_7";
    }
}