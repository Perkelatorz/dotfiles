import QtQuick
import QtQuick.Layouts

import "."

// A hairline between two clusters of the status run. With no fill behind any
// widget, a dense row of icon+text reads as one undifferentiated line; these
// are what turn it back into groups.
//
// Only placed at boundaries where both sides are reliably populated — most of
// the alert-tier widgets collapse to zero width when they have nothing to say,
// and a rule with nothing on one side of it is worse than no rule.
Rectangle {
    required property var colors
    implicitWidth: 1
    implicitHeight: 14
    Layout.alignment: Qt.AlignVCenter
    Layout.leftMargin: 7
    Layout.rightMargin: 7
    color: Qt.rgba(colors.textMain.r, colors.textMain.g, colors.textMain.b, 0.13)
}
