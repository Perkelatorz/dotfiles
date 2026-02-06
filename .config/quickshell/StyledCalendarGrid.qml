import QtQuick

import "."

Item {
    id: root
    required property var colors
    required property var calendarDays
    required property int calendarTodayDay
    required property bool calendarIsCurrentMonth

    readonly property var dayNames: ["Mo", "Tu", "We", "Th", "Fr", "Sa", "Su"]
    property int cellWidth: Math.max(18, Math.floor((width - 14) / 7))
    property int headerHeight: 20
    property int rowHeight: 18

    Column {
        anchors.fill: parent
        anchors.margins: 6
        spacing: 2

        Row {
            width: root.width - 12
            height: root.headerHeight
            spacing: 2
            Repeater {
                model: root.dayNames
                Text {
                    width: root.cellWidth
                    height: root.headerHeight
                    text: modelData
                    color: root.colors.primary
                    font.pixelSize: root.colors.clockFontSize - 1
                    font.bold: true
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
            }
        }

        Grid {
            id: daysGrid
            columns: 7
            rows: 6
            rowSpacing: 2
            columnSpacing: 2
            width: 7 * root.cellWidth + 6 * 2
            height: 6 * root.rowHeight + 5 * 2

            Repeater {
                model: root.calendarDays || []
                Rectangle {
                    width: root.cellWidth
                    height: root.rowHeight
                    color: {
                        if (modelData === 0)
                            return "transparent"
                        if (root.calendarIsCurrentMonth && modelData === root.calendarTodayDay)
                            return root.colors.calendarCurrentDayBg
                        return "transparent"
                    }
                    radius: 3

                    Text {
                        anchors.centerIn: parent
                        text: modelData > 0 ? modelData : ""
                        color: {
                            if (modelData === 0)
                                return "transparent"
                            if (root.calendarIsCurrentMonth && modelData === root.calendarTodayDay)
                                return root.colors.textOnPrimary
                            return root.colors.textMain
                        }
                        font.pixelSize: root.colors.clockFontSize - 1
                        font.family: "monospace"
                    }
                }
            }
        }
    }
}
