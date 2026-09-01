import QtQuick
import qs.config
import qs.components
import qs.services

MaterialSymbol {
    required property SVolume volume

    size: 16
    color: Appearance.text

    name: {
        const level = volume.level;
        if (level === 0)
            return "no_sound";
        if (level <= 35)
            return "volume_mute";
        if (level <= 65)
            return "volume_down";
        return "volume_up";
    }
}