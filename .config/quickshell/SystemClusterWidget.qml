import QtQuick

import "."

// One bar entry standing for the whole machine-status group, rather than five
// separate pills. Throughput is the label because it is the reading that
// actually changes moment to moment; the dot is a summary of everything behind
// it, so the cluster can report without being read.
BarPill {
    id: cluster
    pillIndex: 2

    signal panelToggleRequested()

    readonly property int pendingUpdates: SystemServices.repoUpdates + SystemServices.aurUpdates
    readonly property bool vpnUp: SystemServices.vpnStatus
        && SystemServices.vpnStatus !== "off" && SystemServices.vpnStatus !== "—"
    readonly property bool diskFull: SystemServices.diskPercent >= 90

    icon: ""
    label: SystemServices.netSpeed && SystemServices.netSpeed !== "—"
        ? SystemServices.formatSpeed(Math.max(SystemServices.rxRate, SystemServices.txRate))
        : "—"
    // Only shouts when the disk is nearly full; updates and VPN get the dot.
    active: diskFull
    activeColor: colors.urgent
    activeTextColor: colors.textOnUrgent

    onClicked: mouse => cluster.panelToggleRequested()

    // Summary dot, trailing the label. It sits in BarPill's content Row (that
    // is what `default property alias extraContent` feeds), so it is laid out
    // inline — a Row rejects left/right/fill/centerIn anchors outright.
    // Absent when there is nothing to report, and the pill narrows to match.
    Rectangle {
        visible: cluster.pendingUpdates > 0 || cluster.vpnUp
        width: visible ? 6 : 0
        height: 6
        radius: 3
        anchors.verticalCenter: parent.verticalCenter
        color: cluster.pendingUpdates > 0 ? cluster.colors.primary : cluster.colors.tertiary
    }
}
