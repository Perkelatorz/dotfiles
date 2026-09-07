import QtQuick

import "."

// Wi-Fi and Bluetooth in one popout, reached from one bar entry.
//
// They were two cards in QuickSettings that each opened a subview of a panel
// that also held audio, disk, printers and power. Radios are one job; this is
// the panel for it. WifiContent and BluetoothContent are unchanged — they were
// always the real UI, just buried two clicks down.
Item {
    id: net
    required property var colors
    property var onClose: null
    property bool panelOpen: false

    property string tab: "wifi"

    implicitWidth: 340
    implicitHeight: 430

    Column {
        anchors.fill: parent
        anchors.margins: 14
        spacing: 12

        // Segmented switch. Two options, so a pair of chips beats a dropdown.
        Row {
            spacing: 6
            Repeater {
                model: [
                    { id: "wifi", label: "Wi-Fi" },
                    { id: "bluetooth", label: "Bluetooth" }
                ]
                delegate: Rectangle {
                    required property var modelData
                    readonly property bool sel: net.tab === modelData.id
                    width: (net.width - 28 - 6) / 2
                    height: 30
                    radius: 9
                    color: sel
                        ? Qt.rgba(net.colors.primary.r, net.colors.primary.g,
                                  net.colors.primary.b, 0.18)
                        : (tabMa.containsMouse ? net.colors.surfaceBright
                                               : net.colors.surfaceContainer)
                    border.width: 1
                    border.color: sel
                        ? Qt.rgba(net.colors.primary.r, net.colors.primary.g,
                                  net.colors.primary.b, 0.45)
                        : Qt.rgba(net.colors.textMain.r, net.colors.textMain.g,
                                  net.colors.textMain.b, 0.10)
                    Behavior on color { ColorAnimation { duration: 110 } }
                    Text {
                        anchors.centerIn: parent
                        text: modelData.label
                        color: parent.sel ? net.colors.primary : net.colors.textDim
                        font.pixelSize: 12
                        font.bold: parent.sel
                    }
                    MouseArea {
                        id: tabMa
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: net.tab = modelData.id
                    }
                }
            }
        }

        Item {
            width: parent.width
            height: parent.height - 42

            WifiContent {
                anchors.fill: parent
                colors: net.colors
                visible: net.tab === "wifi"
                // Only the visible tab scans/polls.
                panelOpen: net.panelOpen && net.tab === "wifi"
            }
            BluetoothContent {
                anchors.fill: parent
                colors: net.colors
                visible: net.tab === "bluetooth"
                panelOpen: net.panelOpen && net.tab === "bluetooth"
            }
        }
    }
}
