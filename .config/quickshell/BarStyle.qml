pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

// Global bar geometry — where the bar sits and what shape its ground is.
//
// There was a second axis here, `style`, picking how an individual widget was
// drawn (flat / underline / filled). It was a leftover from the version where
// widgets carried per-widget matugen fills and those genuinely differed. Once
// colour moved to the icons, every style rendered identically unless a widget
// was `active` — which almost never happens — so switching it did nothing. A
// control that does nothing is worse than no control.
//
// It persists to ~/.config/quickshell/bar.json through FileView's JsonAdapter,
// which replaces the old `cat`/`printf` Process pair against bar-style.txt —
// no subprocess per read or write, and an external edit to the file is picked
// up live by watchChanges.
Singleton {
    id: root

    // --- Bar geometry ----------------------------------------------------
    readonly property var geometries: [
        { id: "edge",    label: "Full width" }, // flush, square, no wasted gap
        { id: "capsule", label: "Capsule" },    // one inset rounded bar
        { id: "islands", label: "Islands" }     // three detached groups
    ]

    readonly property string geometry: cfg.adapter ? cfg.adapter.geometry : "edge"

    function _valid(list, id) {
        for (var i = 0; i < list.length; i++)
            if (list[i].id === id) return true
        return false
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
            property string geometry: "edge"
        }
    }
}
