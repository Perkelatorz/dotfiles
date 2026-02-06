import QtQuick
import Quickshell.Io
import Quickshell.Hyprland

import "."

Item {
    id: kbWidget
    required property var colors
    property int pillIndex: 6

    readonly property color pillColor: (colors.widgetPillColors && pillIndex >= 0 && pillIndex < colors.widgetPillColors.length) ? colors.widgetPillColors[pillIndex] : colors.surfaceContainer
    readonly property color pillTextColor: (colors.widgetTextOnPillColors && pillIndex >= 0 && pillIndex < colors.widgetTextOnPillColors.length) ? colors.widgetTextOnPillColors[pillIndex] : colors.textMain

    property string layout: ""
    // Set to e.g. "hyprctl switchxkblayout at-translated-set-2-keyboard next" to cycle on click (device name may vary)
    property string layoutSwitchCommand: "hyprctl switchxkblayout at-translated-set-2-keyboard next"

    implicitWidth: pill.width
    implicitHeight: 28

    Process {
        id: layoutProc
        command: ["sh", "-c", "setxkbmap -query 2>/dev/null | grep '^layout:' | sed 's/layout:\\s*//' | cut -d',' -f1 | tr -d ' '"]
        stdout: StdioCollector {
            onStreamFinished: {
                kbWidget.layout = (layoutProc.stdout.text || "").trim() || "?"
                layoutProc.running = false
            }
        }
    }

    Process {
        id: switchProc
        command: []
        running: false
        onRunningChanged: if (!running) layoutProc.running = true
    }

    Connections {
        target: Hyprland
        function onRawEvent(event) {
            if ((event.name || "").indexOf("layout") >= 0 || (event.name || "").indexOf("keyboard") >= 0)
                layoutProc.running = true
        }
    }

    Timer {
        interval: 5000
        repeat: true
        running: true
        onTriggered: layoutProc.running = true
    }

    Component.onCompleted: layoutProc.running = true

    Rectangle {
        id: pill
        height: kbWidget.implicitHeight - (colors.widgetPillPaddingV) * 2
        width: Math.max(row.implicitWidth + (colors.widgetPillPaddingH) * 2, 44)
        anchors.verticalCenter: parent.verticalCenter
        radius: colors.widgetPillRadius
        color: kbWidget.pillColor
        border.width: 1
        border.color: kbWidget.pillColor

        MouseArea {
            anchors.fill: parent
            onClicked: {
                var cmd = (kbWidget.layoutSwitchCommand || "").trim().split(/\s+/).filter(function(s) { return s.length > 0 })
                if (cmd.length > 0) {
                    switchProc.command = cmd
                    switchProc.running = true
                } else {
                    layoutProc.running = true
                }
            }
            Row {
                id: row
                anchors.centerIn: parent
                spacing: 4
                Text {
                    text: "\uF11C"
                    color: kbWidget.pillTextColor
                    font.pixelSize: colors.cpuFontSize
                    font.family: colors.widgetIconFont
                }
                Text {
                    text: kbWidget.layout || "?"
                    color: kbWidget.pillTextColor
                    font.pixelSize: colors.cpuFontSize
                }
            }
        }
    }
}
