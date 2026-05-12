import QtQuick
import QtQuick.Layouts
import Quickshell.Io
import Quickshell.Services.Pipewire

import "."

GridLayout {
    id: grid
    required property var colors
    property string audioSettingsCommand: "pavucontrol"
    property string batterySettingsCommand: ""
    property string diskSettingsCommand: "sh -c \"thunar \\$HOME\""

    signal runCommand(string cmd)

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
        onClick: function() { SystemServices.toggleWifi() }
        onRightClick: function() { grid.runCommand("nm-connection-editor") }
    }
    QuickSettingCard {
        colors: grid.colors
        icon: "\uF293"
        title: "Bluetooth"
        status: SystemServices.btStatus
        active: SystemServices.btPowered
        onClick: function() { SystemServices.toggleBluetooth() }
        onRightClick: function() { grid.runCommand("sh -c 'blueman-manager 2>/dev/null || bluetoothctl'") }
    }
    QuickSettingCard {
        colors: grid.colors
        enabled: SystemServices.batteryHas || !!grid.batterySettingsCommand
        icon: SystemServices.batteryHas ? (SystemServices.batteryStatus === "Charging" ? "\uF0E7" : "\uF240") : "\uF244"
        title: "Battery"
        status: SystemServices.batteryHas ? (SystemServices.batteryCapacity + "% " + SystemServices.batteryStatus) : "N/A"
        active: SystemServices.batteryHas && SystemServices.batteryStatus === "Charging"
        progress: SystemServices.batteryHas ? SystemServices.batteryCapacity / 100 : -1
        onClick: grid.batterySettingsCommand ? function() { grid.runCommand(grid.batterySettingsCommand) } : null
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
        icon: "\uF0AC"
        title: "Network"
        status: SystemServices.netSpeed
        onClick: function() { grid.runCommand("nm-connection-editor") }
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
        icon: "\uF49E"
        title: "Updates"
        status: SystemServices.updateStatus
        active: SystemServices.repoUpdates + SystemServices.aurUpdates > 0
        onClick: function() { grid.runCommand("kitty -e paru") }
    }
    QuickSettingCard {
        colors: grid.colors
        icon: SystemServices.weatherIcon
        title: "Weather"
        status: SystemServices.weatherStatus
        onClick: function() { grid.runCommand("xdg-open https://wttr.in/" + SystemServices.weatherLocation) }
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
