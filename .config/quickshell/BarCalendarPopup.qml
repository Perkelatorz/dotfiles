import QtQuick
import Quickshell

import "."

/**
 * Calendar popup anchored to anchorItem (e.g. clock). Uses anchor.item so
 * Quickshell maps item position to the window at show time.
 * Rect is in item coords: 200px-wide band at bottom to center popup under the clock.
 */
PopupWindow {
    id: popup

    required property var colors
    required property bool isOpen
    required property var anchorItem
    required property var calendarState

    property int popupWidth: 200
    property int popupHeight: 200
    property int topMargin: 5
    property int offsetX: 0
    property int offsetY: 0

    visible: isOpen && anchorItem != null
    implicitWidth: popupWidth
    implicitHeight: popupHeight
    color: colors.background

    anchor.item: anchorItem
    anchor.rect.x: anchorItem ? Math.max(0, Math.floor((anchorItem.width - popupWidth) / 2)) : 0
    anchor.rect.y: 0
    anchor.rect.width: popupWidth
    anchor.rect.height: anchorItem ? Math.max(1, Math.floor(anchorItem.height)) : 1
    anchor.edges: Edges.Bottom | Edges.Left
    anchor.gravity: Edges.Bottom | Edges.Right
    anchor.margins.left: offsetX
    anchor.margins.top: topMargin + offsetY
    anchor.adjustment: PopupAdjustment.Slide | PopupAdjustment.Flip

    // Recalculate position after show in case layout wasn't ready
    Timer {
        interval: 50
        running: popup.visible && popup.anchor.item != null
        repeat: false
        onTriggered: if (popup.anchor.item) popup.anchor.updateAnchor()
    }

    Column {
        anchors.fill: parent
        spacing: 0
        Rectangle {
            width: parent.width
            height: Math.max(0, parent.height - 28)
            color: colors.background
            border.width: 1
            border.color: colors.border
            StyledCalendarGrid {
                anchors.fill: parent
                colors: popup.colors
                calendarDays: calendarState.calendarDays
                calendarTodayDay: calendarState.calendarTodayDay
                calendarIsCurrentMonth: calendarState.calendarIsCurrentMonth
            }
        }
        Row {
            width: parent.width
            height: 28
            spacing: 4
            layoutDirection: Qt.LeftToRight
            Item {
                width: 24
                height: parent.height
                MouseArea {
                    anchors.fill: parent
                    onClicked: calendarState.calendarPreviousMonth()
                    Text {
                        anchors.centerIn: parent
                        text: "◀"
                        color: colors.textMain
                        font.pixelSize: colors.clockFontSize
                    }
                }
            }
            Text {
                width: parent.width - 24 - 24 - 24 - 44
                height: parent.height
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                text: calendarState.calendarTitle
                color: colors.primary
                font.pixelSize: colors.clockFontSize
                font.bold: true
            }
            Item {
                width: 24
                height: parent.height
                MouseArea {
                    anchors.fill: parent
                    onClicked: calendarState.calendarNextMonth()
                    Text {
                        anchors.centerIn: parent
                        text: "▶"
                        color: colors.textMain
                        font.pixelSize: colors.clockFontSize
                    }
                }
            }
            Item {
                width: 44
                height: parent.height
                MouseArea {
                    anchors.fill: parent
                    onClicked: calendarState.calendarGoToToday()
                    Rectangle {
                        anchors.fill: parent
                        anchors.margins: 2
                        radius: 4
                        color: colors.surfaceContainer
                        Text {
                            anchors.centerIn: parent
                            text: "Today"
                            color: colors.textMain
                            font.pixelSize: colors.clockFontSize - 1
                        }
                    }
                }
            }
        }
    }
}
