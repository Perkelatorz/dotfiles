import QtQuick
import Quickshell.Io

import "."

Item {
    id: screenshotWidget
    required property var colors
    property int pillIndex: 0

    signal menuToggleRequested()

    readonly property color pillColor: (colors.widgetPillColors && pillIndex >= 0 && pillIndex < colors.widgetPillColors.length) ? colors.widgetPillColors[pillIndex] : colors.primary
    readonly property color pillTextColor: (colors.widgetTextOnPillColors && pillIndex >= 0 && pillIndex < colors.widgetTextOnPillColors.length) ? colors.widgetTextOnPillColors[pillIndex] : colors.textMain

    // When set, fullscreen captures this output only (e.g. from bar's screen). Empty = whole session.
    property string fullscreenOutput: ""
    property string screenshotFullscreenCommand: "grim - | wl-copy -t image/png"
    // Use temp file + wl-copy (grim -o and -g are mutually exclusive; use stdout redirect)
    property string screenshotSelectCommand: "C=\"${XDG_CACHE_HOME:-$HOME/.cache}\"; T=\"$C/quickshell-shot-$$.png\"; g=$(slurp); [ -n \"$g\" ] && grim -g \"$g\" - > \"$T\" && wl-copy -t image/png < \"$T\" && echo \"$g\" > \"$C/quickshell-last-slurp\"; rm -f \"$T\""
    property string screenshotLastCommand: "C=\"${XDG_CACHE_HOME:-$HOME/.cache}\"; f=\"$C/quickshell-last-slurp\"; T=\"$C/quickshell-shot-$$.png\"; [ -f \"$f\" ] && grim -g \"$(cat \"$f\")\" - > \"$T\" && wl-copy -t image/png < \"$T\"; rm -f \"$T\""

    implicitWidth: pill.width
    implicitHeight: 28

    Process {
        id: screenshotProc
        command: []
        running: false
    }

    // Scripts copy WAYLAND_DISPLAY from an existing process (e.g. kitty) so wl-copy works without opening a terminal.
    readonly property string _scriptDir: "$HOME/.config/scripts"
    function runScript(scriptName, envPrefix) {
        var ex = (envPrefix && envPrefix.length) ? (envPrefix + " ") : ""
        var path = screenshotWidget._scriptDir + "/" + scriptName
        screenshotProc.command = ["hyprctl", "dispatch", "exec", ex + "bash " + path]
        screenshotProc.running = false
        startScreenshotTimer.start()
    }
    function runInSession(shellCommand) {
        screenshotProc.command = ["hyprctl", "dispatch", "exec", "sh -c " + JSON.stringify(shellCommand)]
        screenshotProc.running = false
        startScreenshotTimer.start()
    }

    Timer {
        id: startScreenshotTimer
        interval: 50
        repeat: false
        onTriggered: {
            screenshotProc.running = true
        }
    }

    // Longer delay for region so menu closes and compositor releases input before slurp
    Timer {
        id: selectDelayTimer
        interval: 280
        repeat: false
        onTriggered: runScript("screenshot-region.sh", "")
    }

    function takeFullscreen() {
        var out = screenshotWidget.fullscreenOutput
        var envPrefix = (out && out.length) ? ("OUTPUT=" + JSON.stringify(out)) : ""
        runScript("screenshot-fullscreen.sh", envPrefix)
    }

    function takeSelect() {
        screenshotProc.running = false
        selectDelayTimer.start()
    }

    function takeLast() {
        runScript("screenshot-last.sh", "")
    }

    Rectangle {
        id: pill
        height: screenshotWidget.implicitHeight - (colors.widgetPillPaddingV) * 2
        width: row.implicitWidth + (colors.widgetPillPaddingH) * 2
        anchors.verticalCenter: parent.verticalCenter
        radius: colors.widgetPillRadius
        color: screenshotWidget.pillColor
        border.width: 1
        border.color: screenshotWidget.pillColor

        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            acceptedButtons: Qt.LeftButton
            onClicked: screenshotWidget.menuToggleRequested()
            Row {
                id: row
                anchors.centerIn: parent
                spacing: 4
                leftPadding: colors.widgetPillPaddingH
                rightPadding: colors.widgetPillPaddingH
                Text {
                    text: "\uF030"
                    color: screenshotWidget.pillTextColor
                    font.pixelSize: colors.cpuFontSize
                    font.family: colors.widgetIconFont
                }
                Text {
                    text: "Shot"
                    color: screenshotWidget.pillTextColor
                    font.pixelSize: colors.cpuFontSize
                }
            }
        }
    }
}
