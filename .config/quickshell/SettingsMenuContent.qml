import QtQuick
import Quickshell.Io

import "."

Item {
    id: settingsMenuContent
    required property var colors
    required property var onClose
    required property var settingsState

    implicitWidth: 320
    implicitHeight: 420

    property var sinkList: []
    property int selectedSinkId: -1
    property string selectedSinkName: ""
    property real sinkVolume: 0
    property bool sinkMuted: false
    property bool volumeDropdownOpen: false

    readonly property string volumeDetailText: {
        if (!selectedSinkName) return "Select an output above."
        if (sinkMuted) return "Output: " + selectedSinkName + " (muted)"
        return "Output: " + selectedSinkName + " — " + Math.round(sinkVolume * 100) + "%"
    }

    Process {
        id: wpctlStatusProc
        command: ["wpctl", "status"]
        running: false
        stdout: StdioCollector {
            onStreamFinished: {
                var lines = (wpctlStatusProc.stdout.text || "").split("\n")
                var sinks = []
                var inSinks = false
                for (var i = 0; i < lines.length; i++) {
                    var line = lines[i]
                    if (line.indexOf("Sinks:") >= 0) { inSinks = true; continue }
                    if (inSinks && (line.indexOf("Sources:") >= 0 || line.indexOf("├─") < 0 && line.indexOf("│") < 0)) break
                    if (inSinks && line.indexOf("│") >= 0) {
                        var match = line.match(/(\d+)\.\s*(.+?)(?:\s+\[vol:)?/)
                        if (match) {
                            var id = parseInt(match[1], 10)
                            var name = match[2].trim()
                            var isDefault = line.indexOf("*") >= 0
                            sinks.push({ id: id, name: name, isDefault: isDefault })
                            if (isDefault && settingsMenuContent.selectedSinkId < 0) {
                                settingsMenuContent.selectedSinkId = id
                                settingsMenuContent.selectedSinkName = name
                            }
                        }
                    }
                }
                settingsMenuContent.sinkList = sinks
                if (sinks.length > 0 && settingsMenuContent.selectedSinkId < 0) {
                    settingsMenuContent.selectedSinkId = sinks[0].id
                    settingsMenuContent.selectedSinkName = sinks[0].name
                }
                wpctlStatusProc.running = false
                if (settingsMenuContent.selectedSinkId >= 0) settingsMenuContent.runGetVolume()
            }
        }
    }

    function runGetVolume() {
        wpctlGetVolumeProc.command = ["sh", "-c", "wpctl get-volume " + settingsMenuContent.selectedSinkId + " 2>/dev/null"]
        wpctlGetVolumeProc.running = true
    }

    Process {
        id: wpctlGetVolumeProc
        command: []
        running: false
        stdout: StdioCollector {
            onStreamFinished: {
                var out = (wpctlGetVolumeProc.stdout.text || "").trim().toLowerCase()
                var muted = out.indexOf("muted") >= 0
                var m = out.match(/([0-9.]+)/)
                var v = m ? parseFloat(m[1]) : 0
                if (v > 1) v = v / 100
                settingsMenuContent.sinkVolume = Math.min(1, Math.max(0, v))
                settingsMenuContent.sinkMuted = muted
                wpctlGetVolumeProc.running = false
            }
        }
    }

    function refreshSinks() {
        if (!wpctlStatusProc.running) wpctlStatusProc.running = true
    }

    function setVolume(val) {
        if (selectedSinkId < 0) return
        var pct = Math.round(Math.min(100, Math.max(0, val * 100)))
        setVolProc.command = ["wpctl", "set-volume", String(selectedSinkId), pct + "%"]
        setVolProc.running = true
        settingsMenuContent.sinkVolume = val
    }

    function setMute(muted) {
        if (selectedSinkId < 0) return
        muteProc.command = ["wpctl", "set-mute", String(selectedSinkId), muted ? "1" : "0"]
        muteProc.running = true
        settingsMenuContent.sinkMuted = muted
    }

    function selectSink(id) {
        settingsMenuContent.selectedSinkId = id
        var s = sinkList.find(function(x) { return x.id === id })
        settingsMenuContent.selectedSinkName = s ? s.name : ""
        volumeDropdownOpen = false
        runGetVolume()
    }

    Process {
        id: setVolProc
        command: []
        running: false
        onRunningChanged: if (!running && selectedSinkId >= 0) runGetVolume()
    }
    Process {
        id: muteProc
        command: []
        running: false
        onRunningChanged: if (!running) runGetVolume()
    }

    Component.onCompleted: refreshSinks()

    Rectangle {
        anchors.fill: parent
        radius: 8
        color: colors.surfaceContainer
        border.width: 1
        border.color: colors.border

        Column {
            id: mainColumn
            anchors.fill: parent
            anchors.margins: 10
            spacing: 8

            Row {
                width: parent.width - 20
                height: 28
                Item {
                    width: 24
                    height: parent.height
                    MouseArea {
                        anchors.fill: parent
                        onClicked: settingsMenuContent.onClose()
                        Text {
                            anchors.centerIn: parent
                            text: "\uF00D"
                            color: colors.textDim
                            font.pixelSize: 14
                            font.family: colors.widgetIconFont
                        }
                        hoverEnabled: true
                    }
                }
                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text: "Widgets & settings"
                    color: colors.primary
                    font.pixelSize: colors.clockFontSize + 1
                    font.bold: true
                }
            }

            Text {
                text: "Bar widgets"
                color: colors.textDim
                font.pixelSize: colors.clockFontSize - 1
            }

            Grid {
                id: widgetGrid
                width: parent.width - 20
                columns: 2
                rowSpacing: 4
                columnSpacing: 8

                WidgetToggleRow { isOn: settingsState.volumeWidgetVisible; onToggle: function() { settingsState.volumeWidgetVisible = !settingsState.volumeWidgetVisible }; label: "Volume"; icon: "\uF028"; colors: settingsMenuContent.colors }
                WidgetToggleRow { isOn: settingsState.nowPlayingWidgetVisible; onToggle: function() { settingsState.nowPlayingWidgetVisible = !settingsState.nowPlayingWidgetVisible }; label: "Now playing"; icon: "\uF001"; colors: settingsMenuContent.colors }
                WidgetToggleRow { isOn: settingsState.cpuWidgetVisible; onToggle: function() { settingsState.cpuWidgetVisible = !settingsState.cpuWidgetVisible }; label: "CPU"; icon: "\uF2DB"; colors: settingsMenuContent.colors }
                WidgetToggleRow { isOn: settingsState.ramWidgetVisible; onToggle: function() { settingsState.ramWidgetVisible = !settingsState.ramWidgetVisible }; label: "RAM"; icon: "\uF538"; colors: settingsMenuContent.colors }
                WidgetToggleRow { isOn: settingsState.batteryWidgetVisible; onToggle: function() { settingsState.batteryWidgetVisible = !settingsState.batteryWidgetVisible }; label: "Battery"; icon: "\uF240"; colors: settingsMenuContent.colors }
                WidgetToggleRow { isOn: settingsState.brightnessWidgetVisible; onToggle: function() { settingsState.brightnessWidgetVisible = !settingsState.brightnessWidgetVisible }; label: "Brightness"; icon: "\uF185"; colors: settingsMenuContent.colors }
                WidgetToggleRow { isOn: settingsState.microphoneWidgetVisible; onToggle: function() { settingsState.microphoneWidgetVisible = !settingsState.microphoneWidgetVisible }; label: "Microphone"; icon: "\uF3A5"; colors: settingsMenuContent.colors }
                WidgetToggleRow { isOn: settingsState.ipAddressWidgetVisible; onToggle: function() { settingsState.ipAddressWidgetVisible = !settingsState.ipAddressWidgetVisible }; label: "IP address"; icon: "\uF0AC"; colors: settingsMenuContent.colors }
                WidgetToggleRow { isOn: settingsState.screenshotWidgetVisible; onToggle: function() { settingsState.screenshotWidgetVisible = !settingsState.screenshotWidgetVisible }; label: "Screenshot"; icon: "\uF030"; colors: settingsMenuContent.colors }
            }

            Item { height: 6; width: 1 }
            Text {
                text: "Volume (output)"
                color: colors.textDim
                font.pixelSize: colors.clockFontSize - 1
            }

            Column {
                width: parent.width - 20
                spacing: 4

                Row {
                    width: parent.width
                    height: 24
                    spacing: 6
                    Text {
                        text: "\uF028"
                        color: colors.textMain
                        font.pixelSize: 12
                        font.family: colors.widgetIconFont
                        anchors.verticalCenter: parent.verticalCenter
                    }
                    Item {
                        width: 140
                        height: 24
                        MouseArea {
                            id: sinkTrigger
                            anchors.fill: parent
                            hoverEnabled: true
                            onClicked: settingsMenuContent.volumeDropdownOpen = !settingsMenuContent.volumeDropdownOpen
                            Rectangle {
                                anchors.fill: parent
                                radius: 4
                                color: sinkTrigger.containsMouse ? colors.surfaceBright : "transparent"
                                border.width: 1
                                border.color: settingsMenuContent.volumeDropdownOpen ? colors.primary : colors.borderSubtle
                                Text {
                                    anchors.left: parent.left
                                    anchors.verticalCenter: parent.verticalCenter
                                    leftPadding: 6
                                    width: parent.width - 12
                                    elide: Text.ElideRight
                                    text: settingsMenuContent.selectedSinkName || "Select sink..."
                                    color: colors.textMain
                                    font.pixelSize: colors.clockFontSize - 1
                                }
                                Text {
                                    anchors.right: parent.right
                                    anchors.verticalCenter: parent.verticalCenter
                                    rightPadding: 6
                                    text: settingsMenuContent.volumeDropdownOpen ? "\uF0D8" : "\uF0D7"
                                    color: colors.textDim
                                    font.pixelSize: 10
                                    font.family: colors.widgetIconFont
                                }
                            }
                        }
                    }
                }

                Rectangle {
                    width: parent.width
                    height: settingsMenuContent.volumeDropdownOpen && sinkList.length > 0 ? Math.min(sinkList.length, 5) * 26 : 0
                    radius: 4
                    color: colors.surface
                    border.width: 1
                    border.color: colors.borderSubtle
                    visible: settingsMenuContent.volumeDropdownOpen && sinkList.length > 0
                    z: 10
                    Column {
                        Repeater {
                            model: settingsMenuContent.sinkList
                            delegate: MouseArea {
                                id: sinkItemMa
                                width: parent.width - 4
                                height: 24
                                hoverEnabled: true
                                onClicked: settingsMenuContent.selectSink(modelData.id)
                                Rectangle {
                                    anchors.fill: parent
                                    anchors.margins: 2
                                    radius: 3
                                    color: sinkItemMa.containsMouse ? colors.surfaceBright : "transparent"
                                    Text {
                                        anchors.left: parent.left
                                        anchors.verticalCenter: parent.verticalCenter
                                        leftPadding: 6
                                        text: (modelData.isDefault ? "★ " : "") + modelData.name
                                        color: modelData.id === settingsMenuContent.selectedSinkId ? colors.primary : colors.textMain
                                        font.pixelSize: colors.clockFontSize - 1
                                    }
                                }
                            }
                        }
                    }
                }

                Row {
                    width: parent.width
                    height: 32
                    spacing: 8
                    Item {
                        id: volumeSlider
                        width: parent.width - 80
                        height: 24
                        property real dragVal: 0
                        readonly property real val: sliderMouse.pressed ? dragVal : settingsMenuContent.sinkVolume
                        Rectangle {
                            id: track
                            width: parent.width
                            height: 4
                            radius: 2
                            anchors.verticalCenter: parent.verticalCenter
                            color: colors.surfaceBright
                            Rectangle {
                                width: parent.width * volumeSlider.val
                                height: parent.height
                                radius: 2
                                color: colors.primary
                            }
                        }
                        Rectangle {
                            id: handle
                            width: 16
                            height: 16
                            radius: 8
                            anchors.verticalCenter: parent.verticalCenter
                            x: (volumeSlider.width - width) * volumeSlider.val
                            color: sliderMouse.pressed ? colors.primaryContainer : colors.primary
                            border.width: 1
                            border.color: colors.border
                        }
                        MouseArea {
                            id: sliderMouse
                            anchors.fill: parent
                            anchors.leftMargin: -8
                            anchors.rightMargin: -8
                            function setVal(mouseX) {
                                var w = volumeSlider.width
                                var p = Math.min(1, Math.max(0, (mouseX - 8) / w))
                                volumeSlider.dragVal = p
                                settingsMenuContent.setVolume(p)
                            }
                            onPressed: setVal(mouse.x)
                            onPositionChanged: if (pressed) setVal(mouse.x)
                        }
                    }
                    Text {
                        width: 36
                        height: 24
                        text: Math.round(settingsMenuContent.sinkVolume * 100) + "%"
                        color: colors.textMain
                        font.pixelSize: colors.clockFontSize
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }

                Row {
                    width: parent.width
                    height: 20
                    spacing: 8
                    Text {
                        text: "Mute"
                        color: colors.textDim
                        font.pixelSize: colors.clockFontSize - 1
                        anchors.verticalCenter: parent.verticalCenter
                    }
                    Rectangle {
                        width: 32
                        height: 18
                        radius: 4
                        color: settingsMenuContent.sinkMuted ? colors.error : colors.surfaceBright
                        border.width: 1
                        border.color: colors.borderSubtle
                        anchors.verticalCenter: parent.verticalCenter
                        MouseArea {
                            anchors.fill: parent
                            onClicked: settingsMenuContent.setMute(!settingsMenuContent.sinkMuted)
                        }
                        Text {
                            anchors.centerIn: parent
                            text: settingsMenuContent.sinkMuted ? "M" : "On"
                            color: colors.textMain
                            font.pixelSize: 10
                        }
                    }
                }

                Text {
                    width: parent.width - 4
                    wrapMode: Text.WordWrap
                    text: settingsMenuContent.volumeDetailText
                    color: colors.textDim
                    font.pixelSize: colors.clockFontSize - 2
                }
            }
        }
    }
}
