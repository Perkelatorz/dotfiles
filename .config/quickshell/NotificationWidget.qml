import QtQuick

import "."

// The bell. Reads NotificationService, which is this shell's own notification
// server — swaync-client and its three subscription/toggle processes are gone
// with it, along with the guesswork of parsing another daemon's output.
BarPill {
    id: notifWidget
    pillIndex: 4

    signal centerToggleRequested()

    readonly property int count: NotificationService.count
    readonly property bool dnd: NotificationService.dnd

    icon: dnd ? "" : ""
    label: count > 0 ? String(count) : ""

    // Do-not-disturb is a state you chose and should see; a waiting count is
    // just information.
    active: dnd
    activeColor: colors.secondaryContainer
    activeTextColor: colors.textOnSecondaryContainer

    onClicked: mouse => {
        if (mouse.button === Qt.RightButton) NotificationService.toggleDnd()
        else if (mouse.button === Qt.MiddleButton) NotificationService.clearHistory()
        else notifWidget.centerToggleRequested()
    }
}
