import QtQuick
import Quickshell.Services.Mpris

import "."

// Native Mpris service — event-driven, replaces the 3s playerctl polling and
// its sentinel-string parser (which corrupted on titles containing "STATUS",
// "SHUF", etc.). Public interface preserved for MiniPlayerContent/shell.qml.
Item {
    id: nowPlayingWidget
    required property var colors
    property int pillIndex: 6

    signal openMiniPlayerRequested()

    readonly property color pillColor: (colors.widgetPillColors && pillIndex >= 0 && pillIndex < colors.widgetPillColors.length) ? colors.widgetPillColors[pillIndex] : colors.primary
    readonly property color pillTextColor: (colors.widgetTextOnPillColors && pillIndex >= 0 && pillIndex < colors.widgetTextOnPillColors.length) ? colors.widgetTextOnPillColors[pillIndex] : colors.textMain

    property string selectedPlayer: ""
    readonly property var _player: {
        var ps = Mpris.players.values
        if (ps.length === 0) return null
        for (var i = 0; i < ps.length; i++) {
            if (ps[i].identity === nowPlayingWidget.selectedPlayer) return ps[i]
        }
        return ps[0]
    }
    readonly property var playerList: {
        var names = []
        var ps = Mpris.players.values
        for (var i = 0; i < ps.length; i++) names.push(ps[i].identity)
        return names
    }
    readonly property bool hasPlayer: _player !== null
    readonly property string title: _player ? (_player.trackTitle || "") : ""
    readonly property string artist: _player ? (_player.trackArtist || "") : ""
    readonly property string artUrl: _player ? (_player.trackArtUrl || "") : ""
    readonly property string status: {
        if (!_player) return ""
        switch (_player.playbackState) {
        case MprisPlaybackState.Playing: return "Playing"
        case MprisPlaybackState.Paused: return "Paused"
        default: return "Stopped"
        }
    }
    readonly property bool shuffleOn: _player && _player.shuffleSupported ? _player.shuffle : false
    readonly property string loopMode: {
        if (!_player || !_player.loopSupported) return "None"
        switch (_player.loopState) {
        case MprisLoopState.Track: return "Track"
        case MprisLoopState.Playlist: return "Playlist"
        default: return "None"
        }
    }

    implicitWidth: hasPlayer ? pill.width : 0
    implicitHeight: hasPlayer ? 28 : 0
    visible: hasPlayer

    // No-ops kept for MiniPlayerContent compatibility — Mpris pushes changes.
    function refreshMetadata() { }
    function refreshList() { }

    function setSelectedPlayer(name) { nowPlayingWidget.selectedPlayer = name || "" }
    function playPause() { if (_player && _player.canTogglePlaying) _player.togglePlaying() }
    function previous() { if (_player && _player.canGoPrevious) _player.previous() }
    function next() { if (_player && _player.canGoNext) _player.next() }
    function toggleShuffle() { if (_player && _player.shuffleSupported) _player.shuffle = !_player.shuffle }
    function cycleLoop() {
        if (!_player || !_player.loopSupported) return
        switch (_player.loopState) {
        case MprisLoopState.None: _player.loopState = MprisLoopState.Track; break
        case MprisLoopState.Track: _player.loopState = MprisLoopState.Playlist; break
        default: _player.loopState = MprisLoopState.None; break
        }
    }

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
