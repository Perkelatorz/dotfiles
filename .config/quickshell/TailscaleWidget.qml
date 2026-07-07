import QtQuick
import Quickshell.Io

import "."

// Tailscale: an icon in the bar. Click opens a popup listing every machine on
// the tailnet; click a machine there to copy its IP. Hidden entirely when
// tailscale isn't installed. A small dot shows connection state at a glance.
BarPill {
    id: tsWidget
    pillIndex: 1

    signal toggleRequested()

    property bool connected: false
    property bool installed: true

    icon: "\uF0E8"    // nf-fa-sitemap — a network of machines
    present: installed
    onClicked: tsWidget.toggleRequested()

    // Connection dot rides alongside the icon in the pill's content row.
    Rectangle {
        anchors.verticalCenter: parent.verticalCenter
        width: 7
        height: 7
        radius: 4
        color: tsWidget.connected ? "#3dd57e" : "#ff5c5c"
    }

    // Lightweight poll just to colour the dot; the popup fetches the full list.
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
                tsWidget.connected = (obj.BackendState === "Running") && obj.Self && obj.Self.Online === true
            } catch (_) {
                tsWidget.connected = false
            }
        }
    }
}
