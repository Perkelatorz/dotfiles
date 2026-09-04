import QtQuick
import Quickshell.Services.Pipewire

import "."

BarPill {
    id: micWidget
    pillIndex: 0

    property var source: Pipewire.defaultAudioSource
    PwObjectTracker {
        objects: micWidget.source ? [micWidget.source] : []
    }

    property bool muted: source && source.audio ? source.audio.muted : false
    readonly property int levelPct: source && source.audio ? Math.round(source.audio.volume * 100) : 0

    icon: muted ? "\uF131" : "\uF130"
    label: muted ? "Muted" : (levelPct + "%")
    // Muted mic is the state worth noticing.
    // Conditional tier: an unmuted mic is the normal case and says nothing, so
    // the widget collapses to zero width. `present` (not `visible`) because the
    // user's toggle in settings drives `visible` independently.
    present: muted
    active: muted

    // Direct Pipewire mute toggle — no wpctl process, no stale-state race.
    onClicked: if (source && source.audio) source.audio.muted = !source.audio.muted
}
