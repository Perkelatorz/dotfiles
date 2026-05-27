import QtQuick
import Quickshell.Io

import "."

Column {
    id: perfContent
    required property var colors
    required property var onClose

    property int cpuUsage: 0
    property int lastCpuTotal: 0
    property int lastCpuIdle: 0
    property int ramPercent: 0
    property string ramUsed: ""
    property string ramTotal: ""
    property var sensorGroups: []
    property string lastError: ""
    property bool loading: true

    spacing: 8
    width: 320
    padding: 10

    function refresh() {
        perfContent.loading = true
        perfContent.lastError = ""
        cpuProc.running = true
        memProc.running = true
        sensorsProc.running = true
    }

    Component.onCompleted: refresh()

    Timer {
        interval: 2000
        running: true
        repeat: true
        onTriggered: perfContent.refresh()
    }

    Process {
        id: cpuProc
        command: ["sh", "-c", "head -1 /proc/stat"]
        running: false
        stdout: StdioCollector {
            onStreamFinished: {
                cpuProc.running = false
                var text = (cpuProc.stdout.text || "").trim()
                if (!text) return
                var p = text.split(/\s+/)
                if (p.length < 9) return
                var idle = parseInt(p[4]) + parseInt(p[5])
                var total = 0
                for (var i = 1; i <= 8; i++) total += parseInt(p[i])
                if (perfContent.lastCpuTotal > 0) {
                    var dTotal = total - perfContent.lastCpuTotal
                    var dIdle = idle - perfContent.lastCpuIdle
                    if (dTotal > 0) {
                        var u = Math.round(100 * (1 - dIdle / dTotal))
                        perfContent.cpuUsage = Math.max(0, Math.min(100, u))
                    }
                }
                perfContent.lastCpuTotal = total
                perfContent.lastCpuIdle = idle
            }
        }
    }

    Process {
        id: memProc
        command: ["sh", "-c", "awk '/MemTotal/ {t=$2} /MemAvailable/ {a=$2} END {if(t>0) {u=t-a; printf \"%d %d %d\", int(100*u/t), int(u/1024), int(t/1024)}}' /proc/meminfo"]
        running: false
        stdout: StdioCollector {
            onStreamFinished: {
                memProc.running = false
                var text = (memProc.stdout.text || "").trim()
                if (!text) return
                var parts = text.split(/\s+/)
                if (parts.length < 3) return
                var pct = parseInt(parts[0])
                if (!isNaN(pct)) perfContent.ramPercent = Math.max(0, Math.min(100, pct))
                var usedMB = parseInt(parts[1])
                var totalMB = parseInt(parts[2])
                if (!isNaN(usedMB)) perfContent.ramUsed = usedMB >= 1024 ? (usedMB / 1024).toFixed(1) + "G" : usedMB + "M"
                if (!isNaN(totalMB)) perfContent.ramTotal = totalMB >= 1024 ? (totalMB / 1024).toFixed(1) + "G" : totalMB + "M"
            }
        }
    }

    Process {
        id: sensorsProc
        command: ["sh", "-c", "sensors -j 2>/dev/null"]
        running: false
        stdout: StdioCollector {
            onStreamFinished: {
                sensorsProc.running = false
                var text = (sensorsProc.stdout.text || "").trim()
                if (!text) {
                    perfContent.lastError = "sensors missing (install lm_sensors)"
                    perfContent.loading = false
                    return
                }
                try {
                    var data = JSON.parse(text)
                    var groups = []
                    var seen = {}
                    for (var chipKey in data) {
                        var chip = data[chipKey]
                        if (typeof chip !== "object") continue
                        var nameBase = chipKey.split("-")[0]
                        var entries = []
                        for (var label in chip) {
                            if (label === "Adapter") continue
                            var sub = chip[label]
                            if (typeof sub !== "object") continue
                            var val = null
                            for (var k in sub) {
                                if (k.match(/^temp\d+_input$/) && typeof sub[k] === "number") {
                                    val = sub[k]
                                    break
                                }
                            }
                            if (val !== null && val > 0 && val < 200) {
                                entries.push({ label: label, value: val })
                            }
                        }
                        if (entries.length === 0) continue
                        var displayName = nameBase
                        if (nameBase === "k10temp" || nameBase === "coretemp" || nameBase === "zenpower") displayName = "CPU (" + nameBase + ")"
                        else if (nameBase === "amdgpu" || nameBase === "nvidia") displayName = "GPU (" + nameBase + ")"
                        else if (nameBase === "nvme") displayName = "NVMe"
                        else if (nameBase === "asusec" || nameBase === "asus") displayName = "Mainboard (" + nameBase + ")"
                        var dedupKey = displayName
                        var n = 2
                        while (seen[dedupKey]) { dedupKey = displayName + " #" + n; n++ }
                        seen[dedupKey] = true
                        groups.push({ name: dedupKey, entries: entries })
                    }
                    perfContent.sensorGroups = groups
                    perfContent.loading = false
                } catch (e) {
                    perfContent.lastError = "parse error: " + e
                    perfContent.loading = false
                }
            }
        }
    }

    Process {
        id: openBtop
        command: ["sh", "-c", "kitty -e btop"]
        running: false
    }

    // Header
    Item {
        width: parent.width - 20
        height: 22
        Row {
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            spacing: 8
            Text {
                text: ""
                color: perfContent.colors.primary
                font.pixelSize: 16
                font.family: perfContent.colors.widgetIconFont
                anchors.verticalCenter: parent.verticalCenter
            }
            Text {
                text: "System monitor"
                color: perfContent.colors.textMain
                font.pixelSize: 13
                font.bold: true
                anchors.verticalCenter: parent.verticalCenter
            }
        }
        MouseArea {
            id: btopMa
            width: 22; height: 22
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            anchors.right: refreshMa.left
            anchors.rightMargin: 4
            anchors.verticalCenter: parent.verticalCenter
            onClicked: { openBtop.running = true; perfContent.onClose() }
            Rectangle {
                anchors.fill: parent
                radius: 4
                color: btopMa.containsMouse ? perfContent.colors.surfaceBright : "transparent"
            }
            Text {
                anchors.centerIn: parent
                text: ""
                color: perfContent.colors.textDim
                font.pixelSize: 12
                font.family: perfContent.colors.widgetIconFont
            }
        }
        MouseArea {
            id: refreshMa
            width: 22; height: 22
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            onClicked: perfContent.refresh()
            Rectangle {
                anchors.fill: parent
                radius: 4
                color: refreshMa.containsMouse ? perfContent.colors.surfaceBright : "transparent"
            }
            Text {
                anchors.centerIn: parent
                text: ""
                color: perfContent.colors.textDim
                font.pixelSize: 11
                font.family: perfContent.colors.widgetIconFont
            }
        }
    }

    Rectangle { width: parent.width - 20; height: 1; color: perfContent.colors.borderSubtle }

    // CPU / RAM bars
    Column {
        width: parent.width - 20
        spacing: 6

        Column {
            width: parent.width
            spacing: 3
            Item {
                width: parent.width; height: 14
                Text {
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                    text: "CPU"
                    color: perfContent.colors.textDim
                    font.pixelSize: 11
                }
                Text {
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    text: perfContent.cpuUsage + "%"
                    color: perfContent.colors.textMain
                    font.pixelSize: 11
                }
            }
            Rectangle {
                width: parent.width; height: 4; radius: 2
                color: perfContent.colors.surfaceBright
                Rectangle {
                    width: parent.width * (perfContent.cpuUsage / 100.0)
                    height: parent.height
                    radius: parent.radius
                    color: perfContent.colors.primary
                    Behavior on width { NumberAnimation { duration: 250 } }
                }
            }
        }

        Column {
            width: parent.width
            spacing: 3
            Item {
                width: parent.width; height: 14
                Text {
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                    text: "RAM"
                    color: perfContent.colors.textDim
                    font.pixelSize: 11
                }
                Text {
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    text: (perfContent.ramUsed || "?") + " / " + (perfContent.ramTotal || "?") + "  (" + perfContent.ramPercent + "%)"
                    color: perfContent.colors.textMain
                    font.pixelSize: 11
                }
            }
            Rectangle {
                width: parent.width; height: 4; radius: 2
                color: perfContent.colors.surfaceBright
                Rectangle {
                    width: parent.width * (perfContent.ramPercent / 100.0)
                    height: parent.height
                    radius: parent.radius
                    color: perfContent.colors.primary
                    Behavior on width { NumberAnimation { duration: 250 } }
                }
            }
        }
    }

    Rectangle { width: parent.width - 20; height: 1; color: perfContent.colors.borderSubtle }

    // Temperature groups header
    Row {
        width: parent.width - 20
        spacing: 6
        Text {
            text: ""
            color: perfContent.colors.primary
            font.pixelSize: 12
            font.family: perfContent.colors.widgetIconFont
            anchors.verticalCenter: parent.verticalCenter
        }
        Text {
            text: "Temperatures"
            color: perfContent.colors.textMain
            font.pixelSize: 12
            font.bold: true
            anchors.verticalCenter: parent.verticalCenter
        }
    }

    Column {
        width: parent.width - 20
        spacing: 8

        Repeater {
            model: perfContent.sensorGroups

            Column {
                width: parent.width
                spacing: 2
                Text {
                    text: modelData.name
                    color: perfContent.colors.textDim
                    font.pixelSize: 10
                    font.bold: true
                }
                Repeater {
                    model: modelData.entries
                    Item {
                        width: parent.width
                        height: 14
                        Text {
                            anchors.left: parent.left
                            anchors.verticalCenter: parent.verticalCenter
                            text: modelData.label
                            color: perfContent.colors.textMain
                            font.pixelSize: 11
                        }
                        Text {
                            anchors.right: parent.right
                            anchors.verticalCenter: parent.verticalCenter
                            text: modelData.value.toFixed(1) + "°C"
                            color: modelData.value >= 80 ? perfContent.colors.error
                                : modelData.value >= 65 ? perfContent.colors.primary
                                : perfContent.colors.textMain
                            font.pixelSize: 11
                            font.bold: modelData.value >= 65
                        }
                    }
                }
            }
        }

        Text {
            visible: perfContent.sensorGroups.length === 0 && !perfContent.loading
            width: parent.width
            text: perfContent.lastError || "no sensors found"
            color: perfContent.colors.textMuted
            font.pixelSize: 10
            wrapMode: Text.WordWrap
        }
    }

    Rectangle { width: parent.width - 20; height: 1; color: perfContent.colors.borderSubtle }

    Text {
        width: parent.width - 20
        text: "Middle-click pill to open btop. Click again to close."
        color: perfContent.colors.textMuted
        font.pixelSize: 9
        wrapMode: Text.WordWrap
    }
}
