import QtQuick
import Quickshell

import "."

BarPill {
    id: clockWidget
    pillIndex: 3

    signal calendarToggleRequested()

    SystemClock {
        id: systemClock
        precision: SystemClock.Seconds
    }

    icon: ""
    label: Qt.formatTime(systemClock.date, "HH:mm")
    onClicked: clockWidget.calendarToggleRequested()
}
