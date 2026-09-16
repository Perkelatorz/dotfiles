import QtQuick

import "."

// Month grid: a weekday header over six rows of day cells.
//
// `calendarDays` is 42 entries of { day, inMonth } — always six rows, so the
// panel keeps its height while you page through months instead of growing and
// shrinking under the cursor. The days either side of the month are real dates
// rather than blanks, dimmed to stay out of the way: a grid that shows where
// the month sits in the week is easier to read than one that starts in midair.
Column {
    id: root

    required property var colors
    required property var calendarDays
    required property int calendarTodayDay
    required property bool calendarIsCurrentMonth

    property int cellSize: 30
    property int cellSpacing: 2

    readonly property var dayNames: ["Mo", "Tu", "We", "Th", "Fr", "Sa", "Su"]

    spacing: 4

    Row {
        spacing: root.cellSpacing
        Repeater {
            model: root.dayNames
            delegate: Text {
                required property int index
                required property string modelData
                width: root.cellSize
                height: 18
                text: modelData
                // Weekends step back a shade. The header is the only place the
                // distinction is drawn — colouring the numbers too turns a
                // quiet grid into a striped one.
                color: index >= 5 ? root.colors.textMuted : root.colors.textDim
                font.pixelSize: root.colors.fontXs
                font.bold: true
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }
        }
    }

    Grid {
        columns: 7
        rowSpacing: root.cellSpacing
        columnSpacing: root.cellSpacing

        Repeater {
            model: root.calendarDays || []
            delegate: Rectangle {
                id: cell
                required property var modelData

                readonly property int day: modelData ? (modelData.day || 0) : 0
                readonly property bool inMonth: modelData ? !!modelData.inMonth : false
                readonly property bool isToday: root.calendarIsCurrentMonth
                    && cell.inMonth && cell.day === root.calendarTodayDay

                width: root.cellSize
                height: root.cellSize
                radius: root.cellSize / 2

                color: {
                    if (cell.isToday) return root.colors.primary
                    if (cellMouse.containsMouse)
                        return Qt.rgba(root.colors.textMain.r, root.colors.textMain.g,
                                       root.colors.textMain.b, 0.08)
                    return "transparent"
                }
                Behavior on color { ColorAnimation { duration: 100 } }

                Text {
                    anchors.centerIn: parent
                    text: cell.day > 0 ? cell.day : ""
                    // Today's fill is solid accent, so its label takes the
                    // paired on-primary colour. It used to be on-primary over a
                    // 20%-alpha wash, which is dark text on a dark ground — the
                    // highlight was there, the number in it was not.
                    color: cell.isToday ? root.colors.textOnPrimary
                         : (cell.inMonth ? root.colors.textMain
                                         : Qt.rgba(root.colors.textMuted.r, root.colors.textMuted.g,
                                                   root.colors.textMuted.b, 0.45))
                    font.pixelSize: root.colors.fontSm
                    font.bold: cell.isToday
                    font.family: root.colors.fontMain || "monospace"
                }

                MouseArea {
                    id: cellMouse
                    anchors.fill: parent
                    hoverEnabled: true
                }
            }
        }
    }
}
