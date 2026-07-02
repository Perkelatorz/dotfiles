import QtQuick

import "."

BarPill {
    id: overviewWidget
    pillIndex: 0

    signal toggleRequested()

    icon: "\uF00A"
    onClicked: overviewWidget.toggleRequested()
}
