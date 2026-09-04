import QtQuick
import Quickshell.Io

import "."

Item {
    id: sessionRunner
    width: 0; height: 0; visible: false

    property string compositorName: "mango"

    Process {
        id: proc
        command: []
        running: false
    }

    function run(cmd) {
        if (compositorName === "mango") {
            // Hand it to the compositor rather than `sh -c` so the app is
            // reparented to mango, not to quickshell — otherwise restarting the
            // bar takes every app it launched down with it. spawn_shell (not
            // spawn) so pipes and quoting behave as they would in a shell.
            proc.command = ["mmsg", "dispatch", "spawn_shell," + cmd]
        } else {
            proc.command = ["sh", "-c", cmd]
        }
        proc.running = false
        proc.running = true
    }
}
