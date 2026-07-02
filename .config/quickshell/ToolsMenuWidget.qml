import QtQuick

import "."

BarPill {
    id: toolsWidget

    signal toggleRequested()

    icon: "\uF0AD"
    onClicked: toolsWidget.toggleRequested()
}
