pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Bluetooth
import Quickshell.Services.UPower

// Single source of truth for system state polled via shell.
// Bar widgets and QuickSettings panel both bind to these properties.
// Replaces duplicated Process+Timer triples spread across widgets.
Singleton {
    id: root

    // ===== consumer-gate flags (set by bars/panel; widgets bind their visibility here) =====
    property bool qsOpen: false
    // Fresh brightness the moment quick settings opens (poll below is slow).
    onQsOpenChanged: if (qsOpen && _brightnessHas) _refreshBrightness()

    // ===== BATTERY (UPower — event-driven, replaces the 60s sysfs pipeline) =====
    // Property names/strings preserved for BatteryWidget/QuickSettingsGrid.
    readonly property var _bat: UPower.displayDevice
    readonly property bool batteryHas: _bat !== null && _bat.isLaptopBattery
    readonly property int batteryCapacity: batteryHas ? Math.round(_bat.percentage * 100) : 0
    readonly property string batteryStatus: {
        if (!batteryHas) return ""
        switch (_bat.state) {
        case UPowerDeviceState.Charging:
        case UPowerDeviceState.PendingCharge:
            return "Charging"
        case UPowerDeviceState.FullyCharged:
            return "Full"
        case UPowerDeviceState.Discharging:
        case UPowerDeviceState.PendingDischarge:
            return "Discharging"
        default:
            return "Unknown"
        }
    }
    readonly property int batteryTimeMinutes: {
        if (!batteryHas) return 0
        var secs = batteryStatus === "Charging" ? _bat.timeToFull : _bat.timeToEmpty
        return secs > 0 ? Math.round(secs / 60) : 0
    }
    readonly property string batteryTimeText: {
        if (!batteryHas || batteryTimeMinutes <= 0) return ""
        var h = Math.floor(batteryTimeMinutes / 60)
        var m = batteryTimeMinutes % 60
        if (h > 0) return h + "h " + m + "m"
        return m + "m"
    }

    // ===== BRIGHTNESS =====
    readonly property bool brightnessHas: _brightnessHas
    readonly property int brightnessLevel: _brightnessLevel
    property bool _brightnessHas: false
    property int _brightnessLevel: 0
    property string _backlightPath: ""
    property var _brightnessctlDevices: []
    property int brightnessScreenIndex: 0

    function setBrightness(percent) {
        var p = Math.max(0, Math.min(100, percent))
        if (_backlightPath) {
            // brightnessctl goes through logind — a raw sysfs echo needs root
            // and fails silently as a regular user.
            _setBrightProc.command = ["brightnessctl", "set", p + "%"]
            _setBrightProc.running = true
        } else if (_brightnessctlDevices.length > 0) {
            var dev = _brightnessctlDevices[Math.min(brightnessScreenIndex, _brightnessctlDevices.length - 1)]
            _setBrightProc.command = dev ? ["brightnessctl", "-d", dev, "set", p + "%"] : ["brightnessctl", "set", p + "%"]
            _setBrightProc.running = true
        }
    }
    function _refreshBrightness() {
        if (_backlightPath) {
            _readBrightProc.command = ["sh", "-c", "b=$(cat \"" + _backlightPath + "/brightness\" 2>/dev/null); m=$(cat \"" + _backlightPath + "/max_brightness\" 2>/dev/null); [ -n \"$m\" ] && [ \"$m\" -gt 0 ] && echo $((b*100/m)) || echo 0"]
            _readBrightProc.running = true
        } else if (_brightnessctlDevices.length > 0) {
            var dev = _brightnessctlDevices[Math.min(brightnessScreenIndex, _brightnessctlDevices.length - 1)]
            _readBrightProc.command = dev ? ["brightnessctl", "-d", dev, "-m"] : ["brightnessctl", "-m"]
            _readBrightProc.running = true
        }
    }

    Process {
        id: _backlightDetectProc
        command: ["sh", "-c", "d=$(ls -d /sys/class/backlight/* 2>/dev/null | head -1); if [ -n \"$d\" ] && [ -r \"$d/brightness\" ] && [ -r \"$d/max_brightness\" ]; then echo \"$d\"; else echo \"\"; fi"]
        running: false
        stdout: StdioCollector {
            onStreamFinished: {
                var p = (_backlightDetectProc.stdout.text || "").trim()
                root._backlightPath = p
                if (p) {
                    root._brightnessHas = true
                    root._refreshBrightness()
                } else {
                    _brightnessctlListProc.running = true
                }
                _backlightDetectProc.running = false
            }
        }
    }
    Process {
        id: _brightnessctlListProc
        command: ["sh", "-c", "brightnessctl -l 2>/dev/null"]
        running: false
        stdout: StdioCollector {
            onStreamFinished: {
                var out = (_brightnessctlListProc.stdout.text || "").trim()
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
                root._brightnessctlDevices = devices
                root._brightnessHas = devices.length > 0
                if (root._brightnessHas) root._refreshBrightness()
                _brightnessctlListProc.running = false
            }
        }
    }
    Process {
        id: _readBrightProc
        command: []
        running: false
        stdout: StdioCollector {
            onStreamFinished: {
                var line = (_readBrightProc.stdout.text || "").trim()
                var m = line.match(/(\d+)%?\s*$/)
                if (m) root._brightnessLevel = Math.max(0, Math.min(100, parseInt(m[1], 10)))
                else {
                    var v = parseInt(line, 10)
                    if (!isNaN(v)) root._brightnessLevel = Math.max(0, Math.min(100, v))
                }
                _readBrightProc.running = false
            }
        }
    }
    Process {
        id: _setBrightProc
        command: []
        running: false
        onRunningChanged: if (!running && root._brightnessHas) root._refreshBrightness()
    }
    // Slow background poll (catches hardware-key changes made outside the
    // shell); refresh-after-set and the qsOpen hook cover the fast paths.
    Timer {
        interval: 10000
        repeat: true
        running: root._brightnessHas
        onTriggered: root._refreshBrightness()
    }

    // ===== WIFI =====
    readonly property string wifiStatus: _wifiStatus
    readonly property bool wifiEnabled: _wifiEnabled
    property string _wifiStatus: "N/A"
    property bool _wifiEnabled: true
    function toggleWifi() { _toggleWifiProc.running = true }
    Process {
        id: _toggleWifiProc
        command: ["sh", "-c", "s=$(nmcli radio wifi 2>/dev/null); if [ \"$s\" = \"enabled\" ]; then nmcli radio wifi off; else nmcli radio wifi on; fi"]
        running: false
        stdout: StdioCollector {
            onStreamFinished: {
                _toggleWifiProc.running = false
                _wifiProc.refresh()
                _wifiStateProc.refresh()
            }
        }
    }
    PollingProcess {
        id: _wifiProc
        interval: 30000
        command: ["sh", "-c", "nmcli -t -f active,ssid,signal dev wifi 2>/dev/null | grep '^yes' | head -1 | cut -d: -f2-"]
        onOutput: text => {
            var s = text.trim()
            if (!s) {
                root._wifiStatus = "Disconnected"
                return
            }
            // Split on the LAST colon: nmcli -t escapes colons in SSIDs as \:
            // and the trailing field (signal) is always numeric.
            var i = s.lastIndexOf(":")
            if (i > 0) {
                var ssid = s.slice(0, i).replace(/\\:/g, ":")
                root._wifiStatus = ssid + " " + s.slice(i + 1) + "%"
            } else {
                root._wifiStatus = s
            }
        }
    }
    PollingProcess {
        id: _wifiStateProc
        interval: 30000
        command: ["sh", "-c", "nmcli radio wifi 2>/dev/null"]
        onOutput: text => { root._wifiEnabled = text.trim() === "enabled" }
    }

    // ===== BLUETOOTH (native service — replaces the bluetoothctl loop that
    // spawned one process per paired device every 30s) =====
    readonly property var _btAdapter: Bluetooth.defaultAdapter
    readonly property bool btPowered: _btAdapter !== null && _btAdapter.enabled
    readonly property string btStatus: {
        if (_btAdapter === null) return "N/A"
        if (!_btAdapter.enabled) return "Off"
        var devs = Bluetooth.devices.values
        for (var i = 0; i < devs.length; i++) {
            if (devs[i].connected) return "On\n" + devs[i].name
        }
        return "On\nNo devices"
    }
    function toggleBluetooth() {
        if (_btAdapter !== null) _btAdapter.enabled = !_btAdapter.enabled
    }

    // ===== DISK =====
    readonly property int diskPercent: _diskPercent
    readonly property string diskStatus: _diskStatus
    property int _diskPercent: 0
    property string _diskStatus: "No data"
    PollingProcess {
        interval: 30000
        command: ["sh", "-c", "r_line=$(df -h / 2>/dev/null | tail -1); r_pct=$(echo \"$r_line\" | awk '{gsub(/%/,\"\"); print $5}'); r_avail=$(echo \"$r_line\" | awk '{print $4}'); echo \"${r_pct:-0}\"; echo \"Root ${r_pct:-0}%, ${r_avail:-?} free\""]
        onOutput: text => {
            var lines = text.trim().split("\n")
            if (lines.length >= 1) {
                var p = parseInt(lines[0], 10)
                root._diskPercent = isNaN(p) ? 0 : Math.max(0, Math.min(100, p))
            }
            root._diskStatus = lines.length >= 2 ? lines[1] : "No data"
        }
    }

    // ===== VPN =====
    readonly property string vpnStatus: _vpnStatus
    property string _vpnStatus: "Disconnected"
    PollingProcess {
        interval: 30000
        command: ["sh", "-c", "n=$(nmcli -t -f name,type con show --active 2>/dev/null | grep -E ':vpn|:wireguard' | head -1 | cut -d: -f1); if [ -n \"$n\" ]; then echo \"Connected: $n\"; else echo \"Disconnected\"; fi"]
        onOutput: text => { root._vpnStatus = text.trim() || "Disconnected" }
    }

    // ===== PRINTERS =====
    readonly property string printersStatus: _printersStatus
    property string _printersStatus: "No data"
    PollingProcess {
        interval: 30000
        command: ["sh", "-c", "n=$(lpstat -p 2>/dev/null | grep -c '^printer' || true); j=$(lpstat -o 2>/dev/null | wc -l); echo \"$n $j\""]
        onOutput: text => {
            var parts = text.trim().split(/\s+/)
            var n = parseInt(parts[0], 10) || 0
            var j = parseInt(parts[1], 10) || 0
            root._printersStatus = "Printers: " + n + "\nJobs: " + j
        }
    }

    // ===== THEME (FileView watch — replaces a cat every 2 seconds) =====
    readonly property string themeStatus: _themeStatus
    property string _themeStatus: "…"
    property string _themeRaw: ""
    property string _colorsRaw: ""
    FileView {
        path: (Quickshell.env("XDG_CACHE_HOME") || Quickshell.env("HOME") + "/.cache") + "/hypr/current-theme.txt"
        watchChanges: true
        onFileChanged: reload()
        onLoaded: { root._themeRaw = text(); root._recomputeTheme() }
        onLoadFailed: { root._themeRaw = ""; root._recomputeTheme() }
    }
    FileView {
        path: (Quickshell.env("XDG_CONFIG_HOME") || Quickshell.env("HOME") + "/.config") + "/quickshell/Colors.qml"
        watchChanges: true
        onFileChanged: reload()
        onLoaded: { root._colorsRaw = text(); root._recomputeTheme() }
        onLoadFailed: { root._colorsRaw = ""; root._recomputeTheme() }
    }
    function _recomputeTheme() {
        var raw = root._themeRaw.trim()
        if (!raw) {
            // Fallback: derive from Colors.qml (same info, different format).
            var lines = root._colorsRaw.split("\n").filter(function(l) {
                return l.indexOf("Palette:") >= 0 || l.indexOf("background:") >= 0
            })
            raw = lines.slice(0, 2).join(" ")
        }
        {
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
            if (styleLabel && modeLabel) root._themeStatus = styleLabel + " · " + modeLabel
            else if (styleLabel) root._themeStatus = styleLabel
            else if (modeLabel) root._themeStatus = modeLabel
            else root._themeStatus = "—"
        }
    }

    // ===== WEATHER =====
    readonly property string weatherLocation: _weatherLocation
    readonly property string weatherStatus: _weatherStatus
    readonly property string weatherIcon: _weatherIcon
    readonly property string weatherCondition: _weatherCondition
    readonly property string weatherTemp: _weatherTemp
    readonly property string weatherLocationName: _weatherLocationName
    readonly property bool weatherHasData: _weatherHasData
    readonly property string weatherFeelsLike: _weatherFeelsLike
    readonly property string weatherHumidity: _weatherHumidity
    readonly property string weatherWind: _weatherWind
    readonly property var weatherForecast: _weatherForecast
    property string _weatherLocation: ""
    property string _weatherStatus: "—"
    property string _weatherIcon: ""
    property string _weatherCondition: ""
    property string _weatherTemp: ""
    property string _weatherLocationName: ""
    property bool _weatherHasData: false
    property string _weatherFeelsLike: ""
    property string _weatherHumidity: ""
    property string _weatherWind: ""
    property var _weatherForecast: []
    readonly property string _weatherUrl: _weatherLocation ? ("wttr.in/" + encodeURIComponent(_weatherLocation)) : "wttr.in"

    function _weatherIconForCondition(cond) {
        if (!cond) return "\uF0C2"
        var c = cond.toLowerCase()
        if (c.indexOf("sun") >= 0 || c.indexOf("clear") >= 0) return "\uF185"
        if (c.indexOf("thunder") >= 0 || c.indexOf("storm") >= 0) return "\uF0E7"
        if (c.indexOf("snow") >= 0 || c.indexOf("sleet") >= 0 || c.indexOf("blizzard") >= 0) return "\uF2DC"
        if (c.indexOf("rain") >= 0 || c.indexOf("drizzle") >= 0 || c.indexOf("shower") >= 0) return "\uF73D"
        if (c.indexOf("fog") >= 0 || c.indexOf("mist") >= 0 || c.indexOf("haze") >= 0) return "\uF75F"
        if (c.indexOf("cloud") >= 0 || c.indexOf("overcast") >= 0) return "\uF0C2"
        return "\uF0C2"
    }

    function setWeatherLocation(loc) {
        root._weatherLocation = loc
        // $1 is passed as a positional arg — never interpolated into the script,
        // so quotes/$()/backticks in the location can't execute.
        _saveWeatherLocProc.command = ["sh", "-c", "printf '%s\\n' \"$1\" > \"${XDG_CONFIG_HOME:-$HOME/.config}/quickshell/weather-location.txt\"", "_", loc]
        _saveWeatherLocProc.running = true
        _weatherProc.refresh()
    }

    Process {
        id: _loadWeatherLocProc
        command: ["sh", "-c", "cat \"${XDG_CONFIG_HOME:-$HOME/.config}/quickshell/weather-location.txt\" 2>/dev/null || echo ''"]
        running: true
        stdout: StdioCollector {
            onStreamFinished: {
                root._weatherLocation = (_loadWeatherLocProc.stdout.text || "").trim()
                _loadWeatherLocProc.running = false
                _weatherProc.refresh()
            }
        }
    }
    Process {
        id: _saveWeatherLocProc
        command: []
        running: false
        stdout: StdioCollector { onStreamFinished: _saveWeatherLocProc.running = false }
    }
    PollingProcess {
        id: _weatherProc
        interval: 900000
        runOnStart: false
        // argv form: URL is a single argument, no shell parsing (encodeURIComponent
        // in _weatherUrl handles spaces/quotes); --max-time so a hung curl can't
        // block the next poll forever.
        command: ["curl", "-s", "--max-time", "15", root._weatherUrl + "?format=j1"]
        onOutput: text => {
            var s = text.trim()
            if (!s || s.charAt(0) !== "{") {
                root._weatherHasData = false
                root._weatherStatus = "Unavailable"
                return
            }
            try {
                var j = JSON.parse(s)
                var cur = (j.current_condition && j.current_condition[0]) || {}
                var area = (j.nearest_area && j.nearest_area[0]) || {}
                var cond = (cur.weatherDesc && cur.weatherDesc[0] && cur.weatherDesc[0].value) || ""
                var temp = cur.temp_F || ""
                var feels = cur.FeelsLikeF || ""
                var hum = cur.humidity || ""
                var wind = cur.windspeedMiles || ""
                var locName = (area.areaName && area.areaName[0] && area.areaName[0].value) || ""
                var region = (area.region && area.region[0] && area.region[0].value) || ""
                var loc = region ? (locName + ", " + region) : locName
                root._weatherCondition = cond
                root._weatherTemp = temp + "°F"
                root._weatherFeelsLike = feels ? (feels + "°F") : ""
                root._weatherHumidity = hum ? (hum + "%") : ""
                root._weatherWind = wind ? (wind + " mph") : ""
                root._weatherLocationName = loc
                root._weatherHasData = true
                root._weatherStatus = root._weatherTemp + ", " + cond + "\n" + loc
                root._weatherIcon = root._weatherIconForCondition(cond)
                var fc = []
                var days = j.weather || []
                for (var i = 0; i < Math.min(3, days.length); i++) {
                    var d = days[i]
                    var midHour = null
                    var hourly = d.hourly || []
                    for (var hi = 0; hi < hourly.length; hi++) {
                        if (String(hourly[hi].time) === "1200" || String(hourly[hi].time) === "1300") { midHour = hourly[hi]; break }
                    }
                    if (!midHour && hourly.length > 0) midHour = hourly[Math.floor(hourly.length / 2)]
                    var hCond = (midHour && midHour.weatherDesc && midHour.weatherDesc[0] && midHour.weatherDesc[0].value) || ""
                    fc.push({
                        date: d.date || "",
                        high: d.maxtempF || "",
                        low: d.mintempF || "",
                        condition: hCond,
                        icon: root._weatherIconForCondition(hCond)
                    })
                }
                root._weatherForecast = fc
            } catch (e) {
                root._weatherHasData = false
                root._weatherStatus = "Parse error"
            }
        }
    }

    // ===== UPDATES =====
    readonly property int repoUpdates: _repoUpdates
    readonly property int aurUpdates: _aurUpdates
    readonly property string updateStatus: _repoUpdates + " repo + " + _aurUpdates + " AUR"
    property int _repoUpdates: 0
    property int _aurUpdates: 0
    PollingProcess {
        interval: 1800000
        command: ["sh", "-c", "checkupdates 2>/dev/null | wc -l"]
        onOutput: text => {
            var n = parseInt(text.trim(), 10)
            root._repoUpdates = isNaN(n) ? 0 : Math.max(0, n)
        }
    }
    PollingProcess {
        interval: 1800000
        command: ["sh", "-c", "paru -Qua 2>/dev/null | wc -l"]
        onOutput: text => {
            var n = parseInt(text.trim(), 10)
            root._aurUpdates = isNaN(n) ? 0 : Math.max(0, n)
        }
    }

    // ===== POWER PROFILE (native PowerProfiles — event-driven, replaces two
    // independent 10s powerprofilesctl pollers that could disagree) =====
    // One-shot daemon check so machines without power-profiles-daemon show "—"
    // (the dbus proxy would otherwise report a default "Balanced").
    property bool _powerHas: false
    readonly property string powerProfile: {
        if (!_powerHas) return "\u2014"
        switch (PowerProfiles.profile) {
        case PowerProfile.Performance: return "Performance"
        case PowerProfile.PowerSaver: return "Power-saver"
        default: return "Balanced"
        }
    }
    readonly property string powerIcon: {
        if (!_powerHas) return ""
        switch (PowerProfiles.profile) {
        case PowerProfile.Performance: return "\uF0E7"
        case PowerProfile.PowerSaver: return "\uF06C"
        default: return "\uF24E"
        }
    }
    function cyclePowerProfile() {
        if (!_powerHas) return
        switch (PowerProfiles.profile) {
        case PowerProfile.Balanced: PowerProfiles.profile = PowerProfile.Performance; break
        case PowerProfile.Performance: PowerProfiles.profile = PowerProfile.PowerSaver; break
        default: PowerProfiles.profile = PowerProfile.Balanced; break
        }
    }
    Process {
        id: _powerDetectProc
        command: ["sh", "-c", "command -v powerprofilesctl >/dev/null && echo yes || echo no"]
        running: true
        stdout: StdioCollector {
            onStreamFinished: {
                root._powerHas = (_powerDetectProc.stdout.text || "").trim() === "yes"
                _powerDetectProc.running = false
            }
        }
    }

    // ===== NET SPEED =====
    readonly property string netIface: _netIface
    readonly property real rxRate: _rxRate
    readonly property real txRate: _txRate
    readonly property string netSpeed: _netSpeed
    property string _netIface: ""
    property real _rxRate: 0
    property real _txRate: 0
    property real _lastRx: 0
    property real _lastTx: 0
    property real _lastNetTs: 0
    property bool _netHasData: false
    property string _netSpeed: "—"
    function _formatSpeed(bps) {
        if (bps < 1024) return Math.round(bps) + " B/s"
        if (bps < 1024 * 1024) return Math.round(bps / 1024) + " KB/s"
        return (bps / (1024 * 1024)).toFixed(1) + " MB/s"
    }
    PollingProcess {
        id: _ifaceProc
        interval: 60000
        // Default-route iface first (so tailscale0/wg/virbr tunnels don't win),
        // falling back to the first plausible up link.
        command: ["sh", "-c", "i=$(ip route show default 2>/dev/null | awk '{print $5; exit}'); [ -n \"$i\" ] && echo \"$i\" || ip -o link show up 2>/dev/null | awk -F': ' '{print $2}' | grep -vE '^(lo|docker|br-|veth|tailscale|wg|tun|virbr|vnet)' | head -1"]
        onOutput: text => {
            var s = text.trim()
            if (s && s !== root._netIface) {
                root._netIface = s
                root._netHasData = false
            }
        }
    }
    PollingProcess {
        id: _netStatsProc
        interval: 2000
        active: root._netIface !== ""
        command: root._netIface ? ["sh", "-c", "cat /sys/class/net/" + root._netIface + "/statistics/rx_bytes /sys/class/net/" + root._netIface + "/statistics/tx_bytes 2>/dev/null"] : []
        onOutput: text => {
            var lines = text.trim().split("\n")
            if (lines.length >= 2) {
                var rx = parseFloat(lines[0]) || 0
                var tx = parseFloat(lines[1]) || 0
                var now = Date.now()
                // Divide by real elapsed time, not the nominal interval — a
                // delayed tick otherwise inflates the rate.
                var dt = root._lastNetTs > 0 ? (now - root._lastNetTs) / 1000 : 2
                if (root._netHasData && dt > 0) {
                    root._rxRate = Math.max(0, (rx - root._lastRx) / dt)
                    root._txRate = Math.max(0, (tx - root._lastTx) / dt)
                    root._netSpeed = "↓ " + root._formatSpeed(root._rxRate) + "  ↑ " + root._formatSpeed(root._txRate)
                }
                root._lastRx = rx
                root._lastTx = tx
                root._lastNetTs = now
                root._netHasData = true
            }
        }
    }

    Component.onCompleted: {
        _backlightDetectProc.running = true
    }
}
