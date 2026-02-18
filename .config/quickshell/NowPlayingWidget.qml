import QtQuick
import Quickshell.Io

import "."

Item {
    id: nowPlayingWidget
    required property var colors
    property int pillIndex: 6

    signal openMiniPlayerRequested()

    readonly property color pillColor: (colors.widgetPillColors && pillIndex >= 0 && pillIndex < colors.widgetPillColors.length) ? colors.widgetPillColors[pillIndex] : colors.primary
    readonly property color pillTextColor: (colors.widgetTextOnPillColors && pillIndex >= 0 && pillIndex < colors.widgetTextOnPillColors.length) ? colors.widgetTextOnPillColors[pillIndex] : colors.textMain

    property string title: ""
    property string artist: ""
    property string artUrl: ""
    property string status: ""  // Playing, Paused, Stopped
    property bool hasPlayer: false
    property var playerList: []
    property string selectedPlayer: ""

    implicitWidth: hasPlayer ? pill.width : 0
    implicitHeight: hasPlayer ? 28 : 0
    visible: hasPlayer

    function refreshMetadata() {
        if (!metaProc.running) nowPlayingWidget.startMetaProc()
    }

    function refreshList() {
        if (!listProc.running) listProc.running = true
    }

    function playPause() {
        playPauseProc.command = ["playerctl"].concat(nowPlayingWidget.playerArg()).concat(["play-pause"])
        playPauseProc.running = true
    }

    function previous() {
        previousProc.command = ["playerctl"].concat(nowPlayingWidget.playerArg()).concat(["previous"])
        previousProc.running = true
    }

    function next() {
        nextProc.command = ["playerctl"].concat(nowPlayingWidget.playerArg()).concat(["next"])
        nextProc.running = true
    }

    function setSelectedPlayer(name) {
        nowPlayingWidget.selectedPlayer = name || ""
        if (!metaProc.running) nowPlayingWidget.startMetaProc()
    }

    function playerArg() {
        return (nowPlayingWidget.selectedPlayer !== "") ? ["-p", nowPlayingWidget.selectedPlayer] : []
    }

    function startMetaProc() {
        var p = nowPlayingWidget.playerArg()
        var pre = p.length ? (p.join(" ") + " ") : ""
        metaProc.command = ["sh", "-c", "playerctl " + pre + "metadata --format '{{ artist }}|||{{ title }}' 2>/dev/null; echo 'STATUS'; playerctl " + pre + "status 2>/dev/null; echo 'ARTURL'; playerctl " + pre + "metadata mpris:artUrl 2>/dev/null"]
        metaProc.running = true
    }

    Process {
        id: listProc
        command: ["playerctl", "-l"]
        running: false
        stdout: StdioCollector {
            onStreamFinished: {
                var lines = (listProc.stdout.text || "").trim().split("\n").filter(function(l) { return l.length > 0 })
                nowPlayingWidget.playerList = lines
                nowPlayingWidget.hasPlayer = lines.length > 0
                if (lines.length > 0 && (nowPlayingWidget.selectedPlayer === "" || lines.indexOf(nowPlayingWidget.selectedPlayer) < 0))
                    nowPlayingWidget.selectedPlayer = lines[0]
                listProc.running = false
                if (lines.length > 0 && !metaProc.running) nowPlayingWidget.startMetaProc()
            }
        }
    }

    Process {
        id: metaProc
        command: []
        running: false
        stdout: StdioCollector {
            onStreamFinished: {
                var out = (metaProc.stdout.text || "").trim()
                var artParts = out.split("ARTURL")
                var main = artParts.length >= 1 ? artParts[0].trim() : ""
                nowPlayingWidget.artUrl = artParts.length >= 2 ? String(artParts[1]).trim() : ""
                var parts = main.split("STATUS")
                if (parts.length >= 1 && parts[0].trim() !== "") {
                    var meta = parts[0].trim().split("|||")
                    nowPlayingWidget.artist = meta.length >= 1 ? String(meta[0]).trim() : ""
                    nowPlayingWidget.title = meta.length >= 2 ? String(meta[1]).trim() : ""
                }
                if (parts.length >= 2) {
                    nowPlayingWidget.status = String(parts[1]).trim()
                }
                metaProc.running = false
            }
        }
    }

    Process {
        id: playPauseProc
        command: ["playerctl", "play-pause"]
        running: false
        onRunningChanged: if (!running) nowPlayingWidget.startMetaProc()
    }

    Process {
        id: previousProc
        command: ["playerctl", "previous"]
        running: false
        onRunningChanged: if (!running) nowPlayingWidget.startMetaProc()
    }

    Process {
        id: nextProc
        command: ["playerctl", "next"]
        running: false
        onRunningChanged: if (!running) nowPlayingWidget.startMetaProc()
    }

    Timer {
        interval: 3000
        repeat: true
        running: nowPlayingWidget.visible
        onTriggered: function() {
            if (!listProc.running) listProc.running = true
            else if (!metaProc.running) nowPlayingWidget.startMetaProc()
        }
    }

    Component.onCompleted: listProc.running = true

    Rectangle {
        id: pill
        height: nowPlayingWidget.implicitHeight - (colors.widgetPillPaddingV) * 2
        width: Math.min(row.implicitWidth + (colors.widgetPillPaddingH) * 2, 220)
        anchors.verticalCenter: parent.verticalCenter
        radius: colors.widgetPillRadius
        color: mouseArea.pressed ? Qt.darker(nowPlayingWidget.pillColor, 1.15) : mouseArea.containsMouse ? Qt.lighter(nowPlayingWidget.pillColor, 1.2) : nowPlayingWidget.pillColor
        border.width: 1
        border.color: mouseArea.containsMouse ? Qt.lighter(nowPlayingWidget.pillColor, 1.4) : nowPlayingWidget.pillColor
        scale: mouseArea.pressed ? 0.94 : 1.0
        visible: nowPlayingWidget.hasPlayer
        Behavior on color { ColorAnimation { duration: 100 } }
        Behavior on border.color { ColorAnimation { duration: 100 } }
        Behavior on scale { NumberAnimation { duration: 80; easing.type: Easing.OutCubic } }

        MouseArea {
            id: mouseArea
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            acceptedButtons: Qt.LeftButton | Qt.MiddleButton
            onClicked: function(mouse) {
                if (mouse.button === Qt.LeftButton)
                    nowPlayingWidget.openMiniPlayerRequested()
                else if (mouse.button === Qt.MiddleButton)
                    nowPlayingWidget.playPause()
            }
            Row {
                id: row
                anchors.centerIn: parent
                spacing: 6
                leftPadding: colors.widgetPillPaddingH
                rightPadding: colors.widgetPillPaddingH
                Text {
                    text: nowPlayingWidget.status === "Playing" ? "\uF04B" : "\uF04C"
                    color: nowPlayingWidget.pillTextColor
                    font.pixelSize: colors.cpuFontSize
                    font.family: colors.widgetIconFont
                }
                Item {
                    width: 160
                    height: npLabel.implicitHeight
                    clip: true
                    Text {
                        id: npLabel
                        readonly property string displayText: {
                            var a = nowPlayingWidget.artist
                            var t = nowPlayingWidget.title
                            if (t) return a ? (a + " – " + t) : t
                            return a || "—"
                        }
                        text: displayText
                        color: nowPlayingWidget.pillTextColor
                        font.pixelSize: colors.cpuFontSize
                        readonly property bool overflows: implicitWidth > 160
                        x: overflows ? npScrollAnim.scrollX : 0
                        property real _scrollX: 0
                        NumberAnimation on _scrollX {
                            id: npScrollAnim
                            property real scrollX: npLabel.overflows ? npLabel._scrollX : 0
                            from: 0
                            to: npLabel.overflows ? -(npLabel.implicitWidth + 40) : 0
                            duration: npLabel.overflows ? Math.max(3000, (npLabel.implicitWidth + 40) * 30) : 0
                            loops: Animation.Infinite
                            running: npLabel.overflows && nowPlayingWidget.visible
                        }
                    }
                }
            }
        }
    }
}
