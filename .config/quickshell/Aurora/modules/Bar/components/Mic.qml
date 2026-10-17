import QtQuick
import qs.config
import qs.components
import qs.services

MaterialSymbol {
    size: 16
    visible: SVolume.micMuted
    color: Appearance.error
    name: "mic_off"
}
