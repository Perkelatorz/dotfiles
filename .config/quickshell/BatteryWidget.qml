import QtQuick

import "."

BarPill {
    id: batteryWidget
    pillIndex: 5

    readonly property bool hasBattery: SystemServices.batteryHas
    readonly property int capacity: SystemServices.batteryCapacity
    readonly property string status: SystemServices.batteryStatus
    readonly property bool lowBattery: hasBattery && status !== "Charging" && capacity < 15

    icon: {
        if (status === "Charging") return "\uF0E7"
        if (capacity <= 10) return "\uF244"
        if (capacity <= 25) return "\uF243"
        if (capacity <= 50) return "\uF242"
        if (capacity <= 75) return "\uF241"
        return "\uF240"
    }
    label: capacity + "%"
    present: hasBattery
    interactive: false

    // Low battery: urgent accent + pulse.
    active: lowBattery
    activeColor: colors.urgent
    activeTextColor: colors.textOnUrgent
    SequentialAnimation {
        loops: Animation.Infinite
        running: batteryWidget.lowBattery
        NumberAnimation { target: batteryWidget; property: "opacity"; from: 1; to: 0.5; duration: 800; easing.type: Easing.InOutSine }
        NumberAnimation { target: batteryWidget; property: "opacity"; from: 0.5; to: 1; duration: 800; easing.type: Easing.InOutSine }
        onRunningChanged: if (!running) batteryWidget.opacity = 1
    }
}
