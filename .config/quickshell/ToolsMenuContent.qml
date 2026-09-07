import QtQuick
import Quickshell.Io

import "."

Column {
    id: toolsMenu
    required property var colors
    required property var onClose
    property string compositorName: "mango"

    spacing: 0
    width: 210
    padding: 6

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
                { label: "Color Picker", icon: "\uF1FB", action: "colorpicker" },
                // Rehomed from the QuickSettings Theme card, which was one of
                // nine tiles in a panel that also held audio and radios.
                { label: "Wallpaper & theme", icon: "\uF185", action: "theme" }
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
                } else if (act === "theme") {
                    toolsMenu.onClose()
                    sessionRunner.run("sh -c '\"$HOME/.config/scripts/select-wallpaper.sh\" --material'")
                } else if (act === "colorpicker") {
                    toolsMenu.onClose()
                    if (!pickerProc.running) pickerProc.running = true
                }
            }
            Rectangle {
                anchors.fill: parent
                radius: 6
                color: toolMa.containsMouse
                    ? Qt.rgba(colors.textMain.r, colors.textMain.g, colors.textMain.b, 0.08)
                    : "transparent"
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

    // ===== APPEARANCE =====
    // The bar shape/style pickers, rehomed from SettingsMenuContent. That page
    // also carried sixteen widget-visibility toggles, which went away with it:
    // widgets now hide themselves through `present` when they have nothing to
    // report, so toggling them by hand was managing a decision already made.
    Item { width: 1; height: 8 }
    Rectangle {
        width: toolsMenu.width - 12
        height: 1
        color: Qt.rgba(toolsMenu.colors.textMain.r, toolsMenu.colors.textMain.g,
                       toolsMenu.colors.textMain.b, 0.09)
    }
    Item { width: 1; height: 8 }

    component Chips: Column {
        id: chipGroup
        required property string heading
        required property var options
        required property string current
        required property var apply
        spacing: 5
        Text {
            text: chipGroup.heading
            color: toolsMenu.colors.textDim
            font.pixelSize: 11
            font.bold: true
            leftPadding: 4
        }
        Flow {
            width: toolsMenu.width - 12
            spacing: 5
            Repeater {
                model: chipGroup.options
                delegate: Rectangle {
                    required property var modelData
                    readonly property bool sel: chipGroup.current === modelData.id
                    width: chipText.implicitWidth + 20
                    height: 26
                    // Stadium, per Material 3: a selectable chip is a full pill,
                    // not a rounded rectangle.
                    radius: height / 2
                    color: sel
                        ? Qt.rgba(toolsMenu.colors.primary.r, toolsMenu.colors.primary.g,
                                  toolsMenu.colors.primary.b, 0.18)
                        : (chipMa.containsMouse
                            ? Qt.rgba(toolsMenu.colors.textMain.r, toolsMenu.colors.textMain.g,
                                      toolsMenu.colors.textMain.b, 0.08)
                            : "transparent")
                    border.width: 1
                    border.color: sel
                        ? Qt.rgba(toolsMenu.colors.primary.r, toolsMenu.colors.primary.g,
                                  toolsMenu.colors.primary.b, 0.45)
                        : Qt.rgba(toolsMenu.colors.textMain.r, toolsMenu.colors.textMain.g,
                                  toolsMenu.colors.textMain.b, 0.10)
                    Behavior on color { ColorAnimation { duration: 110 } }
                    Text {
                        id: chipText
                        anchors.centerIn: parent
                        text: modelData.label
                        color: parent.sel ? toolsMenu.colors.primary : toolsMenu.colors.textDim
                        font.pixelSize: 11
                        font.bold: parent.sel
                    }
                    MouseArea {
                        id: chipMa
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: chipGroup.apply(modelData.id)
                    }
                }
            }
        }
    }

    Chips {
        heading: "BAR SHAPE"
        options: BarStyle.geometries
        current: BarStyle.geometry
        apply: function(id) { BarStyle.setGeometry(id) }
    }
    Item { width: 1; height: 4 }
}
