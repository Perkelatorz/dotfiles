import QtQuick
import Quickshell.Io

import "."

Item {
    id: batteryWidget
    required property var colors
    property int pillIndex: 5

    readonly property bool lowBattery: hasBattery && status !== "Charging" && capacity < 15
    readonly property color pillColor: lowBattery ? colors.urgent : ((colors.widgetPillColors && pillIndex >= 0 && pillIndex < colors.widgetPillColors.length) ? colors.widgetPillColors[pillIndex] : colors.primary)
    readonly property color pillTextColor: lowBattery ? colors.textOnUrgent : ((colors.widgetTextOnPillColors && pillIndex >= 0 && pillIndex < colors.widgetTextOnPillColors.length) ? colors.widgetTextOnPillColors[pillIndex] : colors.textMain)

    property bool hasBattery: false
    property int capacity: 0
    property string status: ""

    implicitWidth: hasBattery ? pill.width : 0
    implicitHeight: hasBattery ? 28 : 0
    visible: hasBattery

    Process {
        id: batteryProc
        command: ["sh", "-c", "d=$(ls -d /sys/class/power_supply/BAT* 2>/dev/null | head -1); if [ -n \"$d\" ] && [ -r \"$d/capacity\" ]; then echo 1; cat \"$d/capacity\" 2>/dev/null; cat \"$d/status\" 2>/dev/null; else echo 0; fi"]
        stdout: StdioCollector {
            onStreamFinished: {
                var lines = (batteryProc.stdout.text || "").trim().split(/\n/)
                if (lines.length >= 1 && lines[0] === "1") {
                    batteryWidget.hasBattery = true
                    if (lines.length >= 2) {
                        var p = parseInt(lines[1], 10)
                        batteryWidget.capacity = isNaN(p) ? 0 : Math.max(0, Math.min(100, p))
                    }
                    if (lines.length >= 3)
                        batteryWidget.status = String(lines[2]).trim()
                } else {
                    batteryWidget.hasBattery = false
                }
                batteryProc.running = false
            }
        }
    }

    Timer {
        interval: 60000
        repeat: true
        running: batteryWidget.hasBattery
        onTriggered: batteryProc.running = true
    }

    Process {
        id: openPowerSettings
        command: ["xdg-open", "power"]
        running: false
    }

    Component.onCompleted: batteryProc.running = true

    Rectangle {
        id: pill
        height: batteryWidget.implicitHeight - (colors.widgetPillPaddingV) * 2
        width: row.implicitWidth + (colors.widgetPillPaddingH) * 2
        anchors.verticalCenter: parent.verticalCenter
        radius: colors.widgetPillRadius
        color: batteryHover.pressed ? Qt.darker(batteryWidget.pillColor, 1.15) : batteryHover.containsMouse ? Qt.lighter(batteryWidget.pillColor, 1.2) : batteryWidget.pillColor
        border.width: 1
        border.color: batteryHover.containsMouse ? Qt.lighter(batteryWidget.pillColor, 1.4) : batteryWidget.pillColor
        scale: batteryHover.pressed ? 0.94 : 1.0
        visible: batteryWidget.hasBattery
        Behavior on color { ColorAnimation { duration: 100 } }
        Behavior on border.color { ColorAnimation { duration: 100 } }
        Behavior on scale { NumberAnimation { duration: 80; easing.type: Easing.OutCubic } }

        SequentialAnimation {
            id: lowBatteryPulse
            loops: Animation.Infinite
            running: batteryWidget.lowBattery
            NumberAnimation { target: pill; property: "opacity"; from: 1; to: 0.5; duration: 800; easing.type: Easing.InOutSine }
            NumberAnimation { target: pill; property: "opacity"; from: 0.5; to: 1; duration: 800; easing.type: Easing.InOutSine }
            onRunningChanged: if (!running) pill.opacity = 1
        }

        MouseArea {
            id: batteryHover
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            acceptedButtons: Qt.RightButton
            onClicked: openPowerSettings.running = true
        }
        Row {
            id: row
            anchors.centerIn: parent
            spacing: 4
            Text {
                text: {
                    if (batteryWidget.status === "Charging") return "\uF0E7"
                    if (batteryWidget.capacity <= 10) return "\uF244"
                    if (batteryWidget.capacity <= 25) return "\uF243"
                    if (batteryWidget.capacity <= 50) return "\uF242"
                    if (batteryWidget.capacity <= 75) return "\uF241"
                    return "\uF240"
                }
                color: batteryWidget.pillTextColor
                font.pixelSize: colors.cpuFontSize
                font.family: colors.widgetIconFont
            }
            Text {
                text: batteryWidget.capacity + "%"
                color: batteryWidget.pillTextColor
                font.pixelSize: colors.cpuFontSize
            }
        }
        Rectangle {
            opacity: batteryHover.containsMouse ? 1 : 0
            visible: opacity > 0
            Behavior on opacity { NumberAnimation { duration: 150; easing.type: Easing.OutCubic } }
            anchors.bottom: parent.top
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottomMargin: 4
            width: tipText.implicitWidth + 12
            height: tipText.implicitHeight + 6
            radius: 4
            color: colors.surface
            border.width: 1
            border.color: colors.border
            z: 1000
            Text {
                id: tipText
                anchors.centerIn: parent
                text: batteryWidget.status === "Charging" ? "Charging" : (batteryWidget.capacity + "% remaining")
                color: colors.textMain
                font.pixelSize: colors.fontSize - 1
            }
        }
    }
}
