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
    property string compositorName: "hyprland"
    property int screenIndex: 0

    signal openPowerRequested()
    signal openSettingsRequested()

    property string lockCommand: "swaylock"
    property string audioSettingsCommand: "pavucontrol"
    property string displaySettingsCommand: "wdisplays"
    property string batterySettingsCommand: ""
    property string diskSettingsCommand: "sh -c \"thunar \\$HOME\""
    property string systemMonitorCommand: "kitty -e btop"

    spacing: 12
    Layout.fillWidth: true

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
            clip: true
            Image {
                id: avatarImage
                anchors.fill: parent
                fillMode: Image.PreserveAspectCrop
                source: (colors.avatarPath && colors.avatarPath.length > 0)
                    ? ("file://" + colors.avatarPath)
                    : (quickSettingsRoot.homePath ? ("file://" + quickSettingsRoot.homePath + "/.face") : "")
                visible: status === Image.Ready
                onStatusChanged: if (status === Image.Error && source !== "") source = ""
            }
            Text {
                anchors.centerIn: parent
                text: userInitial
                color: colors.primary
                font.pixelSize: 20
                font.bold: true
                visible: !avatarImage.visible
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

    SessionRunner {
        id: sessionRunner
        compositorName: quickSettingsRoot.compositorName
    }
    function runInSession(cmd) { sessionRunner.run(cmd) }

    property string userName: "user"
    property string userInitial: "?"
    property string homePath: ""
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
    Process {
        id: homeProc
        command: ["sh", "-c", "echo ${HOME:-}"]
        running: true
        stdout: StdioCollector {
            onStreamFinished: {
                var h = (homeProc.stdout.text || "").trim()
                if (h) quickSettingsRoot.homePath = h
                homeProc.running = false
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
            Layout.minimumWidth: 40
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
            Layout.minimumWidth: 40
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

    GridLayout {
        Layout.fillWidth: true
        Layout.bottomMargin: 16
        columns: 2
        rowSpacing: 8
        columnSpacing: 8

        QuickSettingCard {
            colors: quickSettingsRoot.colors
            icon: quickSettingsRoot.micMuted ? "\uF131" : "\uF130"
            title: "Microphone"
            status: quickSettingsRoot.micMuted ? "Muted" : "On"
            active: !quickSettingsRoot.micMuted
            onClick: function() { quickSettingsRoot.toggleMic() }
            onRightClick: function() { quickSettingsRoot.runInSession(quickSettingsRoot.audioSettingsCommand) }
        }
        QuickSettingCard {
            colors: quickSettingsRoot.colors
            icon: quickSettingsRoot.wifiEnabled ? "\uF1EB" : "\uF05E"
            title: "Wi-Fi"
            status: quickSettingsRoot.wifiEnabled
                ? (quickSettingsRoot.wifiStatus + (quickSettingsRoot.vpnStatus !== "Disconnected" ? ("\n\uF21B " + quickSettingsRoot.vpnStatus) : ""))
                : "Off"
            active: quickSettingsRoot.wifiEnabled
            onClick: function() { quickSettingsRoot.toggleWifi() }
            onRightClick: function() { quickSettingsRoot.runInSession("nm-connection-editor") }
        }
        QuickSettingCard {
            colors: quickSettingsRoot.colors
            icon: "\uF293"
            title: "Bluetooth"
            status: quickSettingsRoot.btStatus
            active: quickSettingsRoot.btPowered
            onClick: function() { quickSettingsRoot.toggleBluetooth() }
            onRightClick: function() { quickSettingsRoot.runInSession("sh -c 'blueman-manager 2>/dev/null || bluetoothctl'") }
        }
        QuickSettingCard {
            colors: quickSettingsRoot.colors
            enabled: batteryHas || !!batterySettingsCommand
            icon: batteryHas ? (batteryStatus === "Charging" ? "\uF0E7" : "\uF240") : "\uF244"
            title: "Battery"
            status: batteryHas ? (batteryCapacity + "% " + batteryStatus) : "N/A"
            active: batteryHas && batteryStatus === "Charging"
            progress: batteryHas ? batteryCapacity / 100 : -1
            onClick: batterySettingsCommand ? function() { quickSettingsRoot.runInSession(batterySettingsCommand) } : null
        }
        QuickSettingCard {
            colors: quickSettingsRoot.colors
            icon: quickSettingsRoot.qsPowerIcon
            title: "Power Profile"
            status: quickSettingsRoot.qsPowerProfile
            active: quickSettingsRoot.qsPowerProfile.toLowerCase() === "performance"
            onClick: function() { quickSettingsRoot.cyclePowerProfile() }
        }
        QuickSettingCard {
            colors: quickSettingsRoot.colors
            icon: "\uF0AC"
            title: "Network"
            status: quickSettingsRoot.qsNetSpeed
            onClick: function() { quickSettingsRoot.runInSession("nm-connection-editor") }
        }
        QuickSettingCard {
            colors: quickSettingsRoot.colors
            enabled: !!diskSettingsCommand
            icon: "\uF0A0"
            title: "Disk"
            status: diskStatus
            progress: quickSettingsRoot.diskPercent / 100
            onClick: diskSettingsCommand ? function() { quickSettingsRoot.runInSession(quickSettingsRoot.diskSettingsCommand) } : null
        }
        QuickSettingCard {
            colors: quickSettingsRoot.colors
            icon: "\uF49E"
            title: "Updates"
            status: quickSettingsRoot.qsUpdateStatus
            active: quickSettingsRoot.qsRepoUpdates + quickSettingsRoot.qsAurUpdates > 0
            onClick: function() { quickSettingsRoot.runInSession("kitty -e paru") }
        }
        QuickSettingCard {
            colors: quickSettingsRoot.colors
            icon: quickSettingsRoot.qsWeatherIcon
            title: "Weather"
            status: quickSettingsRoot.qsWeatherStatus
            onClick: function() { quickSettingsRoot.runInSession("xdg-open https://wttr.in/" + quickSettingsRoot.weatherLocation) }
            onRightClick: function() { quickSettingsRoot.promptWeatherLocation() }
        }
        QuickSettingCard {
            colors: quickSettingsRoot.colors
            icon: "\uF185"
            title: "Theme"
            status: quickSettingsRoot.themeStatus
            paletteColors: [quickSettingsRoot.colors.primary, quickSettingsRoot.colors.secondary, quickSettingsRoot.colors.tertiary, quickSettingsRoot.colors.error, quickSettingsRoot.colors.primaryContainer, quickSettingsRoot.colors.surfaceBright]
            onClick: function() { quickSettingsRoot.runInSession("sh -c '\"$HOME/.config/scripts/select-wallpaper.sh\" --material'") }
        }
        QuickSettingCard {
            colors: quickSettingsRoot.colors
            icon: "\uF02F"
            title: "Printers"
            status: printersStatus
            onClick: function() { quickSettingsRoot.runInSession("system-config-printer") }
        }
    }

    property string themeStatus: "…"
    Process {
        id: themeProc
        command: ["sh", "-c", "F=\"${XDG_CACHE_HOME:-$HOME/.cache}/hypr/current-theme.txt\"; if [ -r \"$F\" ]; then cat \"$F\"; else C=\"${XDG_CONFIG_HOME:-$HOME/.config}/quickshell/Colors.qml\"; if [ -r \"$C\" ]; then grep -E 'Palette:|background:' \"$C\" | head -2 | tr '\\n' ' '; fi; fi"]
        running: false
        stdout: StdioCollector {
            onStreamFinished: {
                var raw = (themeProc.stdout.text || "").trim()
                var style = ""
                var mode = ""
                if (raw.indexOf("|") >= 0) {
                    var parts = raw.split("|")
                    style = parts[0] || ""
                    mode = parts[1] || ""
                } else {
                    var paletteMatch = raw.match(/Palette:\s*(\w+)/)
                    if (paletteMatch) style = paletteMatch[1]
                    var bgMatch = raw.match(/background:\s*"#([0-9a-fA-F]{6})"/)
                    if (bgMatch) {
                        var hex = bgMatch[1]
                        var r = parseInt(hex.slice(0, 2), 16) / 255
                        var g = parseInt(hex.slice(2, 4), 16) / 255
                        var b = parseInt(hex.slice(4, 6), 16) / 255
                        var lum = 0.2126 * r + 0.7152 * g + 0.0722 * b
                        mode = lum < 0.5 ? "dark" : "light"
                    }
                }
                var styleLabel = style ? (style.charAt(0).toUpperCase() + style.slice(1)) : ""
                var modeLabel = mode ? (mode.charAt(0).toUpperCase() + mode.slice(1)) : ""
                if (styleLabel && modeLabel) quickSettingsRoot.themeStatus = styleLabel + " · " + modeLabel
                else if (styleLabel) quickSettingsRoot.themeStatus = styleLabel
                else if (modeLabel) quickSettingsRoot.themeStatus = modeLabel
                else quickSettingsRoot.themeStatus = "—"
                themeProc.running = false
            }
        }
    }
    Timer {
        interval: 2000
        repeat: true
        running: quickSettingsRoot.visible
        onTriggered: themeProc.running = true
    }

    // audioSinkName removed — volume slider above is sufficient
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

    // --- Toggle functions ---
    function toggleMic() {
        toggleMicProc.running = true
    }
    Process {
        id: toggleMicProc
        command: ["wpctl", "set-mute", "@DEFAULT_AUDIO_SOURCE@", "toggle"]
        running: false
        stdout: StdioCollector { onStreamFinished: toggleMicProc.running = false }
    }

    function toggleWifi() {
        toggleWifiProc.running = true
    }
    Process {
        id: toggleWifiProc
        command: ["sh", "-c", "s=$(nmcli radio wifi 2>/dev/null); if [ \"$s\" = \"enabled\" ]; then nmcli radio wifi off; else nmcli radio wifi on; fi"]
        running: false
        stdout: StdioCollector {
            onStreamFinished: {
                toggleWifiProc.running = false
                wifiProc.running = true
                wifiStateProc.running = true
            }
        }
    }

    function toggleBluetooth() {
        toggleBtProc.running = true
    }
    Process {
        id: toggleBtProc
        command: ["sh", "-c", "if bluetoothctl show 2>/dev/null | grep -q 'Powered: yes'; then bluetoothctl power off; else bluetoothctl power on; fi"]
        running: false
        stdout: StdioCollector {
            onStreamFinished: {
                toggleBtProc.running = false
                btProc.running = true
            }
        }
    }

    property string wifiStatus: "N/A"
    property bool wifiEnabled: true
    property string btStatus: "N/A"
    property bool btPowered: false
    Component.onCompleted: {
        backlightDetectProc.running = true
        wifiProc.running = true
        wifiStateProc.running = true
        btProc.running = true
        diskProc.running = true
        vpnProc.running = true
        printersProc.running = true
        themeProc.running = true
        qsWeatherProc.running = true
        qsRepoProc.running = true
        qsAurProc.running = true
        qsPowerGetProc.running = true
        qsIfaceProc.running = true
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
        id: wifiStateProc
        command: ["sh", "-c", "nmcli radio wifi 2>/dev/null"]
        running: false
        stdout: StdioCollector {
            onStreamFinished: {
                quickSettingsRoot.wifiEnabled = (wifiStateProc.stdout.text || "").trim() === "enabled"
                wifiStateProc.running = false
            }
        }
    }
    Process {
        id: btProc
        command: ["sh", "-c", "if ! bluetoothctl show 2>/dev/null | grep -q 'Powered: yes'; then echo 'PWROFF'; exit 0; fi; name=$(bluetoothctl devices 2>/dev/null | awk '{print $2}' | while read m; do bluetoothctl info \"$m\" 2>/dev/null | grep -q 'Connected: yes' && bluetoothctl info \"$m\" 2>/dev/null | grep 'Name:' | sed 's/.*Name: //' | head -1 && break; done); if [ -z \"$name\" ]; then echo -e 'On\\nNo devices'; else echo -e \"On\\n${name}\"; fi"]
        running: false
        stdout: StdioCollector {
            onStreamFinished: {
                var s = (btProc.stdout.text || "").trim()
                if (s === "PWROFF") {
                    quickSettingsRoot.btPowered = false
                    quickSettingsRoot.btStatus = "Off"
                } else {
                    quickSettingsRoot.btPowered = true
                    quickSettingsRoot.btStatus = s || "On"
                }
                btProc.running = false
            }
        }
    }
    property int diskPercent: 0
    Process {
        id: diskProc
        command: ["sh", "-c", "r_line=$(df -h / 2>/dev/null | tail -1); r_pct=$(echo \"$r_line\" | awk '{gsub(/%/,\"\"); print $5}'); r_avail=$(echo \"$r_line\" | awk '{print $4}'); echo \"${r_pct:-0}\"; echo \"Root ${r_pct:-0}%, ${r_avail:-?} free\""]
        running: false
        stdout: StdioCollector {
            onStreamFinished: {
                var lines = (diskProc.stdout.text || "").trim().split("\n")
                if (lines.length >= 1) {
                    var p = parseInt(lines[0], 10)
                    quickSettingsRoot.diskPercent = isNaN(p) ? 0 : Math.max(0, Math.min(100, p))
                }
                quickSettingsRoot.diskStatus = lines.length >= 2 ? lines[1] : "No data"
                diskProc.running = false
            }
        }
    }
    Process {
        id: vpnProc
        command: ["sh", "-c", "n=$(nmcli -t -f name,type con show --active 2>/dev/null | grep -E ':vpn|:wireguard' | head -1 | cut -d: -f1); if [ -n \"$n\" ]; then echo \"Connected: $n\"; else echo \"Disconnected\"; fi"]
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
                quickSettingsRoot.printersStatus = "Printers: " + n + "\nJobs: " + j
                printersProc.running = false
            }
        }
    }
    Timer {
        interval: 30000
        repeat: true
        running: quickSettingsRoot.visible
        onTriggered: {
            wifiProc.running = true
            wifiStateProc.running = true
            btProc.running = true
            diskProc.running = true
            vpnProc.running = true
            printersProc.running = true
        }
    }

    // --- Weather data for QS card ---
    property string qsWeatherStatus: "—"
    property string qsWeatherIcon: "\uF0C2"
    property string weatherLocation: ""
    readonly property string _weatherUrl: weatherLocation ? ("wttr.in/" + weatherLocation) : "wttr.in"

    Process {
        id: loadWeatherLocProc
        command: ["sh", "-c", "cat \"${XDG_CONFIG_HOME:-$HOME/.config}/quickshell/weather-location.txt\" 2>/dev/null || echo ''"]
        running: true
        stdout: StdioCollector {
            onStreamFinished: {
                quickSettingsRoot.weatherLocation = (loadWeatherLocProc.stdout.text || "").trim()
                loadWeatherLocProc.running = false
            }
        }
    }
    Process {
        id: saveWeatherLocProc
        command: []
        running: false
        stdout: StdioCollector { onStreamFinished: saveWeatherLocProc.running = false }
    }

    function promptWeatherLocation() {
        promptWeatherLocProc.running = true
    }
    Process {
        id: promptWeatherLocProc
        command: ["sh", "-c", "LOC=$(rofi -dmenu -p 'Weather location (city or empty for auto)' -l 0 2>/dev/null || true); echo \"$LOC\""]
        running: false
        stdout: StdioCollector {
            onStreamFinished: {
                var loc = (promptWeatherLocProc.stdout.text || "").trim()
                quickSettingsRoot.weatherLocation = loc
                saveWeatherLocProc.command = ["sh", "-c", "echo " + JSON.stringify(loc) + " > \"${XDG_CONFIG_HOME:-$HOME/.config}/quickshell/weather-location.txt\""]
                saveWeatherLocProc.running = true
                qsWeatherProc.running = true
                promptWeatherLocProc.running = false
            }
        }
    }

    Process {
        id: qsWeatherProc
        command: ["sh", "-c", "curl -s '" + quickSettingsRoot._weatherUrl + "?format=%C|%t|%l' 2>/dev/null"]
        running: false
        stdout: StdioCollector {
            onStreamFinished: {
                var s = (qsWeatherProc.stdout.text || "").trim()
                if (s && s.indexOf("|") >= 0) {
                    var parts = s.split("|")
                    var cond = (parts[0] || "").trim()
                    var temp = (parts[1] || "").trim().replace(/^\+/, "")
                    var loc = (parts[2] || "").trim()
                    quickSettingsRoot.qsWeatherStatus = temp + ", " + cond + "\n" + loc
                    var c = cond.toLowerCase()
                    if (c.indexOf("sun") >= 0 || c.indexOf("clear") >= 0) quickSettingsRoot.qsWeatherIcon = "\uF185"
                    else if (c.indexOf("rain") >= 0 || c.indexOf("drizzle") >= 0) quickSettingsRoot.qsWeatherIcon = "\uF73D"
                    else if (c.indexOf("snow") >= 0 || c.indexOf("sleet") >= 0) quickSettingsRoot.qsWeatherIcon = "\uF2DC"
                    else if (c.indexOf("thunder") >= 0 || c.indexOf("storm") >= 0) quickSettingsRoot.qsWeatherIcon = "\uF0E7"
                    else if (c.indexOf("cloud") >= 0 || c.indexOf("overcast") >= 0) quickSettingsRoot.qsWeatherIcon = "\uF0C2"
                    else if (c.indexOf("fog") >= 0 || c.indexOf("mist") >= 0) quickSettingsRoot.qsWeatherIcon = "\uF75F"
                    else quickSettingsRoot.qsWeatherIcon = "\uF6C4"
                } else {
                    quickSettingsRoot.qsWeatherStatus = "Unavailable"
                }
                qsWeatherProc.running = false
            }
        }
    }
    Timer {
        interval: 900000
        repeat: true
        running: quickSettingsRoot.visible
        onTriggered: if (!qsWeatherProc.running) qsWeatherProc.running = true
    }

    // --- Update data for QS card ---
    property int qsRepoUpdates: 0
    property int qsAurUpdates: 0
    property string qsUpdateStatus: "—"
    Process {
        id: qsRepoProc
        command: ["sh", "-c", "checkupdates 2>/dev/null | wc -l"]
        running: false
        stdout: StdioCollector {
            onStreamFinished: {
                var n = parseInt((qsRepoProc.stdout.text || "").trim(), 10)
                quickSettingsRoot.qsRepoUpdates = isNaN(n) ? 0 : Math.max(0, n)
                quickSettingsRoot.qsUpdateStatus = quickSettingsRoot.qsRepoUpdates + " repo + " + quickSettingsRoot.qsAurUpdates + " AUR"
                qsRepoProc.running = false
            }
        }
    }
    Process {
        id: qsAurProc
        command: ["sh", "-c", "paru -Qua 2>/dev/null | wc -l"]
        running: false
        stdout: StdioCollector {
            onStreamFinished: {
                var n = parseInt((qsAurProc.stdout.text || "").trim(), 10)
                quickSettingsRoot.qsAurUpdates = isNaN(n) ? 0 : Math.max(0, n)
                quickSettingsRoot.qsUpdateStatus = quickSettingsRoot.qsRepoUpdates + " repo + " + quickSettingsRoot.qsAurUpdates + " AUR"
                qsAurProc.running = false
            }
        }
    }
    Timer {
        interval: 1800000
        repeat: true
        running: quickSettingsRoot.visible
        onTriggered: {
            if (!qsRepoProc.running) qsRepoProc.running = true
            if (!qsAurProc.running) qsAurProc.running = true
        }
    }

    // --- Power profile data for QS card ---
    property string qsPowerProfile: "—"
    property string qsPowerIcon: "\uF24E"
    readonly property var _powerIcons: ({ "balanced": "\uF24E", "performance": "\uF0E4", "power-saver": "\uF06C" })
    Process {
        id: qsPowerGetProc
        command: ["powerprofilesctl", "get"]
        running: false
        stdout: StdioCollector {
            onStreamFinished: {
                var s = (qsPowerGetProc.stdout.text || "").trim()
                if (s) {
                    quickSettingsRoot.qsPowerProfile = s.charAt(0).toUpperCase() + s.slice(1)
                    quickSettingsRoot.qsPowerIcon = quickSettingsRoot._powerIcons[s] || "\uF24E"
                }
                qsPowerGetProc.running = false
            }
        }
    }
    Process {
        id: qsPowerSetProc
        command: []
        running: false
        stdout: StdioCollector {
            onStreamFinished: {
                qsPowerSetProc.running = false
                qsPowerGetProc.running = true
            }
        }
    }
    function cyclePowerProfile() {
        var order = ["balanced", "performance", "power-saver"]
        var cur = qsPowerProfile.toLowerCase()
        var idx = order.indexOf(cur)
        var next = order[(idx + 1) % order.length]
        qsPowerSetProc.command = ["powerprofilesctl", "set", next]
        qsPowerSetProc.running = true
    }
    Timer {
        interval: 10000
        repeat: true
        running: quickSettingsRoot.visible
        onTriggered: if (!qsPowerGetProc.running) qsPowerGetProc.running = true
    }

    // --- Network speed data for QS card ---
    property string qsNetIface: ""
    property real qsRxRate: 0
    property real qsTxRate: 0
    property real _qsLastRx: 0
    property real _qsLastTx: 0
    property bool _qsNetHasData: false
    property string qsNetSpeed: "—"
    function _formatSpeed(bps) {
        if (bps < 1024) return Math.round(bps) + " B/s"
        if (bps < 1024 * 1024) return Math.round(bps / 1024) + " KB/s"
        return (bps / (1024 * 1024)).toFixed(1) + " MB/s"
    }
    Process {
        id: qsIfaceProc
        command: ["sh", "-c", "ip -o link show up 2>/dev/null | awk -F': ' '{print $2}' | grep -vE '^(lo|docker|br-|veth)' | head -1"]
        running: false
        stdout: StdioCollector {
            onStreamFinished: {
                var s = (qsIfaceProc.stdout.text || "").trim()
                if (s) quickSettingsRoot.qsNetIface = s
                qsIfaceProc.running = false
            }
        }
    }
    Process {
        id: qsNetStatsProc
        command: ["sh", "-c", "cat /sys/class/net/" + qsNetIface + "/statistics/rx_bytes /sys/class/net/" + qsNetIface + "/statistics/tx_bytes 2>/dev/null"]
        running: false
        stdout: StdioCollector {
            onStreamFinished: {
                var lines = (qsNetStatsProc.stdout.text || "").trim().split("\n")
                if (lines.length >= 2) {
                    var rx = parseFloat(lines[0]) || 0
                    var tx = parseFloat(lines[1]) || 0
                    if (quickSettingsRoot._qsNetHasData) {
                        quickSettingsRoot.qsRxRate = Math.max(0, (rx - quickSettingsRoot._qsLastRx) / 2)
                        quickSettingsRoot.qsTxRate = Math.max(0, (tx - quickSettingsRoot._qsLastTx) / 2)
                        quickSettingsRoot.qsNetSpeed = "\u2193 " + quickSettingsRoot._formatSpeed(quickSettingsRoot.qsRxRate) + "  \u2191 " + quickSettingsRoot._formatSpeed(quickSettingsRoot.qsTxRate)
                    }
                    quickSettingsRoot._qsLastRx = rx
                    quickSettingsRoot._qsLastTx = tx
                    quickSettingsRoot._qsNetHasData = true
                }
                qsNetStatsProc.running = false
            }
        }
    }
    onQsNetIfaceChanged: if (qsNetIface) qsNetStatsProc.running = true
    Timer {
        interval: 2000
        repeat: true
        running: quickSettingsRoot.visible && quickSettingsRoot.qsNetIface !== ""
        onTriggered: if (!qsNetStatsProc.running) qsNetStatsProc.running = true
    }

    // Initialize new QS data on panel open
    onVisibleChanged: {
        if (visible) {
            qsWeatherProc.running = true
            qsRepoProc.running = true
            qsAurProc.running = true
            qsPowerGetProc.running = true
            if (!qsNetIface) qsIfaceProc.running = true
        }
    }

    Item { Layout.fillHeight: true }
}
