import QtQuick
import Quickshell.Io

import "."

BarPill {
    id: perfWidget
    pillIndex: 4

    property int cpuUsage: 0
    property int lastCpuTotal: 0
    property int lastCpuIdle: 0
    property int ramPercent: 0
    property int cpuTempC: 0
    property string systemMonitorCommand: "kitty -e btop"

    signal toggleRequested()

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
        command: ["sh", "-c", "awk '/MemTotal/ {t=$2} /MemAvailable/ {a=$2} END {if(t>0) printf \"%d\", int(100*(t-a)/t)}' /proc/meminfo"]
        interval: 2000
        active: perfWidget.visible
        onOutput: (text) => {
            var pct = parseInt((text || "").trim())
            if (!isNaN(pct)) perfWidget.ramPercent = Math.max(0, Math.min(100, pct))
        }
    }

    PollingProcess {
        command: ["sh", "-c", "for h in /sys/class/hwmon/hwmon*; do n=$(cat \"$h/name\" 2>/dev/null); if [ \"$n\" = \"k10temp\" ] || [ \"$n\" = \"coretemp\" ] || [ \"$n\" = \"zenpower\" ]; then awk '{print int($1/1000)}' \"$h/temp1_input\" 2>/dev/null; exit; fi; done"]
        interval: 2000
        active: perfWidget.visible
        onOutput: (text) => {
            var t = parseInt((text || "").trim())
            if (!isNaN(t)) perfWidget.cpuTempC = t
        }
    }

    Process {
        id: runMonitor
        command: perfWidget.systemMonitorCommand.trim().split(/\s+/).filter(function(s) { return s.length > 0 })
        running: false
    }

    onClicked: mouse => {
        if (mouse.button === Qt.MiddleButton) runMonitor.running = true
        else perfWidget.toggleRequested()
    }

    // Segmented CPU | RAM | TEMP content (icons accent-tinted like BarPill's own).
    Row {
        spacing: 3
        anchors.verticalCenter: parent.verticalCenter
        Text { text: "\uF2DB"; color: perfWidget.iconFg; font.pixelSize: colors.cpuFontSize; font.family: colors.widgetIconFont }
        Text { text: perfWidget.cpuUsage + "%"; color: perfWidget.fg; font.pixelSize: colors.cpuFontSize }
    }
    Text {
        text: "│"
        anchors.verticalCenter: parent.verticalCenter
        color: Qt.rgba(perfWidget.fg.r, perfWidget.fg.g, perfWidget.fg.b, 0.35)
        font.pixelSize: colors.cpuFontSize
    }
    Row {
        spacing: 3
        anchors.verticalCenter: parent.verticalCenter
        Text { text: "\uF538"; color: perfWidget.iconFg; font.pixelSize: colors.cpuFontSize; font.family: colors.widgetIconFont }
        Text { text: perfWidget.ramPercent + "%"; color: perfWidget.fg; font.pixelSize: colors.cpuFontSize }
    }
    Text {
        text: "│"
        anchors.verticalCenter: parent.verticalCenter
        visible: perfWidget.cpuTempC > 0
        color: Qt.rgba(perfWidget.fg.r, perfWidget.fg.g, perfWidget.fg.b, 0.35)
        font.pixelSize: colors.cpuFontSize
    }
    Row {
        spacing: 3
        visible: perfWidget.cpuTempC > 0
        anchors.verticalCenter: parent.verticalCenter
        Text { text: "\uF2C7"; color: perfWidget.iconFg; font.pixelSize: colors.cpuFontSize; font.family: colors.widgetIconFont }
        Text { text: perfWidget.cpuTempC + "°"; color: perfWidget.fg; font.pixelSize: colors.cpuFontSize }
    }
}
