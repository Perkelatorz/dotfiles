import QtQuick

import "."

// Current layout for this monitor's active tag.
//
// mango keeps layout per-tag AND per-monitor, so each bar reports its own
// output rather than a single global value. The symbol arrives on the
// all-monitors subscription (MangoIpc), so there's nothing to poll.
//
// Click cycles to the next layout in `circle_layout`.
BarPill {
    id: layoutWidget
    pillIndex: 2

    // This monitor's entry out of MangoIpc.monitors.
    property var mangoMonitor: null
    property string compositorName: "hyprland"

    // Hyprland exposes no equivalent through this data path, so the pill
    // collapses to zero width there instead of showing a stale value.
    present: compositorName === "mango" && mangoMonitor !== null

    readonly property string symbol: mangoMonitor && mangoMonitor.layout_symbol
        ? String(mangoMonitor.layout_symbol) : ""

    // Symbols come from src/layout/layout.h. Only the five in circle_layout are
    // reachable by cycling, but the rest are mapped so a setlayout bind or an
    // `mmsg dispatch` still reads correctly.
    readonly property var _names: ({
        "DW": "Dwindle",  "T":  "Tile",      "VT": "V-Tile",
        "M":  "Monocle",  "S":  "Scroller",  "VS": "V-Scroll",
        "G":  "Grid",     "VG": "V-Grid",    "K":  "Deck",
        "VK": "V-Deck",   "CT": "Center",    "RT": "Right",
        "F":  "Fair",     "VF": "V-Fair"
    })
    readonly property var _icons: ({
        "DW": "\uF009", "T":  "\uF0DB", "VT": "\uF0C9",
        "M":  "\uF2D0", "S":  "\uF07E", "VS": "\uF07E",
        "G":  "\uF00A", "VG": "\uF00A"
    })

    // Unmapped symbol (e.g. the overview glyph) falls through as-is rather than
    // silently showing the wrong layout.
    label: _names[symbol] !== undefined ? _names[symbol] : symbol
    icon: _icons[symbol] !== undefined ? _icons[symbol] : ""

    onClicked: {
        if (!layoutWidget.mangoMonitor) return
        // switch_layout acts on the focused monitor's current tag, so focus this
        // output first — otherwise clicking the pill on a background monitor
        // would silently retile a different screen. Same pattern as the
        // workspace pills.
        MangoIpc.dispatch("focusmon," + layoutWidget.mangoMonitor.name)
        MangoIpc.dispatch("switch_layout")
    }
}
