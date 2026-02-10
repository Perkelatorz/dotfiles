import QtQuick
import Quickshell.Hyprland

import "."

Row {
    id: workspaceRow
    required property var colors
    required property var hyprMonitor
    required property var occupiedWorkspaceIds

    spacing: 6
    leftPadding: 8
    rightPadding: 8
    height: parent ? parent.height : 24

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
            readonly property color slotOnColor: (colors.workspaceSlotOnColors && colors.workspaceSlotOnColors.length > 0)
                ? colors.workspaceSlotOnColors[index % colors.workspaceSlotOnColors.length]
                : colors.textMain

            width: onThisMonitor ? 28 : 0
            height: onThisMonitor ? 24 : 0
            visible: onThisMonitor

            Rectangle {
                anchors.fill: parent
                radius: 6
                color: {
                    if (hasUrgent) return colors.urgent
                    if (!isActive && !wsMouse.containsMouse) return "transparent"
                    if (!isActive && wsMouse.containsMouse) return colors.borderSubtle
                    if (colors.workspaceSlotColors && colors.workspaceSlotColors.length > 0)
                        return colors.workspaceSlotColors[index % colors.workspaceSlotColors.length]
                    return isFocused ? colors.primary : colors.surfaceContainer
                }
                Behavior on color { ColorAnimation { duration: 100 } }

                Rectangle {
                    anchors.centerIn: parent
                    width: 12
                    height: 12
                    radius: 6
                    visible: !hasUrgent
                    color: occupied ? (isActive ? slotOnColor : colors.textMain) : "transparent"
                    border.width: occupied ? 0 : 1
                    border.color: isActive ? slotOnColor : colors.border
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
                Rectangle {
                    visible: wsMouse.containsMouse && onThisMonitor
                    anchors.bottom: parent.top
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.bottomMargin: 4
                    width: wsTip.implicitWidth + 12
                    height: wsTip.implicitHeight + 6
                    radius: 4
                    color: colors.surface
                    border.width: 1
                    border.color: colors.border
                    z: 1000
                    Text {
                        id: wsTip
                        anchors.centerIn: parent
                        text: workspace.name || ("Workspace " + (workspace.id || index + 1))
                        color: colors.textMain
                        font.pixelSize: 11
                    }
                }
            }
        }
    }
}
