import QtQuick
import Quickshell.Io

import "."

BarPill {
    id: updateWidget

    readonly property int totalCount: SystemServices.repoUpdates + SystemServices.aurUpdates
    readonly property bool hasUpdates: totalCount > 0

    // Pending updates are a meaningful state — this pill earns the accent.
    active: hasUpdates
    icon: ""
    label: String(totalCount)
    present: hasUpdates

    Process {
        id: runUpdate
        command: ["kitty", "-e", "paru"]
        running: false
    }
    onClicked: runUpdate.running = true
}
