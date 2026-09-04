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
    property bool gpuHas: false
    property int gpuUsage: 0
    property int gpuTempC: 0
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

    // GPU: nvidia-smi where present (desktop/work), amdgpu sysfs otherwise
    // (laptop iGPU). Any failure → segment hides (gpuHas stays false).
    PollingProcess {
        interval: 3000
        active: perfWidget.visible
        command: ["sh", "-c",
            "if command -v nvidia-smi >/dev/null 2>&1; then " +
            "  nvidia-smi --query-gpu=utilization.gpu,temperature.gpu --format=csv,noheader,nounits 2>/dev/null | head -1 | tr -d ' '; " +
            "else " +
            "  for c in /sys/class/drm/card*/device; do " +
            "    if [ -r \"$c/gpu_busy_percent\" ]; then " +
            "      b=$(cat \"$c/gpu_busy_percent\"); " +
            "      t=$(cat \"$c\"/hwmon/hwmon*/temp1_input 2>/dev/null | head -1); " +
            "      echo \"$b,$(( ${t:-0} / 1000 ))\"; break; " +
            "    fi; " +
            "  done; " +
            "fi"]
        onOutput: text => {
            var parts = (text || "").trim().split(",")
            var u = parseInt(parts[0], 10)
            var t = parseInt(parts[1], 10)
            if (isNaN(u)) { perfWidget.gpuHas = false; return }
            perfWidget.gpuHas = true
            perfWidget.gpuUsage = Math.max(0, Math.min(100, u))
            perfWidget.gpuTempC = isNaN(t) ? 0 : t
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

    // Collapsed to one reading, the way the System cluster is. This used to
    // draw four segments — CPU, RAM, temp, GPU — separated by │ glyphs: eight
    // Text elements and by far the widest thing in the bar, for numbers you
    // cannot act on at a glance anyway.
    //
    // CPU is the label because it is the one that moves. The rest is a click
    // away in the panel, where it now has two minutes of history behind it.
    icon: "\uF2DB"
    label: cpuUsage + "%"

    // Goes urgent when the machine is genuinely working, so a hot box still
    // announces itself without four numbers sitting there permanently.
    readonly property bool underLoad: cpuUsage >= 85 || (gpuHas && gpuUsage >= 85)
    readonly property bool runningHot: cpuTempC >= 85 || gpuTempC >= 85
    active: underLoad || runningHot
    activeColor: runningHot ? colors.urgent : colors.primaryContainer
    activeTextColor: runningHot ? colors.textOnUrgent : colors.textOnPrimaryContainer

    // Second reading, shown only when it has something to say: memory pressure
    // is worth surfacing without a permanent seat.
    Rectangle {
        visible: perfWidget.ramPercent >= 80
        width: visible ? 6 : 0
        height: 6
        radius: 3
        anchors.verticalCenter: parent.verticalCenter
        color: perfWidget.ramPercent >= 92
            ? perfWidget.colors.urgent
            : perfWidget.colors.secondary
    }
}
