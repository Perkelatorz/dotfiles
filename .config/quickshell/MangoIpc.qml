pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

// Single source of truth for mango compositor state.
//
// mango ships `mmsg`, whose `watch` mode holds a socket open and pushes one
// unformatted JSON object per line — an initial snapshot on subscribe, then a
// fresh one on every change. Two long-lived subscriptions replace the polled
// `hyprctl clients -j` / `hyprctl activewindow -j` pair used on Hyprland, and
// living in a singleton means one pair total rather than one per monitor.
//
// Inert (processes never start) unless mango is actually the running compositor.
Singleton {
    id: root

    readonly property bool active: (Quickshell.env("XDG_CURRENT_DESKTOP") || "").toLowerCase().indexOf("mango") >= 0

    // Raw payloads from the two streams.
    property var monitors: []
    property var clients: []

    // Names of outputs showing a genuinely fullscreen window, for bar hiding.
    // mango separates is_fullscreen (covers the bar) from is_maximized (does
    // not), so unlike Hyprland's numeric mode there's nothing to decode.
    readonly property var fullscreenMonitorNames: {
        var names = []
        for (var i = 0; i < root.clients.length; i++) {
            var c = root.clients[i]
            if (c.is_fullscreen && c.is_visible && c.monitor && names.indexOf(c.monitor) < 0)
                names.push(String(c.monitor))
        }
        return names
    }

    function monitorFor(name) {
        if (!name) return null
        for (var i = 0; i < root.monitors.length; i++) {
            if (String(root.monitors[i].name) === String(name))
                return root.monitors[i]
        }
        return null
    }

    // Windows worth showing in the bar for one output: skip minimized and
    // scratchpad clients the way `hyprctl clients` skips special workspaces.
    function clientsOn(monitorName) {
        var out = []
        if (!monitorName) return out
        for (var i = 0; i < root.clients.length; i++) {
            var c = root.clients[i]
            if (String(c.monitor) !== String(monitorName)) continue
            if (c.is_minimized || c.is_scratchpad) continue
            out.push(c)
        }
        return out
    }

    // { tagIndex: [ {address,title,class}, ... ] }. A client pinned to several
    // tags (toggleglobal) is listed under each of them.
    function clientsByTag(monitorName) {
        var by = {}
        var list = clientsOn(monitorName)
        for (var i = 0; i < list.length; i++) {
            var c = list[i]
            var entry = { address: String(c.id), title: c.title || "", class: c.appid || "" }
            var tags = Array.isArray(c.tags) ? c.tags : []
            for (var t = 0; t < tags.length; t++) {
                var k = tags[t]
                if (!by[k]) by[k] = []
                by[k].push(entry)
            }
        }
        return by
    }

    function occupiedTags(monitorName) {
        var occ = {}
        var by = clientsByTag(monitorName)
        for (var k in by) occ[k] = true
        return occ
    }

    // Windows on the tag(s) this output is currently viewing.
    function visibleClientsOn(monitorName) {
        var out = []
        var mon = monitorFor(monitorName)
        if (!mon) return out
        var activeTags = Array.isArray(mon.active_tags) ? mon.active_tags : []
        // active_tags is [0] while the overview is open — show everything then.
        var showAll = activeTags.indexOf(0) >= 0
        var list = clientsOn(monitorName)
        for (var i = 0; i < list.length; i++) {
            var c = list[i]
            var tags = Array.isArray(c.tags) ? c.tags : []
            var onView = showAll
            for (var t = 0; !onView && t < tags.length; t++)
                if (activeTags.indexOf(tags[t]) >= 0) onView = true
            if (onView)
                out.push({ address: String(c.id), title: c.title || "", class: c.appid || "" })
        }
        return out
    }

    // Id of the focused window on an output, as a string, to match the
    // `activeWindowAddress` contract ClientList already uses.
    function activeClientId(monitorName) {
        var mon = monitorFor(monitorName)
        if (!mon || !mon.active_client || mon.active_client.id === null || mon.active_client.id === undefined)
            return ""
        return String(mon.active_client.id)
    }

    // --- Dispatch ---------------------------------------------------------
    // Serialised through one Process: two dispatches fired in the same tick
    // (focus the monitor, then switch its tag) would otherwise clobber each
    // other's command before the first ever ran.
    property var _queue: []

    Process {
        id: dispatchProc
        running: false
        onExited: root._pump()
    }

    function _pump() {
        if (dispatchProc.running || root._queue.length === 0) return
        var q = root._queue.slice()
        var next = q.shift()
        root._queue = q
        dispatchProc.command = next
        dispatchProc.running = true
    }

    // dispatch("view,3,0")  ->  mmsg dispatch view,3,0
    // dispatch("focusid", "client,375")  ->  mmsg dispatch focusid client,375
    function dispatch() {
        var args = ["mmsg", "dispatch"]
        for (var i = 0; i < arguments.length; i++) args.push(String(arguments[i]))
        root._queue = root._queue.concat([args])
        root._pump()
    }

    // --- Subscriptions ----------------------------------------------------
    Process {
        id: monitorWatch
        command: ["mmsg", "watch", "all-monitors"]
        running: root.active
        stdout: SplitParser {
            onRead: line => {
                try {
                    var o = JSON.parse(line)
                    if (o && Array.isArray(o.monitors)) root.monitors = o.monitors
                } catch (_) { }
            }
        }
    }

    Process {
        id: clientWatch
        command: ["mmsg", "watch", "all-clients"]
        running: root.active
        stdout: SplitParser {
            onRead: line => {
                try {
                    var o = JSON.parse(line)
                    if (o && Array.isArray(o.clients)) root.clients = o.clients
                } catch (_) { }
            }
        }
    }
}
