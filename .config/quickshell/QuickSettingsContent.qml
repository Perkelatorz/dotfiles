import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Services.Pipewire

import "."

ColumnLayout {
    id: quickSettingsRoot
    required property var colors
    required property var onClose
    property int screenIndex: 0

    signal openPowerRequested()
    signal openSettingsRequested()

    property string lockCommand: "swaylock"
    property string audioSettingsCommand: "pavucontrol"
    property string displaySettingsCommand: "nwg-displays"

    spacing: 12
    Layout.fillWidth: true

    // --- User + uptime + actions ---
    RowLayout {
        Layout.fillWidth: true
        spacing: 12
        Layout.bottomMargin: 4

        Rectangle {
            width: 48
            height: 48
            radius: 24
            color: colors.surfaceBright
            border.width: 1
            border.color: colors.border
            Text {
                anchors.centerIn: parent
                text: userInitial
                color: colors.primary
                font.pixelSize: 20
                font.bold: true
            }
        }
        Column {
            spacing: 2
            Layout.fillWidth: true
            Text {
                text: userName
                color: colors.textMain
                font.pixelSize: 16
                font.bold: true
            }
            Text {
                text: "up " + uptimeText
                color: colors.textDim
                font.pixelSize: 12
            }
        }
        Row {
            spacing: 6
            Repeater {
                model: [
                    { icon: "\uF023", action: "lock" },
                    { icon: "\uF011", action: "power" },
                    { icon: "\uF013", action: "settings" },
                    { icon: "\uF304", action: "edit" }
                ]
                delegate: Rectangle {
                    width: 32
                    height: 32
                    radius: 16
                    color: actionMa.containsMouse ? colors.surfaceBright : "transparent"
                    MouseArea {
                        id: actionMa
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: {
                            if (modelData.action === "lock") quickSettingsRoot.runInSession("sh -c 'command -v swaylock >/dev/null && exec swaylock || exec hyprlock'")
                            else if (modelData.action === "power") quickSettingsRoot.openPowerRequested()
                            else if (modelData.action === "settings") quickSettingsRoot.openSettingsRequested()
                            else if (modelData.action === "edit") quickSettingsRoot.runInSession("sh -c 'xdg-open \"$HOME/.config/quickshell\"'")
                        }
                    }
                    Text {
                        anchors.centerIn: parent
                        text: modelData.icon
                        color: colors.textMain
                        font.pixelSize: 14
                        font.family: colors.widgetIconFont
                    }
                }
            }
        }
    }

    Process {
        id: runProc
        command: []
        running: false
    }
    /// Run a command in the Hyprland session so GUI apps get WAYLAND_DISPLAY and open on the right display
    function runInSession(cmd) {
        runProc.command = ["hyprctl", "dispatch", "exec", cmd]
        runProc.running = true
    }

    property string userName: "user"
    property string userInitial: "?"
    Process {
        id: userProc
        command: ["sh", "-c", "id -un 2>/dev/null"]
        running: true
        stdout: StdioCollector {
            onStreamFinished: {
                var n = (userProc.stdout.text || "").trim()
                if (n) {
                    quickSettingsRoot.userName = n
                    quickSettingsRoot.userInitial = n.charAt(0).toUpperCase()
                }
                userProc.running = false
            }
        }
    }

    property string uptimeText: "..."
    Process {
        id: uptimeProc
        command: ["sh", "-c", "awk '{s=int($1); d=int(s/86400); h=int((s%86400)/3600); m=int((s%3600)/60); if(d>0) printf \"%d day%s, \", d, (d==1?\"\":\"s\"); printf \"%d hour%s, %d min\", h, (h==1?\"\":\"s\"), m; exit}' /proc/uptime 2>/dev/null"]
        running: true
        stdout: StdioCollector {
            onStreamFinished: {
                var t = (uptimeProc.stdout.text || "").trim()
                if (t) quickSettingsRoot.uptimeText = t
                uptimeProc.running = false
            }
        }
    }

    Timer {
        interval: 60000
        repeat: true
        running: quickSettingsRoot.visible
        onTriggered: { uptimeProc.running = true }
    }

    // --- Volume slider ---
    property var defaultSink: Pipewire.defaultAudioSink
    PwObjectTracker { objects: defaultSink ? [defaultSink] : [] }
    property real volumeLevel: defaultSink && defaultSink.audio ? defaultSink.audio.volume : 0
    property bool volumeMuted: defaultSink && defaultSink.audio ? defaultSink.audio.muted : false

    RowLayout {
        Layout.fillWidth: true
        spacing: 8
        Text {
            text: volumeMuted ? "\uF6A9" : "\uF028"
            color: colors.textMain
            font.pixelSize: 16
            font.family: colors.widgetIconFont
            Layout.preferredWidth: 24
        }
        Item {
            Layout.fillWidth: true
            Layout.preferredHeight: 28
            property real dragVal: -1
            readonly property real val: volSliderMa.pressed ? (dragVal >= 0 ? dragVal : quickSettingsRoot.volumeLevel) : quickSettingsRoot.volumeLevel
            Rectangle {
                id: volTrack
                width: parent.width
                height: 6
                radius: 3
                anchors.verticalCenter: parent.verticalCenter
                color: colors.surfaceBright
                Rectangle {
                    width: parent.width * parent.parent.val
                    height: parent.height
                    radius: 3
                    color: colors.primary
                }
            }
            Rectangle {
                width: 18
                height: 18
                radius: 9
                anchors.verticalCenter: parent.verticalCenter
                x: (parent.width - width) * parent.val
                color: volSliderMa.pressed ? colors.primaryContainer : colors.primary
                border.width: 1
                border.color: colors.border
            }
            MouseArea {
                id: volSliderMa
                anchors.fill: parent
                anchors.leftMargin: -9
                anchors.rightMargin: -9
                function setVal(x) {
                    var w = parent.width
                    var p = Math.min(1, Math.max(0, (x - 9) / w))
                    parent.dragVal = p
                    setVolumeProc.command = ["wpctl", "set-volume", "@DEFAULT_AUDIO_SINK@", Math.round(p * 100) + "%"]
                    setVolumeProc.running = true
                }
                onPressed: setVal(mouse.x)
                onPositionChanged: if (pressed) setVal(mouse.x)
                onReleased: parent.dragVal = -1
            }
        }
        Text {
            text: Math.round(quickSettingsRoot.volumeLevel * 100) + "%"
            color: colors.textDim
            font.pixelSize: 12
            Layout.preferredWidth: 36
        }
    }
    RowLayout {
        Layout.fillWidth: true
        Layout.leftMargin: 32
        spacing: 4
        Item { Layout.fillWidth: true }
        MouseArea {
            id: volGearMa
            width: 24
            height: 24
            hoverEnabled: true
            onClicked: quickSettingsRoot.runInSession(quickSettingsRoot.audioSettingsCommand)
            Rectangle {
                anchors.fill: parent
                radius: 4
                color: volGearMa.containsMouse ? colors.surfaceBright : "transparent"
            }
            Text {
                anchors.centerIn: parent
                text: "\uF013"
                color: colors.textDim
                font.pixelSize: 12
                font.family: colors.widgetIconFont
            }
        }
    }

    Process {
        id: setVolumeProc
        command: []
        running: false
    }

    // --- Brightness slider ---
    property bool hasBrightness: false
    property int brightnessLevel: 0
    property string backlightPath: ""
    property bool hasBrightnessctl: false
    property var brightnessctlDevices: []

    RowLayout {
        Layout.fillWidth: true
        spacing: 8
        visible: hasBrightness
        Text {
            text: "\uF185"
            color: colors.textMain
            font.pixelSize: 16
            font.family: colors.widgetIconFont
            Layout.preferredWidth: 24
        }
        Item {
            Layout.fillWidth: true
            Layout.preferredHeight: 28
            visible: quickSettingsRoot.hasBrightness
            property real dragVal: -1
            readonly property real val: (brightSliderMa.pressed && dragVal >= 0) ? dragVal : (quickSettingsRoot.brightnessLevel / 100)
            Rectangle {
                width: parent.width
                height: 6
                radius: 3
                anchors.verticalCenter: parent.verticalCenter
                color: colors.surfaceBright
                Rectangle {
                    width: parent.width * parent.parent.val
                    height: parent.height
                    radius: 3
                    color: colors.primary
                }
            }
            Rectangle {
                width: 18
                height: 18
                radius: 9
                anchors.verticalCenter: parent.verticalCenter
                x: (parent.width - width) * parent.val
                color: brightSliderMa.pressed ? colors.primaryContainer : colors.primary
                border.width: 1
                border.color: colors.border
            }
            MouseArea {
                id: brightSliderMa
                anchors.fill: parent
                anchors.leftMargin: -9
                anchors.rightMargin: -9
                function setVal(x) {
                    var w = parent.width
                    var p = Math.min(1, Math.max(0, (x - 9) / w))
                    parent.dragVal = p
                    quickSettingsRoot.setBrightness(Math.round(p * 100))
                }
                onPressed: setVal(mouse.x)
                onPositionChanged: if (pressed) setVal(mouse.x)
                onReleased: parent.dragVal = -1
            }
        }
        Text {
            text: quickSettingsRoot.brightnessLevel + "%"
            color: colors.textDim
            font.pixelSize: 12
            Layout.preferredWidth: 36
        }
    }
    RowLayout {
        Layout.fillWidth: true
        Layout.leftMargin: 32
        spacing: 4
        visible: hasBrightness
        Item { Layout.fillWidth: true }
        MouseArea {
            id: brightGearMa
            width: 24
            height: 24
            hoverEnabled: true
            onClicked: quickSettingsRoot.runInSession(quickSettingsRoot.displaySettingsCommand)
            Rectangle {
                anchors.fill: parent
                radius: 4
                color: brightGearMa.containsMouse ? colors.surfaceBright : "transparent"
            }
            Text {
                anchors.centerIn: parent
                text: "\uF108"
                color: colors.textDim
                font.pixelSize: 12
                font.family: colors.widgetIconFont
            }
        }
    }

    function setBrightness(percent) {
        var p = Math.max(0, Math.min(100, percent))
        if (backlightPath) {
            setBrightProc.command = ["sh", "-c", "m=$(cat \"" + backlightPath + "/max_brightness\"); v=$((m * " + p + " / 100)); echo $v > \"" + backlightPath + "/brightness\""]
            setBrightProc.running = true
        } else if (brightnessctlDevices.length > 0) {
            var dev = brightnessctlDevices[Math.min(screenIndex, brightnessctlDevices.length - 1)]
            setBrightProc.command = dev ? ["brightnessctl", "-d", dev, "set", p + "%"] : ["brightnessctl", "set", p + "%"]
            setBrightProc.running = true
        }
    }
    function refreshBrightness() {
        if (backlightPath) {
            readBrightProc.command = ["sh", "-c", "b=$(cat \"" + backlightPath + "/brightness\" 2>/dev/null); m=$(cat \"" + backlightPath + "/max_brightness\" 2>/dev/null); [ -n \"$m\" ] && [ \"$m\" -gt 0 ] && echo $((b*100/m)) || echo 0"]
            readBrightProc.running = true
        } else if (brightnessctlDevices.length > 0) {
            var dev = brightnessctlDevices[Math.min(screenIndex, brightnessctlDevices.length - 1)]
            readBrightProc.command = dev ? ["sh", "-c", "brightnessctl -d " + JSON.stringify(dev) + " -m 2>/dev/null"] : ["sh", "-c", "brightnessctl -m 2>/dev/null"]
            readBrightProc.running = true
        }
    }

    Process {
        id: backlightDetectProc
        command: ["sh", "-c", "d=$(ls -d /sys/class/backlight/* 2>/dev/null | head -1); if [ -n \"$d\" ] && [ -r \"$d/brightness\" ] && [ -r \"$d/max_brightness\" ]; then echo \"$d\"; else echo \"\"; fi"]
        running: false
        stdout: StdioCollector {
            onStreamFinished: {
                var p = (backlightDetectProc.stdout.text || "").trim()
                quickSettingsRoot.backlightPath = p
                if (p) {
                    quickSettingsRoot.hasBrightness = true
                    quickSettingsRoot.refreshBrightness()
                } else {
                    brightnessctlListProc.running = true
                }
                backlightDetectProc.running = false
            }
        }
    }
    Process {
        id: brightnessctlListProc
        command: ["sh", "-c", "brightnessctl -l 2>/dev/null"]
        running: false
        stdout: StdioCollector {
            onStreamFinished: {
                var out = (brightnessctlListProc.stdout.text || "").trim()
                var devices = []
                var lines = out.split("\n")
                for (var i = 0; i < lines.length; i++) {
                    var m = lines[i].match(/Device\s+(\S+)/)
                    if (m) devices.push(m[1])
                    else {
                        var tok = lines[i].split(/\s+/).filter(function(t) { return t.indexOf("::") >= 0 })
                        if (tok.length) devices.push(tok[0])
                    }
                }
                quickSettingsRoot.brightnessctlDevices = devices
                quickSettingsRoot.hasBrightness = devices.length > 0
                if (quickSettingsRoot.hasBrightness) quickSettingsRoot.refreshBrightness()
                brightnessctlListProc.running = false
            }
        }
    }
    Process {
        id: readBrightProc
        command: []
        running: false
        stdout: StdioCollector {
            onStreamFinished: {
                var line = (readBrightProc.stdout.text || "").trim()
                var m = line.match(/(\d+)%?\s*$/)
                if (m) quickSettingsRoot.brightnessLevel = Math.max(0, Math.min(100, parseInt(m[1], 10)))
                else {
                    var v = parseInt(line, 10)
                    if (!isNaN(v)) quickSettingsRoot.brightnessLevel = Math.max(0, Math.min(100, v))
                }
                readBrightProc.running = false
            }
        }
    }
    Process {
        id: setBrightProc
        command: []
        running: false
        onRunningChanged: if (!running && hasBrightness) quickSettingsRoot.refreshBrightness()
    }
    Timer {
        interval: 2000
        repeat: true
        running: quickSettingsRoot.hasBrightness && quickSettingsRoot.visible
        onTriggered: quickSettingsRoot.refreshBrightness()
    }

    // --- Cards grid ---
    GridLayout {
        Layout.fillWidth: true
        columns: 2
        rowSpacing: 8
        columnSpacing: 8

        QuickSettingCard {
            colors: quickSettingsRoot.colors
            icon: batteryHas ? (batteryStatus === "Charging" ? "\uF0E7" : "\uF240") : "\uF244"
            title: "Battery"
            status: batteryHas ? (batteryCapacity + "% " + batteryStatus) : "N/A"
        }
        QuickSettingCard {
            colors: quickSettingsRoot.colors
            icon: volumeMuted ? "\uF6A9" : "\uF028"
            title: audioSinkName || "Audio"
            status: Math.round(quickSettingsRoot.volumeLevel * 100) + "%"
            onClick: function() { quickSettingsRoot.runInSession(quickSettingsRoot.audioSettingsCommand) }
        }
        QuickSettingCard {
            colors: quickSettingsRoot.colors
            icon: micMuted ? "\uF131" : "\uF130"
            title: "Microphone"
            status: micMuted ? "Muted" : "On"
        }
        QuickSettingCard {
            colors: quickSettingsRoot.colors
            icon: "\uF1EB"
            title: "Wi‑Fi"
            status: wifiStatus
            onClick: function() { quickSettingsRoot.runInSession("nm-connection-editor") }
        }
        QuickSettingCard {
            colors: quickSettingsRoot.colors
            icon: "\uF293"
            title: "Bluetooth"
            status: btStatus
            onClick: function() { quickSettingsRoot.runInSession("sh -c 'blueman-manager 2>/dev/null || bluetoothctl'") }
        }
        QuickSettingCard {
            colors: quickSettingsRoot.colors
            icon: "\uF0A0"
            title: "Disk"
            status: diskStatus
        }
        QuickSettingCard {
            colors: quickSettingsRoot.colors
            icon: "\uF21B"
            title: "VPN"
            status: vpnStatus
            onClick: function() { quickSettingsRoot.runInSession("nm-connection-editor") }
        }
        QuickSettingCard {
            colors: quickSettingsRoot.colors
            icon: "\uF02F"
            title: "Printers"
            status: printersStatus
            onClick: function() { quickSettingsRoot.runInSession("system-config-printer") }
        }
        QuickSettingCard {
            colors: quickSettingsRoot.colors
            icon: "\uF185"
            title: "Theme"
            status: "Dark"
            onClick: function() { quickSettingsRoot.runInSession("sh -c '\"$HOME/.config/quickshell/select-wallpaper.sh\" --material'") }
        }
    }

    property string audioSinkName: ""
    property string diskStatus: "No data"
    property string vpnStatus: "Disconnected"
    property string printersStatus: "No data"

    property bool batteryHas: false
    property int batteryCapacity: 0
    property string batteryStatus: ""
    Process {
        id: batteryProc
        command: ["sh", "-c", "d=$(ls -d /sys/class/power_supply/BAT* 2>/dev/null | head -1); if [ -n \"$d\" ] && [ -r \"$d/capacity\" ]; then echo 1; cat \"$d/capacity\"; cat \"$d/status\" 2>/dev/null; else echo 0; fi"]
        running: true
        stdout: StdioCollector {
            onStreamFinished: {
                var lines = (batteryProc.stdout.text || "").trim().split("\n")
                quickSettingsRoot.batteryHas = lines.length >= 1 && lines[0] === "1"
                if (quickSettingsRoot.batteryHas && lines.length >= 2) {
                    var p = parseInt(lines[1], 10)
                    quickSettingsRoot.batteryCapacity = isNaN(p) ? 0 : Math.max(0, Math.min(100, p))
                    quickSettingsRoot.batteryStatus = lines.length >= 3 ? String(lines[2]).trim() : ""
                }
                batteryProc.running = false
            }
        }
    }
    Timer {
        interval: 60000
        repeat: true
        running: quickSettingsRoot.visible
        onTriggered: batteryProc.running = true
    }

    property bool micMuted: false
    property var defaultSource: Pipewire.defaultAudioSource
    PwObjectTracker { objects: defaultSource ? [defaultSource] : [] }
    Binding {
        target: quickSettingsRoot
        property: "micMuted"
        value: quickSettingsRoot.defaultSource && quickSettingsRoot.defaultSource.audio ? quickSettingsRoot.defaultSource.audio.muted : false
        when: quickSettingsRoot.defaultSource != null
    }

    property string wifiStatus: "N/A"
    property string btStatus: "N/A"
    Component.onCompleted: {
        backlightDetectProc.running = true
        wifiProc.running = true
        btProc.running = true
        sinkNameProc.running = true
        diskProc.running = true
        vpnProc.running = true
        printersProc.running = true
    }
    Process {
        id: sinkNameProc
        command: ["sh", "-c", "wpctl status 2>/dev/null | grep -A 200 'Sinks:' | grep '\\*' | head -1 | sed 's/^[^.]*\\. //; s/\\s*\\[.*//; s/^\\s*//'"]
        running: false
        stdout: StdioCollector {
            onStreamFinished: {
                var s = (sinkNameProc.stdout.text || "").trim()
                if (s) quickSettingsRoot.audioSinkName = s.length > 22 ? s.slice(0, 19) + "…" : s
                sinkNameProc.running = false
            }
        }
    }
    Timer {
        interval: 5000
        repeat: true
        running: quickSettingsRoot.visible
        onTriggered: sinkNameProc.running = true
    }
    Process {
        id: wifiProc
        command: ["sh", "-c", "nmcli -t -f active,ssid,signal dev wifi 2>/dev/null | grep '^yes' | head -1 | cut -d: -f2-"]
        running: false
        stdout: StdioCollector {
            onStreamFinished: {
                var s = (wifiProc.stdout.text || "").trim()
                if (s) {
                    var parts = s.split(":")
                    quickSettingsRoot.wifiStatus = parts.length >= 2 ? (parts[0] + " " + parts[1] + "%") : s
                } else {
                    quickSettingsRoot.wifiStatus = "Disconnected"
                }
                wifiProc.running = false
            }
        }
    }
    Process {
        id: btProc
        command: ["sh", "-c", "p=$(bluetoothctl show 2>/dev/null | grep 'Powered: yes'); n=$(bluetoothctl devices 2>/dev/null | wc -l); if [ -z \"$p\" ]; then echo 'Off'; elif [ \"$n\" -eq 0 ]; then echo 'No devices'; elif [ \"$n\" -eq 1 ]; then echo '1 device'; else echo \"$n devices\"; fi"]
        running: false
        stdout: StdioCollector {
            onStreamFinished: {
                var s = (btProc.stdout.text || "").trim()
                quickSettingsRoot.btStatus = s || "N/A"
                btProc.running = false
            }
        }
    }
    Process {
        id: diskProc
        command: ["sh", "-c", "df -h / 2>/dev/null | tail -1 | awk '{print $5 \" used\"}'"]
        running: false
        stdout: StdioCollector {
            onStreamFinished: {
                var s = (diskProc.stdout.text || "").trim()
                quickSettingsRoot.diskStatus = s || "No data"
                diskProc.running = false
            }
        }
    }
    Process {
        id: vpnProc
        command: ["sh", "-c", "nmcli -t -f name,type con show --active 2>/dev/null | grep -E ':vpn|:wireguard' | head -1 | cut -d: -f1 || echo 'Disconnected'"]
        running: false
        stdout: StdioCollector {
            onStreamFinished: {
                var s = (vpnProc.stdout.text || "").trim()
                quickSettingsRoot.vpnStatus = s || "Disconnected"
                vpnProc.running = false
            }
        }
    }
    Process {
        id: printersProc
        command: ["sh", "-c", "n=$(lpstat -p 2>/dev/null | grep -c '^printer' || true); j=$(lpstat -o 2>/dev/null | wc -l); echo \"$n $j\""]
        running: false
        stdout: StdioCollector {
            onStreamFinished: {
                var parts = (printersProc.stdout.text || "").trim().split(/\s+/)
                var n = parseInt(parts[0], 10) || 0
                var j = parseInt(parts[1], 10) || 0
                quickSettingsRoot.printersStatus = "Printers: " + n + " - Jobs: " + j
                printersProc.running = false
            }
        }
    }
    Timer {
        interval: 30000
        repeat: true
        running: quickSettingsRoot.visible
        onTriggered: {
            diskProc.running = true
            vpnProc.running = true
            printersProc.running = true
        }
    }

    Item { Layout.fillHeight: true }
}
