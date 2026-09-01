import QtQuick
import qs.config
import qs.components
import qs.services

MaterialSymbol {
    required property SMicrophone microphone

    size: 16
    visible: microphone.muted
    color: "#ff4d4d"
    name: "mic_off"
}