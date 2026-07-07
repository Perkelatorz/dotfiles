pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

// Global bar visual style, shared by every BarPill and the settings picker.
// One source of truth so a single toggle restyles the whole bar. Persists to
// ~/.config/quickshell/bar-style.txt so the choice survives restarts.
Singleton {
    id: root

    // Available styles: id + human label. Order is also the cycle order.
    readonly property var styles: [
        { id: "pill",      label: "Pill" },
        { id: "neon",      label: "Neon" },
        { id: "glass",     label: "Glass" },
        { id: "underline", label: "Underline" },
        { id: "blocks",    label: "Blocks" }
    ]

    property string style: "pill"

    readonly property string _file:
        (Quickshell.env("XDG_CONFIG_HOME") || (Quickshell.env("HOME") + "/.config"))
        + "/quickshell/bar-style.txt"

    function _valid(s) {
        for (var i = 0; i < styles.length; i++)
            if (styles[i].id === s) return true
        return false
    }

    function setStyle(s) {
        if (!_valid(s) || s === style) return
        style = s
        writeProc.command = ["sh", "-c", "printf '%s' \"$1\" > \"$2\"", "sh", s, _file]
        writeProc.running = true
    }

    function cycle() {
        var i = 0
        for (var k = 0; k < styles.length; k++)
            if (styles[k].id === style) { i = k; break }
        setStyle(styles[(i + 1) % styles.length].id)
    }

    Process { id: writeProc; command: []; running: false }

    Process {
        id: readProc
        command: ["sh", "-c", "cat \"$1\" 2>/dev/null", "sh", root._file]
        running: true
        stdout: StdioCollector {
            onStreamFinished: {
                var s = (readProc.stdout.text || "").trim()
                if (root._valid(s)) root.style = s
                readProc.running = false
            }
        }
    }
}
