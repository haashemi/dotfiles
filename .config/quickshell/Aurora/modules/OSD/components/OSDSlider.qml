import QtQuick
import qs.config
import qs.components

// Android 16 expressive vertical slider: inactive track on top, a 4dp handle
// bar overhanging the track with 6dp gaps, active track at the bottom.
Item {
    id: root

    required property real value // 0..1
    required property string icon
    // Discrete slider with this many steps (e.g. a 0..3 keyboard backlight):
    // values snap and stop dots are drawn. 0 = continuous.
    property int steps: 0

    signal moved(real value)

    readonly property int handleGap: 6
    readonly property int handleThickness: 4
    readonly property int handleWidth: 52
    readonly property int outerRadius: 12
    readonly property int innerRadius: 2
    readonly property int iconTop: 10
    readonly property int iconSize: 20
    readonly property real usable: height - handleGap * 2 - handleThickness
    readonly property real activeHeight: usable * animatedValue
    property real animatedValue: value

    implicitWidth: 40
    implicitHeight: 250

    Behavior on animatedValue {
        NumberAnimation {
            duration: 120
            easing.type: Easing.OutCubic
        }
    }

    Rectangle {
        id: inactive
        anchors.top: parent.top
        width: parent.width
        height: root.usable - root.activeHeight
        visible: height > 1
        color: Appearance.textOnPrimary
        topLeftRadius: root.outerRadius
        topRightRadius: root.outerRadius
        bottomLeftRadius: root.innerRadius
        bottomRightRadius: root.innerRadius
    }

    Rectangle {
        id: handle
        anchors.horizontalCenter: parent.horizontalCenter
        y: inactive.height + root.handleGap
        width: root.handleWidth
        height: root.handleThickness
        radius: height / 2
        color: Appearance.primary
    }

    Rectangle {
        anchors.bottom: parent.bottom
        width: parent.width
        height: root.activeHeight
        visible: height > 1
        color: Appearance.primary
        topLeftRadius: root.innerRadius
        topRightRadius: root.innerRadius
        bottomLeftRadius: root.outerRadius
        bottomRightRadius: root.outerRadius
    }

    // Stop indicators at each inner step, hidden where they'd touch the icon or handle.
    Repeater {
        model: root.steps > 1 ? root.steps - 1 : 0

        Rectangle {
            required property int index
            readonly property real centerY: (1 - (index + 1) / root.steps) * root.usable + root.handleGap + root.handleThickness / 2
            readonly property bool onActive: centerY > handle.y

            anchors.horizontalCenter: parent.horizontalCenter
            y: centerY - height / 2
            width: 4
            height: 4
            radius: 2
            color: onActive ? Appearance.textOnPrimary : Appearance.primary
            visible: Math.abs(centerY - (handle.y + handle.height / 2)) > root.handleGap + root.handleThickness && centerY > root.iconTop + root.iconSize + 4
        }
    }

    MaterialSymbol {
        anchors.horizontalCenter: parent.horizontalCenter
        y: root.iconTop
        name: root.icon
        size: root.iconSize
        fill: true
        // Flip to on-primary once the handle/active track slides under the icon.
        color: inactive.height < y + height ? Appearance.textOnPrimary : Appearance.primary
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onPressed: mouse => root.moved(root.valueAt(mouse.y))
        onPositionChanged: mouse => root.moved(root.valueAt(mouse.y))
        onWheel: wheel => root.moved(root.snap(root.value + Math.sign(wheel.angleDelta.y) * (root.steps > 0 ? 1 / root.steps : 0.04)))
    }

    function valueAt(y: real): real {
        return snap(1 - (y - handleGap - handleThickness / 2) / usable);
    }

    function snap(value: real): real {
        value = Math.max(0, Math.min(1, value));
        return steps > 0 ? Math.round(value * steps) / steps : value;
    }
}
