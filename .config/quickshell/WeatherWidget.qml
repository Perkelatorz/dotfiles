import QtQuick
import Quickshell.Io

import "."

BarPill {
    id: weatherWidget

    signal openForecastRequested()

    readonly property bool hasData: SystemServices.weatherHasData

    // Icon mapping lives in SystemServices (single source — the forecast panel
    // uses the same one, so bar and popup can no longer disagree).
    icon: SystemServices.weatherIcon
    label: SystemServices.weatherTemp || "--"
    present: hasData

    Process {
        id: openBrowser
        command: ["xdg-open", SystemServices.weatherLocation ? ("https://wttr.in/" + encodeURIComponent(SystemServices.weatherLocation)) : "https://wttr.in"]
        running: false
    }

    onClicked: mouse => {
        if (mouse.button === Qt.MiddleButton) openBrowser.running = true
        else weatherWidget.openForecastRequested()
    }
}
