import QtQuick
import Quickshell.Io

import "."

Item {
    id: ramUsageWidget
    required property var colors
    property int pillIndex: 2

    readonly property color pillColor: (colors.widgetPillColors && pillIndex >= 0 && pillIndex < colors.widgetPillColors.length) ? colors.widgetPillColors[pillIndex] : colors.secondary
    readonly property color pillTextColor: (colors.widgetTextOnPillColors && pillIndex >= 0 && pillIndex < colors.widgetTextOnPillColors.length) ? colors.widgetTextOnPillColors[pillIndex] : colors.textMain

    property int ramUsagePercent: 0

    implicitWidth: pill.width
    implicitHeight: 28

    Process {
        id: ramProc
        command: ["sh", "-c", "awk '/MemTotal/ {t=$2} /MemAvailable/ {a=$2} END {if(t>0) print int(100*(t-a)/t); else print 0}' /proc/meminfo"]
        stdout: StdioCollector {
            onStreamFinished: {
                var data = this.text
                if (!data) return
                var p = parseInt(String(data).trim())
                if (!isNaN(p))
                    ramUsageWidget.ramUsagePercent = Math.max(0, Math.min(100, p))
                ramProc.running = false
            }
        }
        Component.onCompleted: running = true
    }

    Timer {
        interval: 2000
        repeat: true
        running: true
        onTriggered: ramProc.running = true
    }

    // Run btop/htop in a terminal (btop needs a TTY).
    property string systemMonitorCommand: "kitty -e btop"

    Process {
        id: runMonitor
        command: systemMonitorCommand.trim().split(/\s+/).filter(function(s) { return s.length > 0 })
        running: false
    }

    Rectangle {
        id: pill
        height: ramUsageWidget.implicitHeight - (colors.widgetPillPaddingV) * 2
        width: Math.max(row.implicitWidth + (colors.widgetPillPaddingH) * 2, 52)
        anchors.verticalCenter: parent.verticalCenter
        radius: colors.widgetPillRadius
        color: ramUsageWidget.pillColor
        border.width: 1
        border.color: ramUsageWidget.pillColor

        MouseArea {
            anchors.fill: parent
            onClicked: runMonitor.running = true
        }
        Row {
            id: row
            anchors.centerIn: parent
            spacing: 4
            Text {
                text: "\uF538"
                color: ramUsageWidget.pillTextColor
                font.pixelSize: colors.cpuFontSize
                font.family: colors.widgetIconFont
            }
            Text {
                id: ramText
                text: ramUsageWidget.ramUsagePercent + "%"
                color: ramUsageWidget.pillTextColor
                font.pixelSize: colors.cpuFontSize
            }
        }
    }
}
