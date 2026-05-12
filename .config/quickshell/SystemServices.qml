pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

// Single source of truth for system state polled via shell.
// Bar widgets and QuickSettings panel both bind to these properties.
// Replaces duplicated Process+Timer triples spread across widgets.
Singleton {
    id: root

    // ===== consumer-gate flags (set by bars/panel; widgets bind their visibility here) =====
    property bool qsOpen: false

    // ===== BATTERY =====
    readonly property bool batteryHas: _batteryHas
    readonly property int batteryCapacity: _batteryCapacity
    readonly property string batteryStatus: _batteryStatus
    readonly property int batteryTimeMinutes: _batteryTimeMinutes
    readonly property string batteryTimeText: {
        if (!_batteryHas || _batteryTimeMinutes <= 0) return ""
        var h = Math.floor(_batteryTimeMinutes / 60)
        var m = _batteryTimeMinutes % 60
        if (h > 0) return h + "h " + m + "m"
        return m + "m"
    }
    property bool _batteryHas: false
    property int _batteryCapacity: 0
    property string _batteryStatus: ""
    property int _batteryTimeMinutes: 0
    PollingProcess {
        interval: 60000
        command: ["sh", "-c",
            "d=$(ls -d /sys/class/power_supply/BAT* 2>/dev/null | head -1); " +
            "if [ -n \"$d\" ] && [ -r \"$d/capacity\" ]; then " +
            "  echo 1; " +
            "  cat \"$d/capacity\" 2>/dev/null; " +
            "  cat \"$d/status\" 2>/dev/null; " +
            "  if [ -r \"$d/energy_now\" ] && [ -r \"$d/power_now\" ]; then " +
            "    echo \"E\"; cat \"$d/energy_now\"; cat \"$d/energy_full\" 2>/dev/null; cat \"$d/power_now\"; " +
            "  elif [ -r \"$d/charge_now\" ] && [ -r \"$d/current_now\" ]; then " +
            "    echo \"C\"; cat \"$d/charge_now\"; cat \"$d/charge_full\" 2>/dev/null; cat \"$d/current_now\"; " +
            "  fi; " +
            "else echo 0; fi"]
        onOutput: text => {
            var lines = text.trim().split("\n")
            root._batteryHas = lines.length >= 1 && lines[0] === "1"
            if (root._batteryHas && lines.length >= 2) {
                var p = parseInt(lines[1], 10)
                root._batteryCapacity = isNaN(p) ? 0 : Math.max(0, Math.min(100, p))
                root._batteryStatus = lines.length >= 3 ? String(lines[2]).trim() : ""
                root._batteryTimeMinutes = 0
                if (lines.length >= 7 && (lines[3] === "E" || lines[3] === "C")) {
                    var now = parseFloat(lines[4]) || 0
                    var full = parseFloat(lines[5]) || 0
                    var rate = parseFloat(lines[6]) || 0
                    if (rate > 0) {
                        var hours = (root._batteryStatus === "Charging") ? (full - now) / rate : now / rate
                        if (hours > 0 && hours < 48) root._batteryTimeMinutes = Math.round(hours * 60)
                    }
                }
            }
        }
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
            _setBrightProc.command = ["sh", "-c", "m=$(cat \"" + _backlightPath + "/max_brightness\"); v=$((m * " + p + " / 100)); echo $v > \"" + _backlightPath + "/brightness\""]
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
            _readBrightProc.command = dev ? ["sh", "-c", "brightnessctl -d " + JSON.stringify(dev) + " -m 2>/dev/null"] : ["sh", "-c", "brightnessctl -m 2>/dev/null"]
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
    Timer {
        interval: 2000
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
            if (s) {
                var parts = s.split(":")
                root._wifiStatus = parts.length >= 2 ? (parts[0] + " " + parts[1] + "%") : s
            } else {
                root._wifiStatus = "Disconnected"
            }
        }
    }
    PollingProcess {
        id: _wifiStateProc
        interval: 30000
        command: ["sh", "-c", "nmcli radio wifi 2>/dev/null"]
        onOutput: text => { root._wifiEnabled = text.trim() === "enabled" }
    }

    // ===== BLUETOOTH =====
    readonly property string btStatus: _btStatus
    readonly property bool btPowered: _btPowered
    property string _btStatus: "N/A"
    property bool _btPowered: false
    function toggleBluetooth() { _toggleBtProc.running = true }
    Process {
        id: _toggleBtProc
        command: ["sh", "-c", "if bluetoothctl show 2>/dev/null | grep -q 'Powered: yes'; then bluetoothctl power off; else bluetoothctl power on; fi"]
        running: false
        stdout: StdioCollector {
            onStreamFinished: { _toggleBtProc.running = false; _btProc.refresh() }
        }
    }
    PollingProcess {
        id: _btProc
        interval: 30000
        command: ["sh", "-c", "if ! bluetoothctl show 2>/dev/null | grep -q 'Powered: yes'; then echo 'PWROFF'; exit 0; fi; name=$(bluetoothctl devices 2>/dev/null | awk '{print $2}' | while read m; do bluetoothctl info \"$m\" 2>/dev/null | grep -q 'Connected: yes' && bluetoothctl info \"$m\" 2>/dev/null | grep 'Name:' | sed 's/.*Name: //' | head -1 && break; done); if [ -z \"$name\" ]; then echo -e 'On\\nNo devices'; else echo -e \"On\\n${name}\"; fi"]
        onOutput: text => {
            var s = text.trim()
            if (s === "PWROFF") {
                root._btPowered = false
                root._btStatus = "Off"
            } else {
                root._btPowered = true
                root._btStatus = s || "On"
            }
        }
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

    // ===== THEME =====
    readonly property string themeStatus: _themeStatus
    property string _themeStatus: "…"
    PollingProcess {
        interval: 2000
        command: ["sh", "-c", "F=\"${XDG_CACHE_HOME:-$HOME/.cache}/hypr/current-theme.txt\"; if [ -r \"$F\" ]; then cat \"$F\"; else C=\"${XDG_CONFIG_HOME:-$HOME/.config}/quickshell/Colors.qml\"; if [ -r \"$C\" ]; then grep -E 'Palette:|background:' \"$C\" | head -2 | tr '\\n' ' '; fi; fi"]
        onOutput: text => {
            var raw = text.trim()
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
    readonly property string _weatherUrl: _weatherLocation ? ("wttr.in/" + _weatherLocation) : "wttr.in"

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
        _saveWeatherLocProc.command = ["sh", "-c", "echo " + JSON.stringify(loc) + " > \"${XDG_CONFIG_HOME:-$HOME/.config}/quickshell/weather-location.txt\""]
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
        command: ["sh", "-c", "curl -s '" + root._weatherUrl + "?format=j1' 2>/dev/null"]
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

    // ===== POWER PROFILE =====
    readonly property string powerProfile: _powerProfile
    readonly property string powerIcon: _powerIcon
    property string _powerProfile: "—"
    property string _powerIcon: ""
    readonly property var _powerIcons: ({ "balanced": "", "performance": "", "power-saver": "" })

    function cyclePowerProfile() {
        var order = ["balanced", "performance", "power-saver"]
        var cur = _powerProfile.toLowerCase()
        var idx = order.indexOf(cur)
        var next = order[(idx + 1) % order.length]
        _powerSetProc.command = ["powerprofilesctl", "set", next]
        _powerSetProc.running = true
    }
    PollingProcess {
        id: _powerGetProc
        interval: 10000
        command: ["powerprofilesctl", "get"]
        onOutput: text => {
            var s = text.trim()
            if (s) {
                root._powerProfile = s.charAt(0).toUpperCase() + s.slice(1)
                root._powerIcon = root._powerIcons[s] || ""
            }
        }
    }
    Process {
        id: _powerSetProc
        command: []
        running: false
        stdout: StdioCollector {
            onStreamFinished: { _powerSetProc.running = false; _powerGetProc.refresh() }
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
        command: ["sh", "-c", "ip -o link show up 2>/dev/null | awk -F': ' '{print $2}' | grep -vE '^(lo|docker|br-|veth)' | head -1"]
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
                if (root._netHasData) {
                    root._rxRate = Math.max(0, (rx - root._lastRx) / 2)
                    root._txRate = Math.max(0, (tx - root._lastTx) / 2)
                    root._netSpeed = "↓ " + root._formatSpeed(root._rxRate) + "  ↑ " + root._formatSpeed(root._txRate)
                }
                root._lastRx = rx
                root._lastTx = tx
                root._netHasData = true
            }
        }
    }

    Component.onCompleted: {
        _backlightDetectProc.running = true
    }
}
