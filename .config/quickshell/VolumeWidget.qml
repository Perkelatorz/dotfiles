import QtQuick
import Quickshell.Io
import Quickshell.Services.Pipewire

import "."

BarPill {
    id: volumeWidget
    pillIndex: 7

    // Volume control app on right-click ("pulsemixer"/"ncpamixer" work too).
    property string volumeControlCommand: "pavucontrol"

    property var sink: Pipewire.defaultAudioSink
    PwObjectTracker {
        objects: volumeWidget.sink ? [volumeWidget.sink] : []
    }
    property real volume: sink && sink.audio ? sink.audio.volume : 0
    property bool muted: sink && sink.audio ? sink.audio.muted : false

    icon: muted ? "\uF6A9" : "\uF028"
    label: {
        if (!sink) return "--"
        if (muted) return "M"
        // Pipewire volume is 0.0–1.5; always scale, clamp at 150%.
        return Math.round(Math.min(volume, 1.5) * 100) + "%"
    }
    // Muted output deserves the accent.
    active: muted

    Process {
        id: runVolumeControl
        command: volumeWidget.volumeControlCommand.trim().split(/\s+/)
        running: false
    }

    onClicked: mouse => {
        if (mouse.button === Qt.RightButton) runVolumeControl.running = true
        else if (mouse.button === Qt.MiddleButton && sink && sink.audio)
            sink.audio.muted = !sink.audio.muted
    }
    // Direct Pipewire adjustment — no wpctl process per scroll tick.
    onWheelMoved: wheel => {
        if (!sink || !sink.audio) return
        var delta = wheel.angleDelta.y > 0 ? 0.02 : -0.02
        sink.audio.volume = Math.max(0, Math.min(1.5, sink.audio.volume + delta))
    }
}
