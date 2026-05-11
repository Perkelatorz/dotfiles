import QtQuick
import Quickshell.Io

import "."

Column {
    id: claudeContent
    required property var colors
    required property var onClose

    // Parsed metrics. Strings so we can show "—" before first fetch.
    property string todayCost: "—"
    property string todayTokens: "—"
    property string weekCost: "—"
    property string weekTokens: "—"
    property string monthCost: "—"
    property string activeBlockLabel: "no active session"
    property real activeBlockPct: 0.0
    property string lastError: ""
    property bool loading: true

    spacing: 6
    width: 280
    padding: 10

    function refresh() {
        claudeContent.loading = true
        claudeContent.lastError = ""
        // Run three ccusage subcommands in parallel.
        dailyProc.running = true
        monthlyProc.running = true
        blocksProc.running = true
    }

    Component.onCompleted: refresh()

    // --- ccusage subprocesses ---

    Process {
        id: dailyProc
        // Last 7 days for week total; also pluck today.
        command: ["sh", "-c", "ccusage daily --json --since $(date -d '6 days ago' +%Y%m%d) 2>/dev/null || npx --yes ccusage@latest daily --json --since $(date -d '6 days ago' +%Y%m%d) 2>/dev/null"]
        running: false
        stdout: StdioCollector {
            onStreamFinished: {
                dailyProc.running = false
                var text = (dailyProc.stdout.text || "").trim()
                if (text === "") {
                    claudeContent.lastError = "ccusage missing (npm i -g ccusage)"
                    claudeContent.loading = false
                    return
                }
                try {
                    var data = JSON.parse(text)
                    var days = data.daily || []
                    var todayStr = Qt.formatDate(new Date(), "yyyy-MM-dd")
                    var weekCost = 0
                    var weekTokens = 0
                    var tCost = null, tTok = null
                    for (var i = 0; i < days.length; i++) {
                        var d = days[i]
                        var c = d.totalCost || 0
                        var t = (d.inputTokens || 0) + (d.outputTokens || 0) +
                                (d.cacheCreationTokens || 0) + (d.cacheReadTokens || 0)
                        weekCost += c
                        weekTokens += t
                        if (d.date === todayStr) {
                            tCost = c
                            tTok = t
                        }
                    }
                    claudeContent.todayCost = tCost != null ? ("$" + tCost.toFixed(2)) : "$0.00"
                    claudeContent.todayTokens = tTok != null ? claudeContent.fmtTokens(tTok) : "0"
                    claudeContent.weekCost = "$" + weekCost.toFixed(2)
                    claudeContent.weekTokens = claudeContent.fmtTokens(weekTokens)
                } catch (e) {
                    claudeContent.lastError = "parse error: " + e
                }
                claudeContent.loading = false
            }
        }
    }

    Process {
        id: monthlyProc
        command: ["sh", "-c", "ccusage monthly --json 2>/dev/null || npx --yes ccusage@latest monthly --json 2>/dev/null"]
        running: false
        stdout: StdioCollector {
            onStreamFinished: {
                monthlyProc.running = false
                var text = (monthlyProc.stdout.text || "").trim()
                if (text === "") return
                try {
                    var data = JSON.parse(text)
                    var months = data.monthly || []
                    var monthStr = Qt.formatDate(new Date(), "yyyy-MM")
                    for (var i = 0; i < months.length; i++) {
                        if (months[i].month === monthStr) {
                            claudeContent.monthCost = "$" + (months[i].totalCost || 0).toFixed(2)
                            return
                        }
                    }
                    claudeContent.monthCost = "$0.00"
                } catch (_) {}
            }
        }
    }

    Process {
        id: blocksProc
        command: ["sh", "-c", "ccusage blocks --active --json 2>/dev/null || npx --yes ccusage@latest blocks --active --json 2>/dev/null"]
        running: false
        stdout: StdioCollector {
            onStreamFinished: {
                blocksProc.running = false
                var text = (blocksProc.stdout.text || "").trim()
                if (text === "") return
                try {
                    var data = JSON.parse(text)
                    var blocks = data.blocks || []
                    var active = null
                    for (var i = 0; i < blocks.length; i++) {
                        if (blocks[i].isActive) { active = blocks[i]; break }
                    }
                    if (!active) {
                        claudeContent.activeBlockLabel = "no active 5h block"
                        claudeContent.activeBlockPct = 0
                        return
                    }
                    var startMs = Date.parse(active.startTime)
                    var endMs = Date.parse(active.endTime)
                    var nowMs = Date.now()
                    var pct = Math.min(1.0, Math.max(0.0, (nowMs - startMs) / (endMs - startMs)))
                    claudeContent.activeBlockPct = pct
                    var minsLeft = Math.max(0, Math.round((endMs - nowMs) / 60000))
                    var tokens = (active.tokenCounts && (active.tokenCounts.inputTokens + active.tokenCounts.outputTokens)) || active.totalTokens || 0
                    claudeContent.activeBlockLabel = claudeContent.fmtTokens(tokens) + " tok · " + minsLeft + "m left"
                } catch (_) {}
            }
        }
    }

    function fmtTokens(n) {
        if (n >= 1000000) return (n / 1000000).toFixed(1) + "M"
        if (n >= 1000) return (n / 1000).toFixed(1) + "k"
        return String(n)
    }

    // --- Layout ---

    Item {
        width: parent.width - 20
        height: 22
        Row {
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            spacing: 8
            Text {
                text: ""
                color: claudeContent.colors.primary
                font.pixelSize: 16
                font.family: claudeContent.colors.widgetIconFont
                anchors.verticalCenter: parent.verticalCenter
            }
            Text {
                text: "Local activity"
                color: claudeContent.colors.textMain
                font.pixelSize: 13
                font.bold: true
                anchors.verticalCenter: parent.verticalCenter
            }
        }
        MouseArea {
            id: refreshMa
            width: 22; height: 22
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            onClicked: claudeContent.refresh()
            Rectangle {
                anchors.fill: parent
                radius: 4
                color: refreshMa.containsMouse ? claudeContent.colors.surfaceBright : "transparent"
            }
            Text {
                anchors.centerIn: parent
                text: claudeContent.loading ? "" : ""
                color: claudeContent.colors.textDim
                font.pixelSize: 11
                font.family: claudeContent.colors.widgetIconFont
            }
        }
    }

    Rectangle { width: parent.width - 20; height: 1; color: claudeContent.colors.borderSubtle }

    // Active 5-hour block progress
    Column {
        width: parent.width - 20
        spacing: 3
        Item {
            width: parent.width
            height: 14
            Text {
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                text: "Active 5h block"
                color: claudeContent.colors.textDim
                font.pixelSize: 11
            }
            Text {
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                text: claudeContent.activeBlockLabel
                color: claudeContent.colors.textMain
                font.pixelSize: 11
                elide: Text.ElideLeft
            }
        }
        Rectangle {
            width: parent.width; height: 4; radius: 2
            color: claudeContent.colors.surfaceBright
            Rectangle {
                width: parent.width * claudeContent.activeBlockPct
                height: parent.height
                radius: parent.radius
                color: claudeContent.colors.primary
                Behavior on width { NumberAnimation { duration: 250 } }
            }
        }
    }

    Rectangle { width: parent.width - 20; height: 1; color: claudeContent.colors.borderSubtle }

    // Stats grid
    Grid {
        columns: 2
        rowSpacing: 6
        columnSpacing: 18
        Text { text: "Today"; color: claudeContent.colors.textDim; font.pixelSize: 11 }
        Text {
            text: claudeContent.todayCost + "  ·  " + claudeContent.todayTokens
            color: claudeContent.colors.textMain
            font.pixelSize: 12
        }
        Text { text: "Week"; color: claudeContent.colors.textDim; font.pixelSize: 11 }
        Text {
            text: claudeContent.weekCost + "  ·  " + claudeContent.weekTokens
            color: claudeContent.colors.textMain
            font.pixelSize: 12
        }
        Text { text: "Month"; color: claudeContent.colors.textDim; font.pixelSize: 11 }
        Text {
            text: claudeContent.monthCost
            color: claudeContent.colors.textMain
            font.pixelSize: 12
        }
    }

    Text {
        visible: claudeContent.lastError !== ""
        text: claudeContent.lastError
        color: claudeContent.colors.error
        font.pixelSize: 10
        width: parent.width - 20
        wrapMode: Text.WordWrap
    }

    Rectangle { width: parent.width - 20; height: 1; color: claudeContent.colors.borderSubtle }

    Text {
        width: parent.width - 20
        text: "Local JSONL counts. Not plan quota — run /usage inside claude for that."
        color: claudeContent.colors.textMuted
        font.pixelSize: 9
        wrapMode: Text.WordWrap
    }
}
