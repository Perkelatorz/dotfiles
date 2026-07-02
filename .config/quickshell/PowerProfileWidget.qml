import QtQuick

import "."

// Bound to SystemServices' event-driven PowerProfiles — no poller here, and
// the bar pill and QuickSettings card can't disagree.
BarPill {
    id: powerWidget

    readonly property string profile: SystemServices.powerProfile.toLowerCase()
    readonly property var profileLabels: ({ "balanced": "Bal", "performance": "Perf", "power-saver": "Save" })
    readonly property var profileIcons: ({ "balanced": "", "performance": "", "power-saver": "" })

    icon: profileIcons[profile] || ""
    label: profileLabels[profile] || "Bal"
    // Performance mode is worth noticing (fans, power draw).
    active: profile === "performance"

    onClicked: SystemServices.cyclePowerProfile()
}
