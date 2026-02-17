import QtQuick
import Quickshell
import Quickshell.Hyprland

import "."

Row {
    id: workspaceRow
    required property var colors
    required property var hyprMonitor
    required property var occupiedWorkspaceIds
    property var clientsByWorkspace: ({})

    spacing: 6
    leftPadding: 8
    rightPadding: 8
    height: parent ? parent.height : 24

    readonly property int maxAppIndicators: 5
    readonly property int appIconSize: 18
    readonly property int slotPadding: 6

    Repeater {
        model: Hyprland.workspaces
        delegate: Item {
            readonly property var workspace: modelData
            readonly property bool onThisMonitor: workspace.monitor === workspaceRow.hyprMonitor
            readonly property bool isActive: workspaceRow.hyprMonitor && workspaceRow.hyprMonitor.activeWorkspace && (
                workspaceRow.hyprMonitor.activeWorkspace.id === workspace.id ||
                workspaceRow.hyprMonitor.activeWorkspace.name === workspace.name
            )
            readonly property bool isFocused: workspaceRow.hyprMonitor && workspaceRow.hyprMonitor.focused && isActive
            readonly property bool occupied: !!(workspaceRow.occupiedWorkspaceIds[workspace.id] || workspaceRow.occupiedWorkspaceIds[String(workspace.name)])
            readonly property bool hasUrgent: !!workspace.urgent
            readonly property var wsClients: {
                if (!onThisMonitor || !workspaceRow.clientsByWorkspace) return []
                var by = workspaceRow.clientsByWorkspace
                var list = by[workspace.id] || by[workspace.name] || by[String(workspace.id)] || by[String(workspace.name)] || []
                return Array.isArray(list) ? list : []
            }
            readonly property int displayCount: Math.min(wsClients.length, workspaceRow.maxAppIndicators)
            readonly property int slotWidth: onThisMonitor
                ? (displayCount > 0
                    ? workspaceRow.slotPadding * 2 + displayCount * (workspaceRow.appIconSize + 2) + (displayCount - 1) * 2
                    : 28)
                : 0

            width: onThisMonitor ? slotWidth : 0
            height: onThisMonitor ? 24 : 0
            visible: onThisMonitor

            Item {
                id: delegateRoot
                anchors.fill: parent
                Rectangle {
                    anchors.fill: parent
                    radius: 6
                    border.width: isFocused ? 1 : 0
                    border.color: colors.primary
                    color: {
                        if (hasUrgent) return colors.urgent
                        if (!isActive && !wsMouse.containsMouse) return "transparent"
                        if (!isActive && wsMouse.containsMouse) return colors.borderSubtle
                        return isFocused ? colors.primary : colors.surfaceContainer
                    }
                    Behavior on color { ColorAnimation { duration: 100 } }
                    Behavior on border.width { NumberAnimation { duration: 100 } }

                    Row {
                        anchors.centerIn: parent
                        spacing: 2
                        layoutDirection: Qt.LeftToRight
                        Repeater {
                            model: displayCount
                            delegate: Item {
                                width: workspaceRow.appIconSize + 2
                                height: workspaceRow.appIconSize + 2
                                anchors.verticalCenter: parent ? parent.verticalCenter : undefined
                                readonly property var client: wsClients[index]
                                readonly property string letter: {
                                    if (!client) return "?"
                                    var s = (client.class || client.title || "?").toString().trim()
                                    return (s.charAt(0) || "?").toUpperCase()
                                }
                                readonly property string iconPath: (client && client.class) ? Quickshell.iconPath(String(client.class).toLowerCase(), true) : ""
                                readonly property bool hasIcon: iconPath !== ""
                                readonly property color badgeColor: {
                                    var arr = colors.workspaceSlotColors || [colors.surfaceBright]
                                    var i = index % Math.max(1, arr.length)
                                    return arr[i] || colors.surfaceBright
                                }
                                readonly property color badgeOnColor: {
                                    var arr = colors.workspaceSlotOnColors || [colors.textMain]
                                    var i = index % Math.max(1, arr.length)
                                    return arr[i] || colors.textMain
                                }
                                readonly property color letterColor: badgeOnColor !== badgeColor ? badgeOnColor : colors.textMain
                                Rectangle {
                                    anchors.centerIn: parent
                                    width: workspaceRow.appIconSize
                                    height: workspaceRow.appIconSize
                                    radius: width / 2
                                    color: badgeColor
                                    border.width: 1
                                    border.color: isActive ? (colors.textOnPrimary || colors.textMain) : colors.borderSubtle
                                    Text {
                                        id: letterLabel
                                        anchors.centerIn: parent
                                        text: letter
                                        color: letterColor
                                        font.pixelSize: Math.max(9, workspaceRow.appIconSize - 5)
                                        font.bold: true
                                        z: 0
                                    }
                                    Image {
                                        id: appIcon
                                        anchors.centerIn: parent
                                        width: workspaceRow.appIconSize - 2
                                        height: workspaceRow.appIconSize - 2
                                        source: iconPath
                                        sourceSize.width: workspaceRow.appIconSize - 2
                                        sourceSize.height: workspaceRow.appIconSize - 2
                                        visible: hasIcon && source !== "" && status === Image.Ready
                                        smooth: true
                                        mipmap: true
                                        z: 1
                                    }
                                }
                            }
                        }
                    }

                    Rectangle {
                        anchors.centerIn: parent
                        width: isActive ? 20 : 12
                        height: 12
                        radius: 6
                        visible: displayCount === 0 && !hasUrgent
                        color: occupied ? (isActive ? colors.textOnPrimary : colors.textMain) : "transparent"
                        border.width: occupied ? 0 : 1
                        border.color: isActive ? colors.textOnPrimary : colors.border
                        Behavior on width { NumberAnimation { duration: 120 } }
                    }
                    Text {
                        anchors.centerIn: parent
                        visible: hasUrgent
                        text: "!"
                        color: colors.textOnUrgent
                        font.pixelSize: 14
                        font.bold: true
                        font.family: colors.fontMain || "sans-serif"
                    }

                    MouseArea {
                        id: wsMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        acceptedButtons: Qt.LeftButton
                        onClicked: {
                            if (workspaceRow.hyprMonitor) {
                                Hyprland.dispatch("focusmonitor " + workspaceRow.hyprMonitor.name)
                                workspace.activate()
                            }
                        }
                    }
                }
            }
        }
    }
}
