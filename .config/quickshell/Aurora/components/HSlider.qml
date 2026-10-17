import QtQuick
import qs.config

// M3 expressive horizontal slider (Android 16/17 brightness style): active
// track | gap | tall handle | gap | inactive track with the icon at its end.
Item {
    id: root

    required property real value // 0..1
    property string icon: ""
    // Discrete slider with this many steps: values snap and stop dots are drawn. 0 = continuous.
    property int steps: 0

    signal moved(real value)

    readonly property int handleGap: 6
    readonly property int handleWidth: 4
    readonly property int outerRadius: 12
    readonly property int innerRadius: 2
    readonly property real usable: width - handleGap * 2 - handleWidth
    readonly property real activeWidth: usable * animatedValue
    property real animatedValue: value

    implicitWidth: 300
    implicitHeight: 44

    Behavior on animatedValue {
        NumberAnimation {
            duration: 120
            easing.type: Easing.OutCubic
        }
    }

    Rectangle {
        id: active
        width: root.activeWidth
        height: parent.height
        visible: width > 1
        color: Appearance.primary
        topLeftRadius: root.outerRadius
        bottomLeftRadius: root.outerRadius
        topRightRadius: root.innerRadius
        bottomRightRadius: root.innerRadius
    }

    Rectangle {
        id: handle
        x: active.width + root.handleGap
        anchors.verticalCenter: parent.verticalCenter
        width: root.handleWidth
        height: parent.height + 8
        radius: width / 2
        color: Appearance.primary
    }

    Rectangle {
        id: inactive
        anchors.right: parent.right
        width: root.usable - root.activeWidth
        height: parent.height
        visible: width > 1
        color: Appearance.secondaryContainer
        topLeftRadius: root.innerRadius
        bottomLeftRadius: root.innerRadius
        topRightRadius: root.outerRadius
        bottomRightRadius: root.outerRadius
    }

    Repeater {
        model: root.steps > 1 ? root.steps - 1 : 0

        Rectangle {
            required property int index
            readonly property real centerX: (index + 1) / root.steps * root.usable + root.handleGap + root.handleWidth / 2

            x: centerX - width / 2
            anchors.verticalCenter: parent.verticalCenter
            width: 4
            height: 4
            radius: 2
            color: centerX < handle.x ? Appearance.textOnPrimary : Appearance.textOnSecondaryContainer
            visible: Math.abs(centerX - handle.x) > root.handleGap + root.handleWidth && centerX < iconItem.x - 8
        }
    }

    MaterialSymbol {
        id: iconItem
        anchors.right: parent.right
        anchors.rightMargin: 12
        anchors.verticalCenter: parent.verticalCenter
        visible: root.icon !== ""
        name: root.icon
        size: 20
        fill: true
        color: inactive.width < parent.width - x ? Appearance.textOnPrimary : Appearance.textOnSecondaryContainer
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onPressed: mouse => root.moved(root.valueAt(mouse.x))
        onPositionChanged: mouse => root.moved(root.valueAt(mouse.x))
        onWheel: wheel => root.moved(root.snap(root.value + Math.sign(wheel.angleDelta.y) * (root.steps > 0 ? 1 / root.steps : 0.04)))
    }

    function valueAt(x: real): real {
        return snap((x - handleGap - handleWidth / 2) / usable);
    }

    function snap(value: real): real {
        value = Math.max(0, Math.min(1, value));
        return steps > 0 ? Math.round(value * steps) / steps : value;
    }
}
