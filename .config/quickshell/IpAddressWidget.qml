import QtQuick
import Quickshell.Io

import "."

Item {
    id: ipWidget
    required property var colors
    property int pillIndex: 7

    readonly property color pillColor: (colors.widgetPillColors && pillIndex >= 0 && pillIndex < colors.widgetPillColors.length) ? colors.widgetPillColors[pillIndex] : colors.error
    readonly property color pillTextColor: (colors.widgetTextOnPillColors && pillIndex >= 0 && pillIndex < colors.widgetTextOnPillColors.length) ? colors.widgetTextOnPillColors[pillIndex] : colors.textMain

    property string ipAddress: ""

    implicitWidth: pill.width
    implicitHeight: 28

    Process {
        id: ipProc
        command: ["sh", "-c", "ip -4 addr show scope global 2>/dev/null | grep -oE 'inet [0-9.]+/[0-9]+' | head -1 | awk '{print $2}'"]
        stdout: StdioCollector {
            onStreamFinished: {
                var s = (ipProc.stdout.text || "").trim()
                ipWidget.ipAddress = s || "--"
                ipProc.running = false
            }
        }
    }

    Process {
        id: runConnectionEditor
        command: ["nm-connection-editor"]
        running: false
    }

    Timer {
        interval: 60000
        repeat: true
        running: ipWidget.visible
        onTriggered: ipProc.running = true
    }

    Component.onCompleted: ipProc.running = true

    Rectangle {
        id: pill
        height: ipWidget.implicitHeight - (colors.widgetPillPaddingV) * 2
        width: row.implicitWidth + colors.widgetPillPaddingH * 2
        anchors.verticalCenter: parent.verticalCenter
        radius: colors.widgetPillRadius
        color: ipWidget.pillColor
        border.width: 1
        border.color: ipWidget.pillColor

        MouseArea {
            anchors.fill: parent
            onClicked: runConnectionEditor.running = true
            Row {
                id: row
                anchors.centerIn: parent
                spacing: 4
                Text {
                    text: "\uF0AC"
                    color: ipWidget.pillTextColor
                    font.pixelSize: colors.cpuFontSize
                    font.family: colors.widgetIconFont
                }
                Text {
                    id: ipText
                    text: {
                        var a = (ipWidget.ipAddress || "").trim()
                        if (a === "" || a === "--") return "No network"
                        return a
                    }
                    color: ipWidget.pillTextColor
                    font.pixelSize: colors.cpuFontSize
                }
            }
        }
    }
}
