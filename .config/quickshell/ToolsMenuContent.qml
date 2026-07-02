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

    // gpu-screen-recorder instant replay (desktop class) — entries only
    // appear when gsr is installed.
    property bool gsrAvailable: false
    Process {
        id: gsrCheck
        command: ["sh", "-c", "command -v gpu-screen-recorder >/dev/null && echo yes || echo no"]
        running: true
        stdout: StdioCollector {
            onStreamFinished: {
                toolsMenu.gsrAvailable = (gsrCheck.stdout.text || "").trim() === "yes"
                gsrCheck.running = false
            }
        }
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
        model: {
            var m = [
                { label: "Screenshot region", icon: "\uF030", action: "shot-region" },
                { label: "Screenshot screen", icon: "\uF108", action: "shot-full" },
                { label: "Same as last", icon: "\uF01E", action: "shot-last" },
                { label: "Quick Notes", icon: "\uF249", action: "notes" },
                { label: "Color Picker", icon: "\uF1FB", action: "colorpicker" }
            ]
            if (toolsMenu.gsrAvailable) {
                m.push({ label: "Save replay clip", icon: "\uF0C7", action: "replay-save" })
                m.push({ label: "Replay buffer", icon: "\uF03D", action: "replay-toggle" })
            }
            return m
        }
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
                } else if (act === "replay-save") {
                    toolsMenu.onClose()
                    sessionRunner.run("sh -c 'if pgrep -f \"gpu-screen-recorder -w\" >/dev/null; then pkill -USR1 -f \"gpu-screen-recorder -w\"; notify-send \"Replay saved\" \"$HOME/Videos/Replays\"; else notify-send \"Replay buffer not running\" \"Start it from the tools menu\"; fi'")
                } else if (act === "replay-toggle") {
                    toolsMenu.onClose()
                    sessionRunner.run("sh -c 'if pgrep -f \"gpu-screen-recorder -w\" >/dev/null; then pkill -f \"gpu-screen-recorder -w\"; notify-send \"Replay buffer stopped\"; else mkdir -p \"$HOME/Videos/Replays\"; gpu-screen-recorder -w screen -f 60 -a default_output -c mp4 -r 60 -o \"$HOME/Videos/Replays\" >/dev/null 2>&1 & notify-send \"Replay buffer started\" \"Last 60s saved on demand\"; fi'")
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
