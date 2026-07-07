import QtQuick
import Quickshell.Bluetooth

import "."

// Bluetooth control-center subview: power toggle + a live device list (native
// Quickshell.Bluetooth service, no polling). Click a device to connect or
// disconnect. Scanning runs only while this panel is open and BT is on.
Item {
    id: bt
    required property var colors
    property bool panelOpen: false

    readonly property var adapter: Bluetooth.defaultAdapter
    readonly property bool powered: adapter !== null && adapter.enabled
    readonly property var devices: powered ? Bluetooth.devices.values : []

    onPanelOpenChanged: _syncScan()
    onPoweredChanged: _syncScan()
    function _syncScan() {
        if (adapter) adapter.discovering = (panelOpen && powered)
    }

    Column {
        anchors.fill: parent
        anchors.margins: 8
        spacing: 8

        // Power toggle
        Rectangle {
            width: parent.width
            height: 40
            radius: 10
            color: bt.powered ? bt.colors.primaryContainer : bt.colors.surfaceBright
            border.width: 1
            border.color: bt.powered ? bt.colors.primary : bt.colors.borderSubtle
            Text {
                id: btPowerIcon
                anchors.left: parent.left
                anchors.leftMargin: 12
                anchors.verticalCenter: parent.verticalCenter
                text: "\uF293"
                font.family: bt.colors.widgetIconFont
                font.pixelSize: 16
                color: bt.powered ? bt.colors.textOnPrimaryContainer : bt.colors.primary
            }
            Text {
                anchors.left: btPowerIcon.right
                anchors.leftMargin: 12
                anchors.verticalCenter: parent.verticalCenter
                text: bt.adapter ? (bt.powered ? (bt.adapter.discovering ? "On · scanning…" : "On") : "Off") : "No adapter"
                color: bt.powered ? bt.colors.textOnPrimaryContainer : bt.colors.textMain
                font.pixelSize: bt.colors.clockFontSize
            }
            Text {
                anchors.right: parent.right
                anchors.rightMargin: 12
                anchors.verticalCenter: parent.verticalCenter
                text: bt.powered ? "ON" : "OFF"
                color: bt.powered ? bt.colors.textOnPrimaryContainer : bt.colors.textDim
                font.pixelSize: bt.colors.clockFontSize - 1
                font.bold: true
            }
            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                enabled: bt.adapter !== null
                onClicked: bt.adapter.enabled = !bt.adapter.enabled
            }
        }

        Item {
            width: parent.width
            height: parent.height - 40 - 8

            Text {
                anchors.top: parent.top
                width: parent.width
                visible: !bt.powered
                text: "Turn on Bluetooth to see devices."
                color: bt.colors.textDim
                font.pixelSize: bt.colors.clockFontSize
            }
            Text {
                anchors.top: parent.top
                width: parent.width
                visible: bt.powered && bt.devices.length === 0
                text: "Searching for devices…"
                color: bt.colors.textDim
                font.pixelSize: bt.colors.clockFontSize
            }

            ListView {
                id: devList
                anchors.fill: parent
                clip: true
                spacing: 4
                visible: bt.powered && bt.devices.length > 0
                model: bt.devices
                delegate: Rectangle {
                    width: devList.width
                    height: 46
                    radius: 8
                    color: devMa.containsMouse ? bt.colors.surfaceBright : "transparent"
                    Column {
                        anchors.left: parent.left
                        anchors.leftMargin: 12
                        anchors.right: connDot.left
                        anchors.rightMargin: 8
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 2
                        Text {
                            text: modelData.name || modelData.address
                            color: bt.colors.textMain
                            font.pixelSize: bt.colors.clockFontSize
                            elide: Text.ElideRight
                            width: parent.width
                        }
                        Text {
                            text: {
                                var s = modelData.connected ? "Connected" : (modelData.paired ? "Paired" : "")
                                if (modelData.connected && modelData.batteryAvailable)
                                    s += " · " + Math.round(modelData.battery * 100) + "%"
                                return s
                            }
                            visible: text !== ""
                            color: modelData.connected ? bt.colors.primary : bt.colors.textDim
                            font.pixelSize: bt.colors.clockFontSize - 2
                        }
                    }
                    Rectangle {
                        id: connDot
                        anchors.right: parent.right
                        anchors.rightMargin: 12
                        anchors.verticalCenter: parent.verticalCenter
                        width: 8
                        height: 8
                        radius: 4
                        color: modelData.connected ? "#3dd57e" : bt.colors.borderSubtle
                    }
                    MouseArea {
                        id: devMa
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            if (modelData.connected) modelData.disconnect()
                            else modelData.connect()
                        }
                    }
                }
            }
        }
    }
}
