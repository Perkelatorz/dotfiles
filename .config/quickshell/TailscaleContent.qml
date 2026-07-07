import QtQuick
import Quickshell.Io

import "."

// Popup body for the Tailscale widget: lists every machine on the tailnet
// (this device first, then online peers, then offline). Click a row to copy
// that machine's IP. Polls `tailscale status --json` each time it opens so the
// list is always fresh.
Column {
    id: tsMenu
    required property var colors
    required property var onClose
    property bool panelOpen: false

    spacing: 0
    width: 260
    padding: 4

    property var machines: []
    property string note: ""

    onPanelOpenChanged: if (panelOpen && !statusProc.running) statusProc.running = true

    Process {
        id: statusProc
        command: ["sh", "-c", "command -v tailscale >/dev/null && tailscale status --json 2>/dev/null || echo MISSING"]
        running: false
        stdout: StdioCollector {
            onStreamFinished: {
                statusProc.running = false
                var s = (this.text || "").trim()
                if (s === "MISSING" || s === "") {
                    tsMenu.machines = []
                    tsMenu.note = "tailscale not installed"
                    return
                }
                try {
                    var obj = JSON.parse(s)
                    var list = []
                    function add(node, isSelf) {
                        if (!node) return
                        var ip = (Array.isArray(node.TailscaleIPs) && node.TailscaleIPs.length > 0)
                               ? String(node.TailscaleIPs[0]) : ""
                        if (!ip) return
                        var name = node.HostName
                                 ? String(node.HostName)
                                 : (node.DNSName ? String(node.DNSName).split(".")[0] : ip)
                        list.push({ name: name, ip: ip, online: node.Online === true,
                                    os: node.OS || "", self: isSelf })
                    }
                    add(obj.Self, true)
                    if (obj.Peer) { for (var k in obj.Peer) add(obj.Peer[k], false) }
                    // Self first, then online before offline, then alphabetical.
                    list.sort(function(a, b) {
                        if (a.self !== b.self) return a.self ? -1 : 1
                        if (a.online !== b.online) return a.online ? -1 : 1
                        return a.name.localeCompare(b.name)
                    })
                    tsMenu.machines = list
                    tsMenu.note = (list.length === 0) ? "no machines found" : ""
                } catch (e) {
                    tsMenu.machines = []
                    tsMenu.note = "could not read status"
                }
            }
        }
    }

    Process { id: copyProc; command: []; running: false }

    // Header
    Item {
        width: tsMenu.width - 8
        height: 26
        Text {
            anchors.verticalCenter: parent.verticalCenter
            x: 8
            text: "Tailnet"
            color: tsMenu.colors.textDim
            font.pixelSize: tsMenu.colors.clockFontSize
            font.bold: true
        }
    }

    // Empty / error note
    Text {
        visible: tsMenu.note !== ""
        text: tsMenu.note
        x: 8
        bottomPadding: 6
        color: tsMenu.colors.textDim
        font.pixelSize: tsMenu.colors.clockFontSize
    }

    Repeater {
        model: tsMenu.machines
        delegate: MouseArea {
            id: rowMa
            width: tsMenu.width - 8
            height: 38
            hoverEnabled: true
            property bool copied: false
            onClicked: {
                copyProc.command = ["wl-copy", modelData.ip]
                copyProc.running = true
                rowMa.copied = true
                copiedTimer.restart()
            }
            Timer { id: copiedTimer; interval: 1200; onTriggered: rowMa.copied = false }

            Rectangle {
                anchors.fill: parent
                radius: 6
                color: rowMa.containsMouse ? tsMenu.colors.surfaceBright : "transparent"
            }
            Row {
                anchors.left: parent.left
                anchors.leftMargin: 10
                anchors.verticalCenter: parent.verticalCenter
                spacing: 9
                Rectangle {
                    anchors.verticalCenter: parent.verticalCenter
                    width: 7
                    height: 7
                    radius: 4
                    color: modelData.online ? "#3dd57e" : "#7a7a7a"
                }
                Column {
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 1
                    Text {
                        text: modelData.name + (modelData.self ? "  · this device" : "")
                        color: tsMenu.colors.textMain
                        font.pixelSize: tsMenu.colors.clockFontSize
                    }
                    Text {
                        text: rowMa.copied ? "Copied!" : modelData.ip
                        color: rowMa.copied ? tsMenu.colors.primary : tsMenu.colors.textDim
                        font.pixelSize: tsMenu.colors.clockFontSize - 1
                    }
                }
            }
            // Copy hint on hover
            Text {
                anchors.verticalCenter: parent.verticalCenter
                anchors.right: parent.right
                anchors.rightMargin: 12
                visible: rowMa.containsMouse && !rowMa.copied
                text: ""
                color: tsMenu.colors.primary
                font.pixelSize: 12
                font.family: tsMenu.colors.widgetIconFont
            }
        }
    }
}
