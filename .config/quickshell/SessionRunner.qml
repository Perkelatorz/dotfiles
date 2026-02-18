import QtQuick
import Quickshell.Io

import "."

Item {
    id: sessionRunner
    width: 0; height: 0; visible: false

    property string compositorName: "hyprland"

    Process {
        id: proc
        command: []
        running: false
    }

    function run(cmd) {
        if (compositorName === "hyprland") {
            proc.command = ["hyprctl", "dispatch", "exec", cmd]
        } else if (compositorName === "mangowc") {
            proc.command = ["mmsg", "-d", "spawn_shell," + cmd]
        } else {
            proc.command = ["sh", "-c", cmd]
        }
        proc.running = false
        proc.running = true
    }
}
