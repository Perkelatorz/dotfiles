import QtQuick
import Quickshell.Io

import "."

Column {
    id: toolsMenu
    required property var colors
    required property var onClose
    required property var screenshotWidget
    property string compositorName: "hyprland"

    signal clipboardRequested()
    signal keybindsRequested()
    signal screenshotMenuRequested()

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
            { label: "Screenshot", icon: "\uF030", action: "screenshot" },
            { label: "Clipboard", icon: "\uF328", action: "clipboard" },
            { label: "Quick Notes", icon: "\uF249", action: "notes" },
            { label: "Color Picker", icon: "\uF1FB", action: "colorpicker" },
            { label: "Keybinds", icon: "\uF11C", action: "keybinds" }
        ]
        delegate: MouseArea {
            id: toolMa
            width: toolsMenu.width - 8
            height: 32
            hoverEnabled: true
            onClicked: {
                var act = modelData.action
                if (act === "screenshot") {
                    toolsMenu.onClose()
                    toolsMenu.screenshotMenuRequested()
                } else if (act === "clipboard") {
                    toolsMenu.onClose()
                    toolsMenu.clipboardRequested()
                } else if (act === "keybinds") {
                    toolsMenu.onClose()
                    toolsMenu.keybindsRequested()
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
            Text {
                visible: modelData.action === "screenshot"
                anchors.right: parent.right
                anchors.rightMargin: 10
                anchors.verticalCenter: parent.verticalCenter
                text: "\uF054"
                color: colors.textMuted
                font.pixelSize: 9
                font.family: colors.widgetIconFont
            }
        }
    }
}
