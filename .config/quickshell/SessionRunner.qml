import QtQuick
import Quickshell.Io

import "."

/**
 * Shared helper: runs a command in the compositor session.
 * On Hyprland uses `hyprctl dispatch exec` for correct Wayland env;
 * on other compositors falls back to `sh -c`.
 *
 * Usage:
 *   SessionRunner { id: runner; compositorName: bar.compositorName }
 *   runner.run("pavucontrol")
 */
Item {
    id: sessionRunner
    width: 0; height: 0; visible: false

    property string compositorName: "hyprland"

    Process {
        id: proc
        command: []
        running: false
        stdout: StdioCollector {
            onStreamFinished: proc.running = false
        }
    }

    function run(cmd) {
        if (compositorName === "hyprland") {
            proc.command = ["hyprctl", "dispatch", "exec", cmd]
        } else if (compositorName === "mangowc") {
            proc.command = ["mmsg", "-d", "spawn," + cmd]
        } else {
            proc.command = ["sh", "-c", cmd]
        }
        if (!proc.running) proc.running = true
    }
}
