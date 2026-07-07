import QtQuick
import QtQuick.Layouts
import Quickshell.Io
import Quickshell.Services.Pipewire

import "."

GridLayout {
    id: grid
    required property var colors
    property string audioSettingsCommand: "pavucontrol"
    property string diskSettingsCommand: "sh -c \"thunar \\$HOME\""

    signal runCommand(string cmd)
    signal openWifiRequested()
    signal openBluetoothRequested()

    Layout.fillWidth: true
    Layout.bottomMargin: 16
    columns: 2
    rowSpacing: 8
    columnSpacing: 8

    // ===== MIC (Pipewire native) =====
    property bool micMuted: false
    property var defaultSource: Pipewire.defaultAudioSource
    PwObjectTracker { objects: defaultSource ? [defaultSource] : [] }
    Binding {
        target: grid
        property: "micMuted"
        value: grid.defaultSource && grid.defaultSource.audio ? grid.defaultSource.audio.muted : false
        when: grid.defaultSource != null
    }
    function toggleMic() { toggleMicProc.running = true }
    Process {
        id: toggleMicProc
        command: ["wpctl", "set-mute", "@DEFAULT_AUDIO_SOURCE@", "toggle"]
        running: false
        stdout: StdioCollector { onStreamFinished: toggleMicProc.running = false }
    }

    // ===== AUDIO OUTPUT (native Pipewire — cycle default sink) =====
    readonly property var audioSinks: {
        var out = []
        var ns = Pipewire.nodes.values
        for (var i = 0; i < ns.length; i++) {
            var n = ns[i]
            if (n.isSink && !n.isStream && (n.type & PwNodeType.Audio)) out.push(n)
        }
        return out
    }
    PwObjectTracker { objects: grid.audioSinks }
    function cycleSink() {
        var sinks = grid.audioSinks
        if (sinks.length < 2) return
        var cur = Pipewire.defaultAudioSink
        var idx = -1
        for (var i = 0; i < sinks.length; i++) {
            if (cur && sinks[i].id === cur.id) { idx = i; break }
        }
        Pipewire.preferredDefaultAudioSink = sinks[(idx + 1) % sinks.length]
    }
    readonly property string currentSinkName: {
        var s = Pipewire.defaultAudioSink
        if (!s) return "None"
        return s.nickname || s.description || s.name || "Unknown"
    }

    // ===== WEATHER LOCATION PROMPT (rofi UI) =====
    function promptWeatherLocation() { promptWeatherLocProc.running = true }
    Process {
        id: promptWeatherLocProc
        command: ["sh", "-c", "LOC=$(rofi -dmenu -p 'Weather location (city or empty for auto)' -l 0 2>/dev/null || true); echo \"$LOC\""]
        running: false
        stdout: StdioCollector {
            onStreamFinished: {
                var loc = (promptWeatherLocProc.stdout.text || "").trim()
                SystemServices.setWeatherLocation(loc)
                promptWeatherLocProc.running = false
            }
        }
    }

    QuickSettingCard {
        colors: grid.colors
        icon: grid.micMuted ? "\uF131" : "\uF130"
        title: "Microphone"
        status: grid.micMuted ? "Muted" : "On"
        active: !grid.micMuted
        onClick: function() { grid.toggleMic() }
        onRightClick: function() { grid.runCommand(grid.audioSettingsCommand) }
    }
    QuickSettingCard {
        colors: grid.colors
        icon: SystemServices.wifiEnabled ? "\uF1EB" : "\uF05E"
        title: "Wi-Fi"
        status: SystemServices.wifiEnabled
            ? (SystemServices.wifiStatus + (SystemServices.vpnStatus !== "Disconnected" ? ("\n " + SystemServices.vpnStatus) : ""))
            : "Off"
        active: SystemServices.wifiEnabled
        onClick: function() { grid.openWifiRequested() }
        onRightClick: function() { grid.runCommand("nm-connection-editor") }
    }
    QuickSettingCard {
        colors: grid.colors
        icon: "\uF293"
        title: "Bluetooth"
        status: SystemServices.btStatus
        active: SystemServices.btPowered
        onClick: function() { grid.openBluetoothRequested() }
        onRightClick: function() { grid.runCommand("sh -c 'blueman-manager 2>/dev/null || bluetoothctl'") }
    }
    QuickSettingCard {
        colors: grid.colors
        icon: SystemServices.powerIcon
        title: "Power Profile"
        status: SystemServices.powerProfile
        active: SystemServices.powerProfile.toLowerCase() === "performance"
        onClick: function() { SystemServices.cyclePowerProfile() }
    }
    QuickSettingCard {
        colors: grid.colors
        icon: "\uF025"
        title: "Output"
        status: grid.currentSinkName + (grid.audioSinks.length > 1 ? "\nClick to switch" : "")
        active: true
        onClick: function() { grid.cycleSink() }
        onRightClick: function() { grid.runCommand(grid.audioSettingsCommand) }
    }
    QuickSettingCard {
        colors: grid.colors
        enabled: !!grid.diskSettingsCommand
        icon: "\uF0A0"
        title: "Disk"
        status: SystemServices.diskStatus
        progress: SystemServices.diskPercent / 100
        onClick: grid.diskSettingsCommand ? function() { grid.runCommand(grid.diskSettingsCommand) } : null
    }
    QuickSettingCard {
        colors: grid.colors
        icon: SystemServices.weatherIcon
        title: "Weather"
        status: SystemServices.weatherStatus
        onClick: function() { grid.runCommand("xdg-open https://wttr.in/" + encodeURIComponent(SystemServices.weatherLocation)) }
        onRightClick: function() { grid.promptWeatherLocation() }
    }
    QuickSettingCard {
        colors: grid.colors
        icon: "\uF185"
        title: "Theme"
        status: SystemServices.themeStatus
        paletteColors: [grid.colors.primary, grid.colors.secondary, grid.colors.tertiary, grid.colors.error, grid.colors.primaryContainer, grid.colors.surfaceBright]
        onClick: function() { grid.runCommand("sh -c '\"$HOME/.config/scripts/select-wallpaper.sh\" --material'") }
    }
    QuickSettingCard {
        colors: grid.colors
        icon: "\uF02F"
        title: "Printers"
        status: SystemServices.printersStatus
        onClick: function() { grid.runCommand("system-config-printer") }
    }
}
