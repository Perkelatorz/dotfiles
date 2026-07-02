import QtQuick

import "."

BarPill {
    id: toolsWidget
    pillIndex: 3

    signal toggleRequested()

    icon: "\uF0AD"
    onClicked: toolsWidget.toggleRequested()
}
