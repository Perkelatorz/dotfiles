import QtQuick
import Quickshell.Io

// Polling process helper: runs `command` every `interval` ms while `active`,
// emits `output(text)` when stdout closes. Replaces the repeated
// Process+StdioCollector+Timer triplet in widgets. Resets `running` on exit
// (the inline pattern only reset on stream-finished, leaking the flag if the
// process failed before writing stdout).
QtObject {
    id: root

    property var command: []
    property int interval: 5000
    property bool active: true
    property bool runOnStart: true

    signal output(string text)

    function refresh(): void {
        if (root.command.length > 0 && !proc.running) proc.running = true
    }

    readonly property Process _proc: Process {
        id: proc
        command: root.command
        running: false
        stdout: StdioCollector {
            onStreamFinished: {
                root.output(this.text || "")
                proc.running = false
            }
        }
        onExited: proc.running = false
    }

    readonly property Timer _timer: Timer {
        interval: root.interval
        repeat: true
        running: root.active
        triggeredOnStart: root.runOnStart
        onTriggered: if (root.command.length > 0 && !proc.running) proc.running = true
    }
}
