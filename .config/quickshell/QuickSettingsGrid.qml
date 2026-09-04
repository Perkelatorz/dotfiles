import QtQuick
import QtQuick.Layouts
import Quickshell.Io
import Quickshell.Services.Pipewire

import "."

// Connectivity, appearance and session — the things that have no other home.
//
// Microphone and Output moved to the volume panel, Power Profile to the battery
// panel, Disk and Printers to the system cluster. Each of those panels owns the
// full control now, so a second half-version of it here was a card you had to
// learn twice and a status string that could disagree with itself.
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

    // The mic toggle, the sink cycler and their Pipewire trackers lived here to
    // feed the Microphone and Output cards. Both cards moved to the volume
    // panel, which does the whole job — device lists, per-app streams — rather
    // than a toggle and a cycle-to-next.

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
}
