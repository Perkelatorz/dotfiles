import QtQuick
import Quickshell.Io

import "."

Item {
    id: perfWidget
    required property var colors
    property int pillIndex: 4

    readonly property color pillColor: (colors.widgetPillColors && pillIndex >= 0 && pillIndex < colors.widgetPillColors.length) ? colors.widgetPillColors[pillIndex] : colors.primary
    readonly property color pillTextColor: (colors.widgetTextOnPillColors && pillIndex >= 0 && pillIndex < colors.widgetTextOnPillColors.length) ? colors.widgetTextOnPillColors[pillIndex] : colors.textMain

    property int cpuUsage: 0
    property int lastCpuTotal: 0
    property int lastCpuIdle: 0
    property int ramPercent: 0
    property string ramUsed: ""
    property string ramTotal: ""
    property int cpuTempC: 0

    signal toggleRequested()

    implicitWidth: pill.width
    implicitHeight: 28

    PollingProcess {
        command: ["sh", "-c", "head -1 /proc/stat"]
        interval: 2000
        active: perfWidget.visible
        onOutput: (text) => {
            if (!text) return
            var p = text.trim().split(/\s+/)
            if (p.length < 9) return
            var idle = parseInt(p[4]) + parseInt(p[5])
            var total = 0
            for (var i = 1; i <= 8; i++) total += parseInt(p[i])
            if (perfWidget.lastCpuTotal > 0) {
                var dTotal = total - perfWidget.lastCpuTotal
                var dIdle = idle - perfWidget.lastCpuIdle
                if (dTotal > 0) {
                    var u = Math.round(100 * (1 - dIdle / dTotal))
                    perfWidget.cpuUsage = Math.max(0, Math.min(100, u))
                }
            }
            perfWidget.lastCpuTotal = total
            perfWidget.lastCpuIdle = idle
        }
    }

    PollingProcess {
        command: ["sh", "-c", "awk '/MemTotal/ {t=$2} /MemAvailable/ {a=$2} END {if(t>0) {u=t-a; printf \"%d %d %d\", int(100*u/t), int(u/1024), int(t/1024)}}' /proc/meminfo"]
        interval: 2000
        active: perfWidget.visible
        onOutput: (text) => {
            if (!text) return
            var parts = text.trim().split(/\s+/)
            if (parts.length < 3) return
            var pct = parseInt(parts[0])
            if (!isNaN(pct)) perfWidget.ramPercent = Math.max(0, Math.min(100, pct))
            var usedMB = parseInt(parts[1])
            var totalMB = parseInt(parts[2])
            if (!isNaN(usedMB)) perfWidget.ramUsed = usedMB >= 1024 ? (usedMB / 1024).toFixed(1) + "G" : usedMB + "M"
            if (!isNaN(totalMB)) perfWidget.ramTotal = totalMB >= 1024 ? (totalMB / 1024).toFixed(1) + "G" : totalMB + "M"
        }
    }

    PollingProcess {
        command: ["sh", "-c", "for h in /sys/class/hwmon/hwmon*; do n=$(cat \"$h/name\" 2>/dev/null); if [ \"$n\" = \"k10temp\" ] || [ \"$n\" = \"coretemp\" ] || [ \"$n\" = \"zenpower\" ]; then awk '{print int($1/1000)}' \"$h/temp1_input\" 2>/dev/null; exit; fi; done"]
        interval: 2000
        active: perfWidget.visible
        onOutput: (text) => {
            if (!text) return
            var t = parseInt(text.trim())
            if (!isNaN(t)) perfWidget.cpuTempC = t
        }
    }

    property string systemMonitorCommand: "kitty -e btop"

    Process {
        id: runMonitor
        command: systemMonitorCommand.trim().split(/\s+/).filter(function(s) { return s.length > 0 })
        running: false
    }

    Rectangle {
        id: pill
        height: perfWidget.implicitHeight - colors.widgetPillPaddingV * 2
        width: Math.max(row.implicitWidth + colors.widgetPillPaddingH * 2, 80)
        anchors.verticalCenter: parent.verticalCenter
        radius: colors.widgetPillRadius
        color: mouseArea.pressed ? Qt.darker(perfWidget.pillColor, 1.15) : mouseArea.containsMouse ? Qt.lighter(perfWidget.pillColor, 1.2) : perfWidget.pillColor
        border.width: 1
        border.color: mouseArea.containsMouse ? Qt.lighter(perfWidget.pillColor, 1.4) : perfWidget.pillColor
        scale: mouseArea.pressed ? 0.94 : 1.0
        Behavior on color { ColorAnimation { duration: 100 } }
        Behavior on border.color { ColorAnimation { duration: 100 } }
        Behavior on scale { NumberAnimation { duration: 80; easing.type: Easing.OutCubic } }

        MouseArea {
            id: mouseArea
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            acceptedButtons: Qt.LeftButton | Qt.MiddleButton
            onClicked: (mouse) => {
                if (mouse.button === Qt.MiddleButton) {
                    runMonitor.running = true
                } else {
                    perfWidget.toggleRequested()
                }
            }
        }
        Row {
            id: row
            anchors.centerIn: parent
            spacing: 6
            Row {
                spacing: 3
                Text {
                    text: "\uF2DB"
                    color: perfWidget.pillTextColor
                    font.pixelSize: colors.cpuFontSize
                    font.family: colors.widgetIconFont
                }
                Text {
                    text: perfWidget.cpuUsage + "%"
                    color: perfWidget.pillTextColor
                    font.pixelSize: colors.cpuFontSize
                }
            }
            Text {
                text: "\u2502"
                color: Qt.rgba(perfWidget.pillTextColor.r, perfWidget.pillTextColor.g, perfWidget.pillTextColor.b, 0.4)
                font.pixelSize: colors.cpuFontSize
            }
            Row {
                spacing: 3
                Text {
                    text: "\uF538"
                    color: perfWidget.pillTextColor
                    font.pixelSize: colors.cpuFontSize
                    font.family: colors.widgetIconFont
                }
                Text {
                    text: perfWidget.ramPercent + "%"
                    color: perfWidget.pillTextColor
                    font.pixelSize: colors.cpuFontSize
                }
            }
            Text {
                text: "\u2502"
                color: Qt.rgba(perfWidget.pillTextColor.r, perfWidget.pillTextColor.g, perfWidget.pillTextColor.b, 0.4)
                font.pixelSize: colors.cpuFontSize
                visible: perfWidget.cpuTempC > 0
            }
            Row {
                spacing: 3
                visible: perfWidget.cpuTempC > 0
                Text {
                    text: "\uF2C7"
                    color: perfWidget.pillTextColor
                    font.pixelSize: colors.cpuFontSize
                    font.family: colors.widgetIconFont
                }
                Text {
                    text: perfWidget.cpuTempC + "\u00B0"
                    color: perfWidget.pillTextColor
                    font.pixelSize: colors.cpuFontSize
                }
            }
        }
        Rectangle {
            opacity: mouseArea.containsMouse ? 1 : 0
            visible: opacity > 0
            Behavior on opacity { NumberAnimation { duration: 150; easing.type: Easing.OutCubic } }
            anchors.bottom: parent.top
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottomMargin: 4
            width: perfTip.implicitWidth + 12
            height: perfTip.implicitHeight + 6
            radius: 4
            color: colors.surface
            border.width: 1
            border.color: colors.border
            z: 1000
            Text {
                id: perfTip
                anchors.centerIn: parent
                text: "CPU " + perfWidget.cpuUsage + "%  •  RAM " + (perfWidget.ramUsed || "?") + " / " + (perfWidget.ramTotal || "?") + " (" + perfWidget.ramPercent + "%)" + (perfWidget.cpuTempC > 0 ? "  •  TEMP " + perfWidget.cpuTempC + "°C" : "")
                color: colors.textMain
                font.pixelSize: colors.fontSize - 1
            }
        }
    }
}
