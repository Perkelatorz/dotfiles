import QtQuick
import Quickshell.Services.Mpris

import "."

// Native Mpris service — event-driven, replaces the 3s playerctl polling and
// its sentinel-string parser (which corrupted on titles containing "STATUS",
// "SHUF", etc.). Public interface preserved for MiniPlayerContent/shell.qml.
BarPill {
    id: nowPlayingWidget

    signal openMiniPlayerRequested()

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

    icon: status === "Playing" ? "" : ""
    present: hasPlayer

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

    onClicked: mouse => {
        if (mouse.button === Qt.MiddleButton) nowPlayingWidget.playPause()
        else nowPlayingWidget.openMiniPlayerRequested()
    }

    // Scrolling track label (max 160px, marquee when it overflows).
    Item {
        width: Math.min(npLabel.implicitWidth, 160)
        height: npLabel.implicitHeight
        anchors.verticalCenter: parent.verticalCenter
        clip: true
        Text {
            id: npLabel
            readonly property string displayText: {
                var a = nowPlayingWidget.artist
                var t = nowPlayingWidget.title
                if (t) return a ? (a + " \u2013 " + t) : t
                return a || "\u2014"
            }
            text: displayText
            color: nowPlayingWidget.fg
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
