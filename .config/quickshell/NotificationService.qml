pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Services.Notifications

// Our own notification server, replacing swaync.
//
// swaync was a second daemon drawing its own windows in its own style with its
// own config — nothing in this shell could see a notification, so the bar's
// counter was guesswork and the popups never matched anything else on screen.
// Quickshell speaks the freedesktop protocol directly, so the shell IS the
// server: one style, one source of truth, and notifications become data the
// rest of the config can read.
//
// Only one process may own org.freedesktop.Notifications. swaync has to be out
// of the mango autostart for this to bind.
Singleton {
    id: root

    property bool dnd: false

    // Everything that has arrived and not been dismissed.
    readonly property var history: server.trackedNotifications

    // The subset currently on screen as a toast: { n, expires }.
    property var toasts: []

    readonly property int count: history ? history.values.length : 0
    readonly property bool hasAny: count > 0

    // Default dwell when a client does not ask for one. Critical notifications
    // are deliberately excluded from auto-expiry below.
    property int defaultTimeoutMs: 5000

    NotificationServer {
        id: server
        keepOnReload: true
        bodySupported: true
        bodyMarkupSupported: true
        actionsSupported: true
        actionIconsSupported: true
        imageSupported: true

        onNotification: n => {
            // Without this the object is destroyed as soon as the signal
            // returns — tracking is what makes a history possible at all.
            n.tracked = true

            if (root.dnd && n.urgency !== NotificationUrgency.Critical) return

            var ms = n.expireTimeout > 0 ? n.expireTimeout : root.defaultTimeoutMs
            // Critical stays until it is acknowledged; that is the whole point
            // of the urgency, and a five-second toast throws it away.
            var expires = n.urgency === NotificationUrgency.Critical
                ? -1 : Date.now() + ms
            root.toasts = root.toasts.concat([{ n: n, expires: expires }])
        }
    }

    Timer {
        interval: 500
        running: root.toasts.length > 0
        repeat: true
        onTriggered: {
            var now = Date.now()
            var keep = []
            for (var i = 0; i < root.toasts.length; i++) {
                var t = root.toasts[i]
                if (t.expires < 0 || t.expires > now) keep.push(t)
            }
            if (keep.length !== root.toasts.length) root.toasts = keep
        }
    }

    function dismissToast(n) {
        var keep = []
        for (var i = 0; i < toasts.length; i++)
            if (toasts[i].n !== n) keep.push(toasts[i])
        toasts = keep
    }

    // Dismissing from a toast should not also delete the history entry — the
    // point of a history is that you can go back to what you waved away.
    function close(n) {
        dismissToast(n)
        if (n) n.dismiss()
    }

    function clearToasts() { toasts = [] }

    function clearHistory() {
        var all = history ? history.values.slice() : []
        for (var i = 0; i < all.length; i++) all[i].dismiss()
        toasts = []
    }

    function toggleDnd() { dnd = !dnd }
}
