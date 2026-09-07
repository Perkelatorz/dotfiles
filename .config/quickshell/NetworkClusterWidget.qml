import QtQuick

import "."

// The radios, as one bar entry. Same rule as the other clusters: one live
// reading (the network you are on), a dot when Bluetooth is also up, and the
// detail on click.
BarPill {
    id: netCluster
    pillIndex: 1

    signal panelToggleRequested()

    readonly property bool wifiOn: SystemServices.wifiEnabled
    readonly property string ssid: SystemServices.wifiStatus || ""
    readonly property bool btOn: SystemServices.btPowered
    readonly property bool offline: !wifiOn || ssid === "" || ssid === "off"
        || ssid === "—" || ssid.toLowerCase().indexOf("disconnect") >= 0

    icon: offline ? "" : ""
    // The SSID is the reading worth carrying; it is trimmed because a long one
    // would push the whole right-hand run around.
    label: offline ? "off" : (ssid.length > 12 ? ssid.substring(0, 11) + "…" : ssid)

    // Offline is the state worth flagging — everything else is business as usual.
    active: offline
    activeColor: colors.urgent
    activeTextColor: colors.textOnUrgent

    onClicked: mouse => netCluster.panelToggleRequested()

    Rectangle {
        visible: netCluster.btOn
        width: visible ? 6 : 0
        height: 6
        radius: 3
        anchors.verticalCenter: parent.verticalCenter
        color: netCluster.colors.tertiary
    }
}
