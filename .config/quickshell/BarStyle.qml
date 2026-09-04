pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

// Global bar look, on two independent axes, shared by every BarPill and the
// settings picker.
//
//   geometry — where the bar sits and what shape its ground is
//   style    — how an individual widget is drawn on that ground
//
// They are orthogonal: three geometries x three styles, not one list of nine.
//
// Both persist to ~/.config/quickshell/bar.json through FileView's JsonAdapter,
// which replaces the old `cat`/`printf` Process pair against bar-style.txt —
// no subprocess per read or write, and an external edit to the file is picked
// up live by watchChanges.
Singleton {
    id: root

    // --- Widget styles ---------------------------------------------------
    // Every one of these has to read against the tinted near-black ground the
    // geometries paint. The old pill/blocks (per-widget matugen fill) and
    // glass/neon (frosted + glow, drawn for bare wallpaper) assumed no ground
    // at all and are gone with it: colour is an accent now, not a fill.
    readonly property var styles: [
        { id: "flat",      label: "Flat" },      // dim ink; accent only when it means something
        { id: "underline", label: "Underline" }, // + accent rule under active widgets
        { id: "filled",    label: "Filled" }     // + accent container behind active widgets
    ]

    // --- Bar geometry ----------------------------------------------------
    readonly property var geometries: [
        { id: "edge",    label: "Full width" }, // flush, square, no wasted gap
        { id: "capsule", label: "Capsule" },    // one inset rounded bar
        { id: "islands", label: "Islands" }     // three detached groups
    ]

    readonly property string style: cfg.adapter ? cfg.adapter.style : "flat"
    readonly property string geometry: cfg.adapter ? cfg.adapter.geometry : "edge"

    function _valid(list, id) {
        for (var i = 0; i < list.length; i++)
            if (list[i].id === id) return true
        return false
    }

    function setStyle(s) {
        if (!cfg.adapter || !_valid(styles, s) || s === style) return
        cfg.adapter.style = s
        cfg.writeAdapter()
    }

    function setGeometry(g) {
        if (!cfg.adapter || !_valid(geometries, g) || g === geometry) return
        cfg.adapter.geometry = g
        cfg.writeAdapter()
    }

    function _cycle(list, current, setter) {
        var i = 0
        for (var k = 0; k < list.length; k++)
            if (list[k].id === current) { i = k; break }
        setter(list[(i + 1) % list.length].id)
    }

    function cycle() { _cycle(styles, style, setStyle) }
    function cycleGeometry() { _cycle(geometries, geometry, setGeometry) }

    FileView {
        id: cfg
        path: (Quickshell.env("XDG_CONFIG_HOME") || (Quickshell.env("HOME") + "/.config"))
              + "/quickshell/bar.json"
        watchChanges: true
        onFileChanged: reload()
        // No onAdapterUpdated -> writeAdapter() here on purpose: that fires on
        // load too, so the file would be rewritten every time it is read. The
        // setters above write explicitly instead.
        JsonAdapter {
            property string style: "flat"
            property string geometry: "edge"
        }
    }
}
