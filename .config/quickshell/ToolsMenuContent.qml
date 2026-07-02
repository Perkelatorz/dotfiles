import QtQuick
import Quickshell.Io

import "."

Column {
    id: toolsMenu
    required property var colors
    required property var onClose
    property string compositorName: "hyprland"

    spacing: 0
    width: 180
    padding: 4

    SessionRunner {
        id: sessionRunner
        compositorName: toolsMenu.compositorName
    }

    Process {
        id: pickerProc
        command: ["hyprpicker", "-a", "-f", "hex"]
        running: false
        stdout: StdioCollector {
            onStreamFinished: pickerProc.running = false
        }
    }

    Repeater {
        id: toolsRepeater
        model: [
            { label: "Screenshot region", icon: "\uF030", action: "shot-region" },
            { label: "Screenshot screen", icon: "\uF108", action: "shot-full" },
            { label: "Same as last", icon: "\uF01E", action: "shot-last" },
            { label: "Quick Notes", icon: "\uF249", action: "notes" },
            { label: "Color Picker", icon: "\uF1FB", action: "colorpicker" }
        ]
        delegate: MouseArea {
            id: toolMa
            width: toolsMenu.width - 8
            height: 32
            hoverEnabled: true
            onClicked: {
                var act = modelData.action
                // Screenshots: menu must close first (or it lands in the
                // capture); the sleep lets the popup animation finish.
                if (act === "shot-region") {
                    toolsMenu.onClose()
                    sessionRunner.run("sh -c 'sleep 0.2; exec \"${XDG_CONFIG_HOME:-$HOME/.config}/scripts/screenshot-region.sh\"'")
                } else if (act === "shot-full") {
                    toolsMenu.onClose()
                    sessionRunner.run("sh -c 'sleep 0.2; exec \"${XDG_CONFIG_HOME:-$HOME/.config}/scripts/screenshot-fullscreen.sh\"'")
                } else if (act === "shot-last") {
                    toolsMenu.onClose()
                    sessionRunner.run("sh -c 'sleep 0.2; exec \"${XDG_CONFIG_HOME:-$HOME/.config}/scripts/screenshot-last.sh\"'")
                } else if (act === "notes") {
                    toolsMenu.onClose()
                    sessionRunner.run("kitty --class quick-notes -e nvim ~/notes.md")
                } else if (act === "colorpicker") {
                    toolsMenu.onClose()
                    if (!pickerProc.running) pickerProc.running = true
                }
            }
            Rectangle {
                anchors.fill: parent
                radius: 6
                color: toolMa.containsMouse ? colors.surfaceBright : "transparent"
            }
            Row {
                anchors.verticalCenter: parent.verticalCenter
                leftPadding: 10
                spacing: 10
                Text {
                    text: modelData.icon
                    color: toolMa.containsMouse ? colors.primary : colors.textMain
                    font.pixelSize: 13
                    font.family: colors.widgetIconFont
                    anchors.verticalCenter: parent.verticalCenter
                }
                Text {
                    text: modelData.label
                    color: toolMa.containsMouse ? colors.textMain : colors.textDim
                    font.pixelSize: colors.clockFontSize
                    anchors.verticalCenter: parent.verticalCenter
                }
            }
        }
    }
}
