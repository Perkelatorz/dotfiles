import QtQuick
import Quickshell.Io

import "."

BarPill {
    id: ipWidget
    pillIndex: 1

    property string ipAddress: ""
    property bool _copied: false

    icon: ""
    label: {
        if (_copied) return "Copied!"
        var a = (ipAddress || "").trim()
        return (a === "" || a === "--") ? "No network" : a
    }

    PollingProcess {
        command: ["sh", "-c", "ip -4 addr show scope global 2>/dev/null | grep -oE 'inet [0-9.]+/[0-9]+' | head -1 | awk '{print $2}'"]
        interval: 60000
        active: ipWidget.visible
        onOutput: (text) => ipWidget.ipAddress = (text || "").trim() || "--"
    }
    Process {
        id: runConnectionEditor
        command: ["nm-connection-editor"]
        running: false
    }
    Process {
        id: copyIpProc
        command: []
        running: false
    }
    Timer { id: copiedTimer; interval: 1500; onTriggered: ipWidget._copied = false }

    onClicked: mouse => {
        if (mouse.button === Qt.MiddleButton) {
            copyIpProc.command = ["wl-copy", ipWidget.ipAddress]
            copyIpProc.running = true
            ipWidget._copied = true
            copiedTimer.restart()
        } else if (mouse.button === Qt.RightButton) {
            runConnectionEditor.running = true
        }
    }
}
