import QtQuick
import Quickshell.Io

import "."

// Wi-Fi control-center subview: on/off toggle, rescan, and a live network list
// (nmcli). Click a network to connect; secured networks that aren't already
// saved prompt for a password via rofi (keeps focus out of the layer-shell).
Item {
    id: wifi
    required property var colors
    property bool panelOpen: false

    property var networks: []   // { ssid, signal, secured, active }
    property bool scanning: false
    readonly property bool enabledNow: SystemServices.wifiEnabled

    function refresh() {
        if (scanProc.running) return
        scanning = true
        scanProc.running = true
    }
    onPanelOpenChanged: if (panelOpen) refresh()

    Process {
        id: scanProc
        command: ["sh", "-c", "nmcli -t -f IN-USE,SIGNAL,SECURITY,SSID dev wifi list 2>/dev/null"]
        running: false
        stdout: StdioCollector {
            onStreamFinished: {
                // nmcli -t escapes ':' inside values as '\:'. SSID is last, so
                // stash escaped colons, split on the field separator, restore.
                var lines = (this.text || "").split("\n")
                var seen = ({})
                var arr = []
                for (var i = 0; i < lines.length; i++) {
                    var ln = lines[i]
                    if (!ln) continue
                    // IN-USE:SIGNAL:SECURITY:SSID — only SSID can contain colons
                    // (escaped by nmcli as '\\:'), so match the first three fields
                    // as non-colon runs and take the rest as the SSID.
                    var m = ln.match(/^([^:]*):([^:]*):([^:]*):(.*)$/)
                    if (!m) continue
                    var ssid = m[4].replace(/\\:/g, ":")
                    if (!ssid) continue
                    var sig = parseInt(m[2], 10); if (isNaN(sig)) sig = 0
                    var secured = m[3] !== "" && m[3] !== "--"
                    var active = m[1] === "*"
                    if (seen[ssid] !== undefined) {
                        var e = arr[seen[ssid]]
                        if (e.signal < sig) e.signal = sig
                        e.active = e.active || active
                        continue
                    }
                    seen[ssid] = arr.length
                    arr.push({ ssid: ssid, signal: sig, secured: secured, active: active })
                }
                arr.sort(function(a, b) {
                    if (a.active !== b.active) return a.active ? -1 : 1
                    return b.signal - a.signal
                })
                wifi.networks = arr
                wifi.scanning = false
                scanProc.running = false
            }
        }
    }
    Process { id: actProc; command: []; running: false; onExited: wifi.refresh() }

    function connect(ssid) {
        actProc.command = ["sh", "-c",
            'ssid="$1"; ' +
            'if nmcli dev wifi connect "$ssid" 2>/dev/null; then ' +
            '  notify-send "Wi-Fi" "Connected to $ssid" 2>/dev/null; exit 0; fi; ' +
            'p=$(rofi -dmenu -password -p "Password for $ssid" 2>/dev/null); ' +
            '[ -n "$p" ] || exit 0; ' +
            'if nmcli dev wifi connect "$ssid" password "$p" 2>/dev/null; then ' +
            '  notify-send "Wi-Fi" "Connected to $ssid" 2>/dev/null; ' +
            'else notify-send -u critical "Wi-Fi" "Failed to connect to $ssid" 2>/dev/null; fi',
            "sh", ssid]
        actProc.running = true
    }

    Column {
        anchors.fill: parent
        anchors.margins: 8
        spacing: 8

        Row {
            width: parent.width
            height: 40
            spacing: 8
            Rectangle {
                width: parent.width - 48
                height: 40
                radius: 10
                color: wifi.enabledNow ? wifi.colors.primaryContainer : wifi.colors.surfaceBright
                border.width: 1
                border.color: wifi.enabledNow ? wifi.colors.primary : wifi.colors.borderSubtle
                Text {
                    id: wifiPowerIcon
                    anchors.left: parent.left
                    anchors.leftMargin: 12
                    anchors.verticalCenter: parent.verticalCenter
                    text: wifi.enabledNow ? "\uF1EB" : "\uF05E"
                    font.family: wifi.colors.widgetIconFont
                    font.pixelSize: 16
                    color: wifi.enabledNow ? wifi.colors.textOnPrimaryContainer : wifi.colors.primary
                }
                Text {
                    anchors.left: wifiPowerIcon.right
                    anchors.leftMargin: 12
                    anchors.verticalCenter: parent.verticalCenter
                    text: wifi.enabledNow ? "Wi-Fi On" : "Wi-Fi Off"
                    color: wifi.enabledNow ? wifi.colors.textOnPrimaryContainer : wifi.colors.textMain
                    font.pixelSize: wifi.colors.clockFontSize
                }
                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: SystemServices.toggleWifi()
                }
            }
            Rectangle {
                width: 40
                height: 40
                radius: 10
                color: rescanMa.containsMouse ? wifi.colors.surfaceBright : "transparent"
                border.width: 1
                border.color: wifi.colors.borderSubtle
                Text {
                    anchors.centerIn: parent
                    text: "\uF021"
                    font.family: wifi.colors.widgetIconFont
                    font.pixelSize: 15
                    color: wifi.colors.primary
                    RotationAnimation on rotation {
                        running: wifi.scanning
                        loops: Animation.Infinite
                        from: 0; to: 360; duration: 900
                    }
                }
                MouseArea {
                    id: rescanMa
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: wifi.refresh()
                }
            }
        }

        Item {
            width: parent.width
            height: parent.height - 40 - 8

            Text {
                anchors.top: parent.top
                width: parent.width
                visible: !wifi.enabledNow
                text: "Turn on Wi-Fi to see networks."
                color: wifi.colors.textDim
                font.pixelSize: wifi.colors.clockFontSize
            }
            Text {
                anchors.top: parent.top
                width: parent.width
                visible: wifi.enabledNow && wifi.networks.length === 0
                text: wifi.scanning ? "Scanning…" : "No networks found."
                color: wifi.colors.textDim
                font.pixelSize: wifi.colors.clockFontSize
            }

            ListView {
                id: netList
                anchors.fill: parent
                clip: true
                spacing: 4
                visible: wifi.enabledNow && wifi.networks.length > 0
                model: wifi.networks
                delegate: Rectangle {
                    width: netList.width
                    height: 42
                    radius: 8
                    color: netMa.containsMouse ? wifi.colors.surfaceBright : "transparent"
                    Text {
                        id: netIcon
                        anchors.left: parent.left
                        anchors.leftMargin: 12
                        anchors.verticalCenter: parent.verticalCenter
                        text: "\uF1EB"
                        font.family: wifi.colors.widgetIconFont
                        font.pixelSize: 14
                        color: modelData.active ? wifi.colors.primary : wifi.colors.textDim
                    }
                    Text {
                        anchors.left: netIcon.right
                        anchors.leftMargin: 12
                        anchors.right: netMeta.left
                        anchors.rightMargin: 8
                        anchors.verticalCenter: parent.verticalCenter
                        text: modelData.ssid
                        color: modelData.active ? wifi.colors.primary : wifi.colors.textMain
                        font.pixelSize: wifi.colors.clockFontSize
                        font.bold: modelData.active
                        elide: Text.ElideRight
                    }
                    Row {
                        id: netMeta
                        anchors.right: parent.right
                        anchors.rightMargin: 12
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 6
                        Text {
                            visible: modelData.secured
                            text: "\uF023"
                            font.family: wifi.colors.widgetIconFont
                            font.pixelSize: 12
                            color: wifi.colors.textDim
                            anchors.verticalCenter: parent.verticalCenter
                        }
                        Text {
                            text: modelData.signal + "%"
                            color: wifi.colors.textDim
                            font.pixelSize: wifi.colors.clockFontSize - 2
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }
                    MouseArea {
                        id: netMa
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: if (!modelData.active) wifi.connect(modelData.ssid)
                    }
                }
            }
        }
    }
}
