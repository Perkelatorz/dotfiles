import QtQuick

import "."

BarPill {
    id: overviewWidget

    signal toggleRequested()

    icon: "\uF00A"
    onClicked: overviewWidget.toggleRequested()
}
