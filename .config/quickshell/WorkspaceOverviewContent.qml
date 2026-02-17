import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland

import "."

ColumnLayout {
    id: overviewRoot
    required property var colors
    required property var hyprMonitor
    required property var clientsByWorkspace
    required property var onClose
    property string activeWindowAddress: ""

    spacing: 12
    Layout.fillWidth: true

    RowLayout {
        Layout.fillWidth: true
        spacing: 8
        Text {
            text: "Workspaces"
            color: colors.textMain
            font.pixelSize: 14
            font.bold: true
        }
        Item { Layout.fillWidth: true }
        MouseArea {
            id: closeMa
            width: 28
            height: 28
            hoverEnabled: true
            onClicked: overviewRoot.onClose()
            Rectangle {
                anchors.fill: parent
                radius: 4
                color: closeMa.containsMouse ? colors.surfaceBright : "transparent"
            }
            Text {
                anchors.centerIn: parent
                text: "\uF00D"
                color: colors.textMain
                font.pixelSize: 12
                font.family: colors.widgetIconFont
            }
        }
    }

    Rectangle {
        Layout.fillWidth: true
        height: 1
        color: colors.borderSubtle
    }

    Repeater {
        model: Hyprland.workspaces
        delegate: Item {
            readonly property var workspace: modelData
            readonly property bool onThisMonitor: workspace.monitor === overviewRoot.hyprMonitor
            readonly property var wsClients: {
                if (!onThisMonitor) return []
                var by = overviewRoot.clientsByWorkspace
                if (!by) return []
                var list = by[workspace.id] || by[workspace.name] || by[String(workspace.id)] || by[String(workspace.name)] || []
                return Array.isArray(list) ? list : []
            }
            readonly property bool isActive: overviewRoot.hyprMonitor && overviewRoot.hyprMonitor.activeWorkspace && (
                overviewRoot.hyprMonitor.activeWorkspace.id === workspace.id ||
                overviewRoot.hyprMonitor.activeWorkspace.name === workspace.name
            )
            readonly property string wsNumber: workspace.name || (workspace.id != null ? String(workspace.id) : "?")

            visible: onThisMonitor
            Layout.fillWidth: true
            readonly property int clientRowsHeight: wsClients.length * 32 + Math.max(0, wsClients.length - 1) * 2
            height: visible ? (36 + 8 + clientRowsHeight) : 0

            Column {
                id: wsColumn
                width: parent.width - 4
                spacing: 6
                anchors.left: parent.left
                anchors.top: parent.top

                MouseArea {
                    id: wsHeader
                    width: parent.width - 4
                    height: 36
                    onClicked: {
                        if (overviewRoot.hyprMonitor) {
                            Hyprland.dispatch("focusmonitor " + overviewRoot.hyprMonitor.name)
                            workspace.activate()
                        }
                        overviewRoot.onClose()
                    }
                    Rectangle {
                        anchors.fill: parent
                        radius: 8
                        color: isActive ? colors.primary : (wsHeader.containsMouse ? colors.surfaceBright : colors.surfaceContainer)
                        border.width: 1
                        border.color: isActive ? colors.primary : colors.borderSubtle
                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 12
                            anchors.rightMargin: 12
                            spacing: 8
                            Text {
                                text: "Workspace " + wsNumber
                                color: isActive ? colors.textOnPrimary : colors.textMain
                                font.pixelSize: 12
                                font.bold: true
                            }
                            Text {
                                visible: wsClients.length > 0
                                text: wsClients.length + (wsClients.length === 1 ? " window" : " windows")
                                color: isActive ? colors.textOnPrimary : colors.textDim
                                font.pixelSize: 11
                                Layout.fillWidth: true
                            }
                        }
                    }
                }

                Column {
                    id: wsClientsList
                    width: parent.width - 4
                    leftPadding: 12
                    spacing: 2
                    Repeater {
                        model: wsClients
                        delegate: MouseArea {
                            id: winMa
                            width: wsClientsList.width - 12
                            height: 32
                            hoverEnabled: true
                            readonly property string iconPath: modelData.class ? Quickshell.iconPath(String(modelData.class).toLowerCase(), true) : ""
                            readonly property bool isFocused: modelData.address && String(modelData.address) === overviewRoot.activeWindowAddress
                            onClicked: {
                                if (modelData.address) {
                                    Hyprland.dispatch("focuswindow address:" + modelData.address)
                                    overviewRoot.onClose()
                                }
                            }
                            Rectangle {
                                anchors.fill: parent
                                radius: 6
                                color: isFocused ? colors.primary : (winMa.containsMouse ? colors.surfaceBright : "transparent")
                                border.width: isFocused ? 0 : 1
                                border.color: colors.borderSubtle
                                Row {
                                    width: parent.width - 20
                                    anchors.centerIn: parent
                                    spacing: 10
                                    Image {
                                        width: 18
                                        height: 18
                                        anchors.verticalCenter: parent.verticalCenter
                                        source: iconPath
                                        sourceSize.width: 18
                                        sourceSize.height: 18
                                        visible: source !== "" && status === Image.Ready
                                        smooth: true
                                        mipmap: true
                                    }
                                    Rectangle {
                                        width: 18
                                        height: 18
                                        radius: 4
                                        anchors.verticalCenter: parent.verticalCenter
                                        color: colors.surfaceBright
                                        border.width: 1
                                        border.color: colors.border
                                        visible: iconPath === ""
                                        Text {
                                            anchors.centerIn: parent
                                            text: (modelData.class || modelData.title || "?").toString().trim().charAt(0).toUpperCase() || "?"
                                            color: colors.textDim
                                            font.pixelSize: 10
                                            font.bold: true
                                        }
                                    }
                                    Text {
                                        width: parent.width - 56
                                        anchors.verticalCenter: parent.verticalCenter
                                        text: (modelData.title || modelData.class || "?").toString().trim()
                                        elide: Text.ElideRight
                                        color: isFocused ? colors.textOnPrimary : (winMa.containsMouse ? colors.textMain : colors.textDim)
                                        font.pixelSize: 11
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
