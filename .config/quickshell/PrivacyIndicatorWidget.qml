import QtQuick
import Quickshell.Io
import Quickshell.Services.Pipewire

import "."

// Appears ONLY while something is actually capturing: an app recording the
// mic (Pipewire audio-in stream), an app capturing the screen (Pipewire
// video stream — OBS/Discord/portal screenshare), or an active Sunshine
// session (kms capture bypasses Pipewire, so detected via its stream ports).
// No toggle needed — absent means nothing is watching or listening.
BarPill {
    id: privacyWidget

    readonly property bool micInUse: {
        var ns = Pipewire.nodes.values
        for (var i = 0; i < ns.length; i++) {
            var t = ns[i].type
            if ((t & PwNodeType.AudioInStream) === PwNodeType.AudioInStream) return true
        }
        return false
    }
    readonly property bool screenCaptured: {
        var ns = Pipewire.nodes.values
        for (var i = 0; i < ns.length; i++) {
            var t = ns[i].type
            if ((t & PwNodeType.Video) && (t & PwNodeType.Stream)) return true
        }
        return false
    }
    property bool sunshineActive: false

    present: micInUse || screenCaptured || sunshineActive
    active: true
    activeColor: colors.errorContainer
    activeTextColor: colors.textOnErrorContainer

    icon: (screenCaptured || sunshineActive) ? "\uF03D" : "\uF130"
    label: {
        var parts = []
        if (micInUse) parts.push("mic")
        if (screenCaptured) parts.push("screen")
        if (sunshineActive) parts.push("stream")
        return parts.join(" · ")
    }

    // Sunshine streams via kms/nvfbc (not Pipewire) — an established
    // connection on its video/control ports means someone is watching.
    PollingProcess {
        interval: 10000
        command: ["sh", "-c", "pgrep -x sunshine >/dev/null 2>&1 && ss -Htn state established '( sport = :47998 or sport = :47999 or sport = :48000 or sport = :48010 )' 2>/dev/null | grep -q . && echo yes || echo no"]
        onOutput: text => privacyWidget.sunshineActive = (text.trim() === "yes")
    }
}
