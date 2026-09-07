import QtQuick

import "."

// The System popout: everything about the machine that is worth knowing but not
// worth a permanent seat in the bar.
//
// The grouped-cluster-that-expands idea comes from caelestia's `statusIcons`
// popout, but the contents deliberately do not: a generic Material shell puts
// network/bluetooth/audio here, all of which QuickSettings already owns. This
// holds the readouts SystemServices computes that had nowhere to live —
// throughput, disk, VPN, printers, updates.
Column {
    id: sys
    required property var colors
    property var onClose: null
    property bool panelOpen: false

    width: 320
    padding: 12
    spacing: 10

    // Material 3 elevation, using the palette instead of inventing greys:
    //   background      the panel ground (level 1, accent-tinted)
    //   surfaceContainer  a card resting on it (level 2)
    //   surfaceBright     that card under the pointer (level 3)
    // The washes this used before were rgba(textMain, 0.07) — readable, but
    // they threw away the surface family matugen generates from the wallpaper.
    component Card: Rectangle {
        color: sys.colors.surfaceContainer
        radius: 12
        border.width: 1
        border.color: Qt.rgba(sys.colors.textMain.r, sys.colors.textMain.g,
                              sys.colors.textMain.b, 0.07)
    }

    component Heading: Text {
        color: sys.colors.textDim
        font.pixelSize: 11
        font.bold: true
    }

    component Rule: Rectangle {
        width: sys.width - 24
        height: 1
        color: Qt.rgba(sys.colors.textMain.r, sys.colors.textMain.g, sys.colors.textMain.b, 0.09)
    }

    // label on the left, value on the right — the panel's basic unit
    component Row_: Item {
        required property string k
        required property string v
        property color tone: sys.colors.textMain
        height: 18
        Text {
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            text: parent.k
            color: sys.colors.textDim
            font.pixelSize: 11
        }
        Text {
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            text: parent.v
            color: parent.tone
            font.pixelSize: 11
            elide: Text.ElideRight
            width: parent.width - 110
            horizontalAlignment: Text.AlignRight
        }
    }

    // ===== NETWORK =====
    Heading { text: "NETWORK" }
    Card {
        width: sys.width - 24
        height: netCol.implicitHeight + 20
        Column {
            id: netCol
            x: 12; y: 10
            width: parent.width - 24
            spacing: 6
            Row_ {
                width: parent.width
                k: SystemServices.netIface || "interface"
                v: SystemServices.netSpeed
            }
    // Down and up as separate charts rather than two series in one box: they
    // share a percentage axis but nothing here needs comparing, and two lines
    // in 26px would need a legend to tell apart.
            Item {
                width: parent.width
                height: 24
                Sparkline {
                    anchors.fill: parent
                    colors: sys.colors
                    values: SystemServices.rxHistory
                    maxSamples: SystemServices.historyLength
                    lineColor: sys.colors.primary
                }
            }
            Item {
                width: parent.width
                height: 24
                Sparkline {
                    anchors.fill: parent
                    colors: sys.colors
                    values: SystemServices.txHistory
                    maxSamples: SystemServices.historyLength
                    lineColor: sys.colors.tertiary
                }
            }
            Row_ {
                width: parent.width
                k: "VPN"
                v: SystemServices.vpnStatus || "off"
                tone: (SystemServices.vpnStatus && SystemServices.vpnStatus !== "off")
                    ? sys.colors.primary : sys.colors.textDim
            }
        }
    }

    // ===== STORAGE =====
    Heading { text: "STORAGE" }
    Card {
        width: sys.width - 24
        height: diskCol.implicitHeight + 20
        Column {
            id: diskCol
            x: 12; y: 10
            width: parent.width - 24
            spacing: 8
            Row_ { width: parent.width; k: "Disk"; v: SystemServices.diskStatus || "—" }
            Rectangle {
                width: parent.width
                height: 4
                radius: 2
        color: Qt.rgba(sys.colors.textMain.r, sys.colors.textMain.g, sys.colors.textMain.b, 0.12)
        Rectangle {
            width: parent.width * Math.max(0, Math.min(1, SystemServices.diskPercent / 100))
            height: parent.height
            radius: parent.radius
            // Storage is the one reading where a high number is bad, so it is
            // allowed to go urgent rather than staying decorative.
            color: SystemServices.diskPercent >= 90 ? sys.colors.urgent : sys.colors.secondary
                    Behavior on width { NumberAnimation { duration: 250 } }
                }
            }
        }
    }

    // ===== MAINTENANCE =====
    Heading { text: "MAINTENANCE" }
    Card {
        width: sys.width - 24
        height: maintCol.implicitHeight + 20
        Column {
            id: maintCol
            x: 12; y: 10
            width: parent.width - 24
            spacing: 6
            Row_ {
                width: parent.width
                k: "Updates"
                v: SystemServices.updateStatus || "—"
                tone: (SystemServices.repoUpdates + SystemServices.aurUpdates) > 0
                    ? sys.colors.primary : sys.colors.textDim
            }
            Row_ {
                width: parent.width
                k: "Repo / AUR"
                v: SystemServices.repoUpdates + " / " + SystemServices.aurUpdates
            }
            Row_ {
                width: parent.width
                k: "Printers"
                v: SystemServices.printersStatus || "—"
                tone: sys.colors.textDim
            }
        }
    }
}
