import QtQuick
import Quickshell.Io

import "."

Item {
    id: cpuUsageWidget
    required property var colors
    property int pillIndex: 1

    readonly property color pillColor: (colors.widgetPillColors && pillIndex >= 0 && pillIndex < colors.widgetPillColors.length) ? colors.widgetPillColors[pillIndex] : colors.primary
    readonly property color pillTextColor: (colors.widgetTextOnPillColors && pillIndex >= 0 && pillIndex < colors.widgetTextOnPillColors.length) ? colors.widgetTextOnPillColors[pillIndex] : colors.textMain

    property int cpuUsage: 0
    property int lastCpuTotal: 0
    property int lastCpuIdle: 0

    implicitWidth: pill.width
    implicitHeight: 28

    Process {
        id: cpuProc
        command: ["sh", "-c", "head -1 /proc/stat"]
        stdout: StdioCollector {
            onStreamFinished: {
                var data = this.text
                if (!data) return
                var p = data.trim().split(/\s+/)
                if (p.length < 9) return
                var idle = parseInt(p[4]) + parseInt(p[5])
                var total = 0
                for (var i = 1; i <= 8; i++)
                    total += parseInt(p[i])
                if (cpuUsageWidget.lastCpuTotal > 0) {
                    var dTotal = total - cpuUsageWidget.lastCpuTotal
                    var dIdle = idle - cpuUsageWidget.lastCpuIdle
                    if (dTotal > 0) {
                        var u = Math.round(100 * (1 - dIdle / dTotal))
                        cpuUsageWidget.cpuUsage = Math.max(0, Math.min(100, u))
                    }
                }
                cpuUsageWidget.lastCpuTotal = total
                cpuUsageWidget.lastCpuIdle = idle
                cpuProc.running = false
            }
        }
        Component.onCompleted: running = true
    }

    Timer {
        interval: 2000
        repeat: true
        running: cpuUsageWidget.visible
        onTriggered: cpuProc.running = true
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
        height: cpuUsageWidget.implicitHeight - colors.widgetPillPaddingV * 2
        width: Math.max(row.implicitWidth + colors.widgetPillPaddingH * 2, 52)
        anchors.verticalCenter: parent.verticalCenter
        radius: colors.widgetPillRadius
        color: mouseArea.pressed ? Qt.darker(cpuUsageWidget.pillColor, 1.15) : mouseArea.containsMouse ? Qt.lighter(cpuUsageWidget.pillColor, 1.2) : cpuUsageWidget.pillColor
        border.width: 1
        border.color: mouseArea.containsMouse ? Qt.lighter(cpuUsageWidget.pillColor, 1.4) : cpuUsageWidget.pillColor
        scale: mouseArea.pressed ? 0.94 : 1.0
        Behavior on color { ColorAnimation { duration: 100 } }
        Behavior on border.color { ColorAnimation { duration: 100 } }
        Behavior on scale { NumberAnimation { duration: 80; easing.type: Easing.OutCubic } }

        MouseArea {
            id: mouseArea
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: runMonitor.running = true
        }
        Row {
            id: row
            anchors.centerIn: parent
            spacing: 4
            Text {
                text: "\uF2DB"
                color: cpuUsageWidget.pillTextColor
                font.pixelSize: colors.cpuFontSize
                font.family: colors.widgetIconFont
            }
            Text {
                id: cpuText
                text: cpuUsageWidget.cpuUsage + "%"
                color: cpuUsageWidget.pillTextColor
                font.pixelSize: colors.cpuFontSize
            }
        }
        Rectangle {
            visible: mouseArea.containsMouse
            anchors.bottom: parent.top
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottomMargin: 4
            width: cpuTip.implicitWidth + 12
            height: cpuTip.implicitHeight + 6
            radius: 4
            color: colors.surface
            border.width: 1
            border.color: colors.border
            z: 1000
            Text {
                id: cpuTip
                anchors.centerIn: parent
                text: "CPU: " + cpuUsageWidget.cpuUsage + "%"
                color: colors.textMain
                font.pixelSize: colors.fontSize - 1
            }
        }
    }
}
