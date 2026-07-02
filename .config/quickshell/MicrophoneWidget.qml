import QtQuick
import Quickshell.Services.Pipewire

import "."

BarPill {
    id: micWidget

    property var source: Pipewire.defaultAudioSource
    PwObjectTracker {
        objects: micWidget.source ? [micWidget.source] : []
    }

    property bool muted: source && source.audio ? source.audio.muted : false
    readonly property int levelPct: source && source.audio ? Math.round(source.audio.volume * 100) : 0

    icon: muted ? "\uF131" : "\uF130"
    label: muted ? "Muted" : (levelPct + "%")
    // Muted mic is the state worth noticing.
    active: muted

    // Direct Pipewire mute toggle — no wpctl process, no stale-state race.
    onClicked: if (source && source.audio) source.audio.muted = !source.audio.muted
}
