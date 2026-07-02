import QtQuick
import Quickshell.Io

import "."

// Tailscale connection status: status dot + IP when up; click copies the IP.
// Hidden entirely when tailscale isn't installed.
BarPill {
    id: tsWidget
    pillIndex: 1

    property bool connected: false
    property string ipAddress: ""
    property string hostname: ""
    property string backendState: ""
    property bool installed: true
    property bool _copied: false

    label: _copied ? "Copied!"
         : connected ? (ipAddress || "tailscale")
         : (backendState || "off")
    present: installed

    // Status dot rides in the pill's content row.
    Rectangle {
        anchors.verticalCenter: parent.verticalCenter
        width: 8
        height: 8
        radius: 4
        color: tsWidget.connected ? "#3dd57e" : "#ff5c5c"
    }

    PollingProcess {
        command: ["sh", "-c", "command -v tailscale >/dev/null && tailscale status --json 2>/dev/null || echo MISSING"]
        interval: 30000
        active: tsWidget.visible
        onOutput: (text) => {
            var s = (text || "").trim()
            if (s === "MISSING" || s === "") {
                tsWidget.installed = false
                return
            }
            tsWidget.installed = true
            try {
                var obj = JSON.parse(s)
                tsWidget.backendState = obj.BackendState || ""
                tsWidget.connected = (obj.BackendState === "Running") && obj.Self && obj.Self.Online === true
                if (obj.Self && Array.isArray(obj.Self.TailscaleIPs) && obj.Self.TailscaleIPs.length > 0) {
                    tsWidget.ipAddress = String(obj.Self.TailscaleIPs[0])
                }
                if (obj.Self && obj.Self.HostName) tsWidget.hostname = String(obj.Self.HostName)
            } catch (_) {
                tsWidget.connected = false
            }
        }
    }
    Process {
        id: copyProc
        command: []
        running: false
    }
    Timer { id: copiedTimer; interval: 1500; onTriggered: tsWidget._copied = false }

    onClicked: {
        if (!tsWidget.ipAddress) return
        copyProc.command = ["wl-copy", tsWidget.ipAddress]
        copyProc.running = true
        tsWidget._copied = true
        copiedTimer.restart()
    }
}
