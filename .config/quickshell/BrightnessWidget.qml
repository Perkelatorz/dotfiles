import QtQuick
import Quickshell.Io

import "."

Item {
    id: brightnessWidget
    required property var colors
    property int pillIndex: 6
    /// Hyprland/output name for this bar's screen (e.g. "DP-1"); used to target that screen only when multiple brightness devices exist
    property string outputName: ""
    /// Index of this bar's screen in Quickshell.screens; used to pick which brightness device to use for multi-monitor
    property int screenIndex: 0

    readonly property color pillColor: (colors.widgetPillColors && pillIndex >= 0 && pillIndex < colors.widgetPillColors.length) ? colors.widgetPillColors[pillIndex] : colors.primary
    readonly property color pillTextColor: (colors.widgetTextOnPillColors && pillIndex >= 0 && pillIndex < colors.widgetTextOnPillColors.length) ? colors.widgetTextOnPillColors[pillIndex] : colors.textMain

    property bool hasBacklight: false
    property bool hasBrightnessctl: false
    property int brightness: 0
    property string backlightPath: ""
    property var brightnessctlDevices: []  // list of device names for per-screen selection

    readonly property bool hasBrightness: hasBacklight || hasBrightnessctl

    implicitWidth: Math.max(56, pill.width)
    implicitHeight: 28

    Process {
        id: detectProc
        command: ["sh", "-c", "d=$(ls -d /sys/class/backlight/* 2>/dev/null | head -1); if [ -n \"$d\" ] && [ -r \"$d/brightness\" ] && [ -r \"$d/max_brightness\" ]; then echo \"$d\"; else echo \"\"; fi"]
        stdout: StdioCollector {
            onStreamFinished: {
                var p = (detectProc.stdout.text || "").trim()
                brightnessWidget.backlightPath = p
                brightnessWidget.hasBacklight = p !== ""
                if (brightnessWidget.hasBacklight) {
                    readProc.command = ["sh", "-c", "b=$(cat \"" + p + "/brightness\" 2>/dev/null); m=$(cat \"" + p + "/max_brightness\" 2>/dev/null); [ -n \"$m\" ] && [ \"$m\" -gt 0 ] && echo $((b*100/m)) || echo 0"]
                    readProc.running = true
                } else {
                    detectBrightnessctlProc.running = true
                }
                detectProc.running = false
            }
        }
    }

    Process {
        id: detectBrightnessctlProc
        command: ["sh", "-c", "brightnessctl -l 2>/dev/null"]
        running: false
        stdout: StdioCollector {
            onStreamFinished: {
                var out = (detectBrightnessctlProc.stdout.text || "").trim()
                var devices = []
                var lines = out.split("\n").filter(function(l) { return l.length > 0 })
                for (var i = 0; i < lines.length; i++) {
                    var line = lines[i]
                    var m = line.match(/Device\s+(\S+)/)
                    if (m) devices.push(m[1])
                    else {
                        var tok = line.split(/\s+/).filter(function(t) { return t.indexOf("::") >= 0 })
                        if (tok.length) devices.push(tok[0])
                    }
                }
                brightnessWidget.brightnessctlDevices = devices
                brightnessWidget.hasBrightnessctl = devices.length > 0
                if (brightnessWidget.hasBrightnessctl) brightnessWidget.refreshBrightness()
                detectBrightnessctlProc.running = false
            }
        }
    }

    Process {
        id: readProc
        command: []
        running: false
        stdout: StdioCollector {
            onStreamFinished: {
                var v = parseInt(String(readProc.stdout.text).trim(), 10)
                brightnessWidget.brightness = isNaN(v) ? 0 : Math.max(0, Math.min(100, v))
                readProc.running = false
            }
        }
    }

    function brightnessctlDevice() {
        var list = brightnessctlDevices || []
        if (list.length === 0) return ""
        var idx = Math.max(0, Math.min(screenIndex, list.length - 1))
        return list[idx] || ""
    }

    Process {
        id: brightnessctlReadProc
        command: []
        running: false
        stdout: StdioCollector {
            onStreamFinished: {
                var line = (brightnessctlReadProc.stdout.text || "").trim()
                var match = line.match(/\s(\d+)%?\s*$/)
                if (match) brightnessWidget.brightness = Math.max(0, Math.min(100, parseInt(match[1], 10)))
                brightnessctlReadProc.running = false
            }
        }
    }

    function setBrightness(percent) {
        var p = Math.max(0, Math.min(100, Math.round(percent)))
        if (hasBacklight && backlightPath) {
            setProc.command = ["sh", "-c", "m=$(cat \"" + backlightPath + "/max_brightness\"); v=$((m * " + p + " / 100)); echo $v > \"" + backlightPath + "/brightness\""]
            setProc.running = true
        } else if (hasBrightnessctl) {
            var dev = brightnessctlDevice()
            if (dev) brightnessctlSetProc.command = ["brightnessctl", "-d", dev, "set", p + "%"]
            else brightnessctlSetProc.command = ["brightnessctl", "set", p + "%"]
            brightnessctlSetProc.running = true
        }
    }

    Process {
        id: setProc
        command: []
        running: false
        onRunningChanged: if (!running && hasBrightness) refreshBrightness()
    }

    Process {
        id: brightnessctlSetProc
        command: []
        running: false
        onRunningChanged: if (!running && hasBrightness) refreshBrightness()
    }

    function refreshBrightness() {
        if (hasBacklight) {
            readProc.running = true
        } else if (hasBrightnessctl) {
            var dev = brightnessctlDevice()
            if (dev) brightnessctlReadProc.command = ["sh", "-c", "brightnessctl -d " + JSON.stringify(dev) + " -m 2>/dev/null"]
            else brightnessctlReadProc.command = ["sh", "-c", "brightnessctl -m 2>/dev/null"]
            brightnessctlReadProc.running = true
        }
    }

    Timer {
        interval: 2000
        repeat: true
        running: brightnessWidget.hasBrightness
        onTriggered: brightnessWidget.refreshBrightness()
    }

    Process {
        id: openDisplaySettings
        command: ["wdisplays"]
        running: false
    }

    Component.onCompleted: detectProc.running = true

    Rectangle {
        id: pill
        height: brightnessWidget.implicitHeight - (colors.widgetPillPaddingV) * 2
        width: row.implicitWidth + (colors.widgetPillPaddingH) * 2
        anchors.verticalCenter: parent.verticalCenter
        radius: colors.widgetPillRadius
        color: mouseArea.pressed ? Qt.darker(brightnessWidget.pillColor, 1.15) : mouseArea.containsMouse ? Qt.lighter(brightnessWidget.pillColor, 1.2) : brightnessWidget.pillColor
        border.width: 1
        border.color: mouseArea.containsMouse ? Qt.lighter(brightnessWidget.pillColor, 1.4) : brightnessWidget.pillColor
        scale: mouseArea.pressed ? 0.94 : 1.0
        Behavior on color { ColorAnimation { duration: 100 } }
        Behavior on border.color { ColorAnimation { duration: 100 } }
        Behavior on scale { NumberAnimation { duration: 80; easing.type: Easing.OutCubic } }

        MouseArea {
            id: mouseArea
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            acceptedButtons: Qt.LeftButton | Qt.RightButton
            onClicked: function(mouse) {
                if (mouse.button === Qt.RightButton) openDisplaySettings.running = true
            }
            onWheel: function(wheel) {
                if (!brightnessWidget.hasBrightness) return
                var delta = wheel.angleDelta.y > 0 ? 5 : -5
                brightnessWidget.setBrightness(brightnessWidget.brightness + delta)
            }
            Row {
                id: row
                anchors.centerIn: parent
                spacing: 4
                Text {
                    text: "\uF185"
                    color: brightnessWidget.pillTextColor
                    font.pixelSize: colors.cpuFontSize
                    font.family: colors.widgetIconFont
                }
                Text {
                    text: brightnessWidget.hasBrightness ? (brightnessWidget.brightness + "%") : "N/A"
                    color: brightnessWidget.pillTextColor
                    font.pixelSize: colors.cpuFontSize
                }
            }
        }
        Rectangle {
            opacity: mouseArea.containsMouse ? 1 : 0
            visible: opacity > 0
            Behavior on opacity { NumberAnimation { duration: 150; easing.type: Easing.OutCubic } }
            anchors.bottom: parent.top
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottomMargin: 4
            width: brightTipCol.implicitWidth + 16
            height: brightTipCol.implicitHeight + 8
            radius: 4
            color: colors.surface
            border.width: 1
            border.color: colors.border
            z: 1000
            Column {
                id: brightTipCol
                anchors.centerIn: parent
                spacing: 3
                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "Brightness: " + brightnessWidget.brightness + "%"
                    color: colors.textMain
                    font.pixelSize: colors.fontSize - 1
                }
                Rectangle {
                    width: 80
                    height: 4
                    radius: 2
                    color: colors.borderSubtle
                    Rectangle {
                        width: parent.width * (brightnessWidget.brightness / 100)
                        height: parent.height
                        radius: 2
                        color: colors.tertiary
                        Behavior on width { NumberAnimation { duration: 80 } }
                    }
                }
            }
        }
    }
}
