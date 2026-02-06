import QtQuick

import "."

/**
 * Calendar UI content only (grid + nav). Use inside the bar or any container.
 * Same look as BarCalendarPopup, no separate window.
 */
Column {
    id: content
    required property var colors
    required property var calendarState

    spacing: 0
    Rectangle {
        width: content.width
        height: Math.max(0, content.height - 28)
        color: colors.background
        border.width: 1
        border.color: colors.border
        StyledCalendarGrid {
            anchors.fill: parent
            colors: content.colors
            calendarDays: content.calendarState.calendarDays
            calendarTodayDay: content.calendarState.calendarTodayDay
            calendarIsCurrentMonth: content.calendarState.calendarIsCurrentMonth
        }
    }
    Row {
        width: content.width
        height: 28
        spacing: 4
        layoutDirection: Qt.LeftToRight
        Item {
            width: 24
            height: parent.height
            MouseArea {
                anchors.fill: parent
                onClicked: content.calendarState.calendarPreviousMonth()
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
            text: content.calendarState.calendarTitle
            color: colors.primary
            font.pixelSize: colors.clockFontSize
            font.bold: true
        }
        Item {
            width: 24
            height: parent.height
            MouseArea {
                anchors.fill: parent
                onClicked: content.calendarState.calendarNextMonth()
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
                onClicked: content.calendarState.calendarGoToToday()
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
