import QtQuick
import Quickshell
import Quickshell.Services.Pipewire

import "."

// Native audio panel — the replacement for shelling out to pavucontrol.
//
// Everything here talks to Pipewire directly through Quickshell's service, so
// there is no subprocess, no external window, and a change is reflected the
// instant it lands rather than after a poll.
Column {
    id: audio
    required property var colors
    property var onClose: null
    // The caller binds this to the panel's visibility: PwObjectTracker only
    // needs to bind the nodes while somebody is looking at them.
    property bool panelOpen: false

    width: 320
    padding: 12
    spacing: 12

    readonly property var sink: Pipewire.defaultAudioSink
    readonly property var source: Pipewire.defaultAudioSource

    function _nodes(wantSink, wantStream) {
        var out = []
        var all = Pipewire.nodes ? Pipewire.nodes.values : []
        for (var i = 0; i < all.length; i++) {
            var n = all[i]
            if (!n || !n.audio) continue
            if (!!n.isStream !== wantStream) continue
            if (!wantStream && !!n.isSink !== wantSink) continue
            out.push(n)
        }
        return out
    }

    readonly property var sinks:   panelOpen ? _nodes(true,  false) : []
    readonly property var sources: panelOpen ? _nodes(false, false) : []
    readonly property var streams: panelOpen ? _nodes(false, true)  : []

    // Live audio properties only arrive for tracked nodes.
    PwObjectTracker {
        objects: audio.panelOpen
            ? audio.sinks.concat(audio.sources).concat(audio.streams)
            : []
    }

    function label(n) {
        if (!n) return "—"
        if (n.isStream) {
            var p = n.properties || {}
            return p["application.name"] || n.description || n.name || "Audio"
        }
        return n.description || n.nickname || n.name || "Device"
    }

    // ===== A labelled volume row =====
    component Level: Item {
        required property var node
        required property string title
        required property color hue
        property bool dim: false
        width: audio.width - 24
        height: 40

        readonly property real vol: node && node.audio ? node.audio.volume : 0
        readonly property bool muted: node && node.audio ? node.audio.muted : false

        Text {
            id: name
            anchors.left: parent.left
            anchors.top: parent.top
            text: parent.title
            color: parent.dim ? audio.colors.textDim : audio.colors.textMain
            font.pixelSize: 12
            width: parent.width - 92
            elide: Text.ElideRight
        }
        Text {
            anchors.right: parent.right
            anchors.top: parent.top
            text: parent.muted ? "muted" : Math.round(Math.min(parent.vol, 1.5) * 100) + "%"
            color: parent.muted ? audio.colors.textDim : audio.colors.textMain
            font.pixelSize: 12
        }

        // Mute toggle doubles as the row's colour: an accent dot when live,
        // hollow when muted, so state reads without a label.
        Rectangle {
            id: muteDot
            anchors.right: parent.right
            anchors.rightMargin: 0
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 1
            width: 12; height: 12; radius: 6
            color: parent.muted ? "transparent" : parent.hue
            border.width: parent.muted ? 1 : 0
            border.color: audio.colors.textDim
            MouseArea {
                anchors.fill: parent
                anchors.margins: -6
                cursorShape: Qt.PointingHandCursor
                onClicked: if (node && node.audio) node.audio.muted = !node.audio.muted
            }
        }

        // Track + fill + drag.
        Rectangle {
            id: track
            anchors.left: parent.left
            anchors.right: muteDot.left
            anchors.rightMargin: 12
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 3
            height: 6
            radius: 3
            color: Qt.rgba(audio.colors.textMain.r, audio.colors.textMain.g,
                           audio.colors.textMain.b, 0.12)

            Rectangle {
                width: track.width * Math.max(0, Math.min(1, parent.parent.vol / 1.5))
                height: parent.height
                radius: parent.radius
                color: parent.parent.muted
                    ? Qt.rgba(audio.colors.textMain.r, audio.colors.textMain.g,
                              audio.colors.textMain.b, 0.25)
                    : parent.parent.hue
            }
            // The 100% mark, because Pipewire allows 150% and overdriving by
            // accident is unpleasant.
            Rectangle {
                x: track.width * (1 / 1.5)
                width: 1; height: parent.height
                color: Qt.rgba(audio.colors.textMain.r, audio.colors.textMain.g,
                               audio.colors.textMain.b, 0.30)
            }

            MouseArea {
                anchors.fill: parent
                anchors.topMargin: -10
                anchors.bottomMargin: -10
                cursorShape: Qt.PointingHandCursor
                function apply(mx) {
                    var n = track.parent.node
                    if (!n || !n.audio) return
                    n.audio.volume = Math.max(0, Math.min(1.5, (mx / track.width) * 1.5))
                }
                onPressed: mouse => apply(mouse.x)
                onPositionChanged: mouse => { if (pressed) apply(mouse.x) }
                onWheel: wheel => {
                    var n = track.parent.node
                    if (!n || !n.audio) return
                    n.audio.volume = Math.max(0, Math.min(1.5,
                        n.audio.volume + (wheel.angleDelta.y > 0 ? 0.02 : -0.02)))
                }
            }
        }
    }

    // ===== A device row you can click to make default =====
    component Device: Rectangle {
        required property var node
        required property bool isDefault
        required property bool forInput
        width: audio.width - 24
        height: 28
        radius: 7
        color: devMa.containsMouse
            ? Qt.rgba(audio.colors.textMain.r, audio.colors.textMain.g,
                      audio.colors.textMain.b, 0.07)
            : "transparent"

        Rectangle {
            id: marker
            anchors.left: parent.left
            anchors.leftMargin: 8
            anchors.verticalCenter: parent.verticalCenter
            width: 6; height: 6; radius: 3
            color: parent.isDefault ? audio.colors.primary : "transparent"
            border.width: parent.isDefault ? 0 : 1
            border.color: Qt.rgba(audio.colors.textMain.r, audio.colors.textMain.g,
                                  audio.colors.textMain.b, 0.25)
        }
        Text {
            anchors.left: marker.right
            anchors.leftMargin: 10
            anchors.right: parent.right
            anchors.rightMargin: 8
            anchors.verticalCenter: parent.verticalCenter
            text: audio.label(parent.node)
            color: parent.isDefault ? audio.colors.textMain : audio.colors.textDim
            font.pixelSize: 11
            elide: Text.ElideRight
        }
        MouseArea {
            id: devMa
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: {
                if (parent.forInput) Pipewire.preferredDefaultAudioSource = parent.node
                else Pipewire.preferredDefaultAudioSink = parent.node
            }
        }
    }

    component Heading: Text {
        color: audio.colors.textDim
        font.pixelSize: 11
        font.bold: true
    }

    component Rule: Rectangle {
        width: audio.width - 24
        height: 1
        color: Qt.rgba(audio.colors.textMain.r, audio.colors.textMain.g,
                       audio.colors.textMain.b, 0.09)
    }

    // ===================== OUTPUT =====================
    Heading { text: "OUTPUT" }
    Level {
        node: audio.sink
        title: audio.label(audio.sink)
        hue: audio.colors.primary
    }
    Column {
        spacing: 1
        Repeater {
            model: audio.sinks
            delegate: Device {
                required property var modelData
                node: modelData
                isDefault: audio.sink && modelData.id === audio.sink.id
                forInput: false
            }
        }
    }

    Rule {}

    // ===================== INPUT =====================
    Heading { text: "INPUT" }
    Level {
        node: audio.source
        title: audio.label(audio.source)
        hue: audio.colors.tertiary
    }
    Column {
        spacing: 1
        Repeater {
            model: audio.sources
            delegate: Device {
                required property var modelData
                node: modelData
                isDefault: audio.source && modelData.id === audio.source.id
                forInput: true
            }
        }
    }

    // ===================== PER-APP =====================
    // Only drawn when something is actually playing, so the panel does not
    // carry an empty heading most of the time.
    Rule { visible: audio.streams.length > 0 }
    Heading { text: "PLAYING"; visible: audio.streams.length > 0 }
    Column {
        spacing: 6
        visible: audio.streams.length > 0
        Repeater {
            model: audio.streams
            delegate: Level {
                required property var modelData
                node: modelData
                title: audio.label(modelData)
                hue: audio.colors.secondary
                dim: true
            }
        }
    }
}
