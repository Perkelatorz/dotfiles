import QtQuick
import Quickshell.Io

import "."

// Toggles hypridle. Active hypridle = system idles normally; stopped = stays
// awake (video calls / long downloads). The stay-awake state lights the pill
// with the urgent color — you want to notice you've left it on.
BarPill {
    id: idleWidget

    property bool inhibited: false  // true = idle disabled, stay awake

    // F0F4 = coffee (stay-awake), F236 = bed (idle-allowed)
    icon: inhibited ? "\uF0F4" : "\uF236"
    active: inhibited
    activeColor: colors.urgent
    activeTextColor: colors.textOnUrgent

    PollingProcess {
        id: statePoll
        command: ["sh", "-c", "systemctl --user is-active hypridle 2>/dev/null"]
        interval: 10000
        active: idleWidget.visible
        onOutput: (text) => {
            // "active" = hypridle running = idle works normally (NOT inhibited).
            idleWidget.inhibited = ((text || "").trim() !== "active")
        }
    }
    Process {
        id: toggleProc
        running: false
        onRunningChanged: if (!running) statePoll.refresh()
    }

    onClicked: {
        toggleProc.command = idleWidget.inhibited
            ? ["systemctl", "--user", "start", "hypridle"]
            : ["systemctl", "--user", "stop", "hypridle"]
        toggleProc.running = true
    }
}
