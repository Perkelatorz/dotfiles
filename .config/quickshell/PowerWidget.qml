import QtQuick

import "."

// Session actions. This slot used to open QuickSettings — a 440px panel with
// audio, radios, disk, printers, power profile, weather, theme, a brightness
// slider and a widget-toggle page. Every one of those either moved to a panel
// that owns it fully, or stopped being needed once widgets learned to hide
// themselves. What was left worth keeping is the session menu.
BarPill {
    id: powerWidget
    pillIndex: 5

    signal menuToggleRequested()

    icon: ""
    label: ""

    onClicked: mouse => powerWidget.menuToggleRequested()
}
