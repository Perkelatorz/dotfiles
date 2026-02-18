import QtQuick
import Quickshell.Io

import "."

Item {
    id: netWidget
    required property var colors
    property int pillIndex: 2

    readonly property color pillColor: (colors.widgetPillColors && pillIndex >= 0 && pillIndex < colors.widgetPillColors.length) ? colors.widgetPillColors[pillIndex] : colors.primary
    readonly property color pillTextColor: (colors.widgetTextOnPillColors && pillIndex >= 0 && pillIndex < colors.widgetTextOnPillColors.length) ? colors.widgetTextOnPillColors[pillIndex] : colors.textMain

    property string iface: ""
    property real rxRate: 0
    property real txRate: 0
    property real lastRx: 0
    property real lastTx: 0
    property bool hasData: false

    implicitWidth: pill.width
    implicitHeight: 28

    function formatSpeed(bytesPerSec) {
        if (bytesPerSec < 1024) return Math.round(bytesPerSec) + " B/s"
        if (bytesPerSec < 1024 * 1024) return Math.round(bytesPerSec / 1024) + " KB/s"
        return (bytesPerSec / (1024 * 1024)).toFixed(1) + " MB/s"
    }

    Process {
        id: ifaceProc
        command: ["sh", "-c", "ip -o link show up 2>/dev/null | awk -F': ' '{print $2}' | grep -vE '^(lo|docker|br-|veth)' | head -1"]
        stdout: StdioCollector {
            onStreamFinished: {
                var s = (ifaceProc.stdout.text || "").trim()
                if (s) netWidget.iface = s
                ifaceProc.running = false
            }
        }
        Component.onCompleted: running = true
    }

    Process {
        id: statsProc
        command: ["sh", "-c", "cat /sys/class/net/" + netWidget.iface + "/statistics/rx_bytes /sys/class/net/" + netWidget.iface + "/statistics/tx_bytes 2>/dev/null"]
        running: false
        stdout: StdioCollector {
            onStreamFinished: {
                var lines = (statsProc.stdout.text || "").trim().split("\n")
                if (lines.length >= 2) {
                    var rx = parseFloat(lines[0]) || 0
                    var tx = parseFloat(lines[1]) || 0
                    if (netWidget.hasData) {
                        netWidget.rxRate = Math.max(0, (rx - netWidget.lastRx) / 2)
                        netWidget.txRate = Math.max(0, (tx - netWidget.lastTx) / 2)
                    }
                    netWidget.lastRx = rx
                    netWidget.lastTx = tx
                    netWidget.hasData = true
                }
                statsProc.running = false
            }
        }
    }

    Process {
        id: runConnectionEditor
        command: ["nm-connection-editor"]
        running: false
    }

    Timer {
        interval: 2000
        repeat: true
        running: netWidget.visible && netWidget.iface !== ""
        onTriggered: if (!statsProc.running) statsProc.running = true
    }

    onIfaceChanged: if (iface !== "") statsProc.running = true

    Rectangle {
        id: pill
        height: netWidget.implicitHeight - colors.widgetPillPaddingV * 2
        width: Math.max(row.implicitWidth + colors.widgetPillPaddingH * 2, 80)
        anchors.verticalCenter: parent.verticalCenter
        radius: colors.widgetPillRadius
        color: mouseArea.pressed ? Qt.darker(netWidget.pillColor, 1.15) : mouseArea.containsMouse ? Qt.lighter(netWidget.pillColor, 1.2) : netWidget.pillColor
        border.width: 1
        border.color: mouseArea.containsMouse ? Qt.lighter(netWidget.pillColor, 1.4) : netWidget.pillColor
        scale: mouseArea.pressed ? 0.94 : 1.0
        Behavior on color { ColorAnimation { duration: 100 } }
        Behavior on border.color { ColorAnimation { duration: 100 } }
        Behavior on scale { NumberAnimation { duration: 80; easing.type: Easing.OutCubic } }

        MouseArea {
            id: mouseArea
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: runConnectionEditor.running = true
        }
        Row {
            id: row
            anchors.centerIn: parent
            spacing: 6
            Row {
                spacing: 2
                Text {
                    text: "\uF063"
                    color: netWidget.pillTextColor
                    font.pixelSize: colors.cpuFontSize - 1
                    font.family: colors.widgetIconFont
                }
                Text {
                    text: netWidget.formatSpeed(netWidget.rxRate)
                    color: netWidget.pillTextColor
                    font.pixelSize: colors.cpuFontSize - 1
                }
            }
            Row {
                spacing: 2
                Text {
                    text: "\uF062"
                    color: netWidget.pillTextColor
                    font.pixelSize: colors.cpuFontSize - 1
                    font.family: colors.widgetIconFont
                }
                Text {
                    text: netWidget.formatSpeed(netWidget.txRate)
                    color: netWidget.pillTextColor
                    font.pixelSize: colors.cpuFontSize - 1
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
            width: netTip.implicitWidth + 12
            height: netTip.implicitHeight + 6
            radius: 4
            color: colors.surface
            border.width: 1
            border.color: colors.border
            z: 1000
            Text {
                id: netTip
                anchors.centerIn: parent
                text: netWidget.iface ? (netWidget.iface + " - " + netWidget.formatSpeed(netWidget.rxRate) + " down / " + netWidget.formatSpeed(netWidget.txRate) + " up") : "No network"
                color: colors.textMain
                font.pixelSize: colors.fontSize - 1
            }
        }
    }
}
