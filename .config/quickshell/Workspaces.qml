import QtQuick
import Quickshell
import Quickshell.Hyprland

import "."

// Workspace strip. Two data sources, one visual (WorkspacePill):
//   hyprland — Hyprland.workspaces, filtered to this monitor
//   mango    — the monitor's `tags` array from `mmsg watch all-monitors`
// The Hyprland branch is unchanged in behaviour from before the mango port.
Row {
    id: workspaceRow
    required property var colors
    required property string compositorName
    // Hyprland monitor object; null under mango.
    required property var hyprMonitor
    // mango: this monitor's entry out of shellRoot.mangoMonitors.
    property var mangoMonitor: null
    required property var occupiedWorkspaceIds
    property var clientsByWorkspace: ({})

    spacing: 6
    leftPadding: 8
    rightPadding: 8
    height: parent ? parent.height : 24

    readonly property int maxAppIndicators: 5
    readonly property int appIconSize: 18
    readonly property int slotPadding: 6

    // mango hardcodes 9 tags at compile time (src/config/preset.h), and there's
    // no runtime option to shrink that. Only 1-5 are bound in binds.conf, to
    // match the 5 Hyprland workspaces, so the rest are shown only when
    // something is actually on them — a window can never end up stranded on an
    // invisible tag, but the strip stays five wide in normal use.
    property int visibleTagCount: 5

    readonly property var mangoTags: {
        if (compositorName !== "mango" || !mangoMonitor) return []
        var all = mangoMonitor.tags || []
        var out = []
        for (var i = 0; i < all.length; i++) {
            var t = all[i]
            var idx = t.index !== undefined ? t.index : (i + 1)
            if (idx <= workspaceRow.visibleTagCount || t.is_active || t.is_urgent
                || workspaceRow.occupiedFor(idx))
                out.push(t)
        }
        return out
    }

    // Clients sitting on a given workspace/tag key, tolerating id-vs-name keys.
    function clientsFor(key, altKey) {
        var by = workspaceRow.clientsByWorkspace
        if (!by) return []
        var list = by[key] || by[String(key)] || (altKey !== undefined ? (by[altKey] || by[String(altKey)]) : null) || []
        return Array.isArray(list) ? list : []
    }

    function occupiedFor(key, altKey) {
        var occ = workspaceRow.occupiedWorkspaceIds
        if (!occ) return false
        return !!(occ[key] || occ[String(key)] || (altKey !== undefined && (occ[altKey] || occ[String(altKey)])))
    }

    // --- Hyprland ---------------------------------------------------------
    Repeater {
        model: workspaceRow.compositorName === "hyprland" ? Hyprland.workspaces : null
        delegate: Item {
            readonly property var workspace: modelData
            readonly property bool onThisMonitor: workspace.monitor === workspaceRow.hyprMonitor
            readonly property bool isActive: workspaceRow.hyprMonitor && workspaceRow.hyprMonitor.activeWorkspace && (
                workspaceRow.hyprMonitor.activeWorkspace.id === workspace.id ||
                workspaceRow.hyprMonitor.activeWorkspace.name === workspace.name
            )

            width: onThisMonitor ? hyprPill.width : 0
            height: onThisMonitor ? hyprPill.height : 0
            visible: onThisMonitor

            WorkspacePill {
                id: hyprPill
                colors: workspaceRow.colors
                isActive: parent.isActive
                isFocused: !!(workspaceRow.hyprMonitor && workspaceRow.hyprMonitor.focused && parent.isActive)
                hasUrgent: !!workspace.urgent
                occupied: workspaceRow.occupiedFor(workspace.id, String(workspace.name))
                wsClients: parent.onThisMonitor ? workspaceRow.clientsFor(workspace.id, workspace.name) : []
                maxAppIndicators: workspaceRow.maxAppIndicators
                appIconSize: workspaceRow.appIconSize
                slotPadding: workspaceRow.slotPadding
                onActivated: {
                    if (workspaceRow.hyprMonitor) {
                        Hyprland.dispatch("focusmonitor " + workspaceRow.hyprMonitor.name)
                        workspace.activate()
                    }
                }
            }
        }
    }

    // --- mango ------------------------------------------------------------
    // `tags` is a fixed-length array (one entry per configured tag), so unlike
    // Hyprland there is nothing to filter by monitor — the array already
    // belongs to this output.
    Repeater {
        model: workspaceRow.mangoTags
        delegate: WorkspacePill {
            required property var modelData
            required property int index
            // Read the tag number off the payload, never from the row position:
            // the model is filtered, so index no longer tracks the real tag.
            readonly property int tagIndex: modelData.index !== undefined ? modelData.index : (index + 1)

            colors: workspaceRow.colors
            isActive: !!modelData.is_active
            // mango marks exactly one monitor `active`; that's the focused one.
            isFocused: !!(workspaceRow.mangoMonitor && workspaceRow.mangoMonitor.active && modelData.is_active)
            hasUrgent: !!modelData.is_urgent
            occupied: workspaceRow.occupiedFor(tagIndex)
            wsClients: workspaceRow.clientsFor(tagIndex)
            maxAppIndicators: workspaceRow.maxAppIndicators
            appIconSize: workspaceRow.appIconSize
            slotPadding: workspaceRow.slotPadding
            onActivated: {
                if (!workspaceRow.mangoMonitor) return
                // Focus the output first so the tag switch lands there, mirroring
                // the focusmonitor + activate pair on the Hyprland side. The
                // singleton serialises the two so the second can't clobber the first.
                MangoIpc.dispatch("focusmon," + workspaceRow.mangoMonitor.name)
                MangoIpc.dispatch("view," + tagIndex + ",0")
            }
        }
    }
}
