import QtQuick
import Quickshell.Io

import "."

BarPill {
    id: notifWidget

    property int notifCount: 0
    property bool dndActive: false

    icon: dndActive ? "\uF1F6" : "\uF0F3"
    active: dndActive

    // One long-lived subscription instead of two 3s pollers — swaync pushes a
    // JSON line on every state change (and the current state on connect). If
    // swaync isn't running the spawn fails once and stays quiet.
    Process {
        id: subscribeProc
        command: ["swaync-client", "--subscribe"]
        running: notifWidget.visible
        stdout: SplitParser {
            onRead: line => {
                try {
                    var o = JSON.parse(line)
                    if (typeof o.count === "number") notifWidget.notifCount = Math.max(0, o.count)
                    if (typeof o.dnd === "boolean") notifWidget.dndActive = o.dnd
                } catch (_) { }
            }
        }
    }
    Process {
        id: togglePanelProc
        command: ["swaync-client", "-t"]
        running: false
    }
    Process {
        id: dismissAllProc
        command: ["swaync-client", "-C"]
        running: false
    }
    Process {
        id: toggleDndProc
        command: ["swaync-client", "-d"]
        running: false
    }

    // Unread badge rides in the content row.
    Rectangle {
        visible: notifWidget.notifCount > 0 && !notifWidget.dndActive
        anchors.verticalCenter: parent.verticalCenter
        width: Math.max(14, badgeText.implicitWidth + 6)
        height: 14
        radius: 7
        color: colors.error
        Text {
            id: badgeText
            anchors.centerIn: parent
            text: notifWidget.notifCount > 99 ? "99+" : String(notifWidget.notifCount)
            color: colors.textOnError
            font.pixelSize: 8
            font.bold: true
        }
    }

    onClicked: mouse => {
        if (mouse.button === Qt.RightButton) dismissAllProc.running = true
        else if (mouse.button === Qt.MiddleButton) toggleDndProc.running = true
        else togglePanelProc.running = true
    }
}
