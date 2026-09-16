import QtQuick

import "."

/**
 * Calendar UI content (nav header + month grid). Use inside the bar or any
 * container.
 *
 * Draws no surface of its own: PopupPanel already puts the calendar on the
 * tinted M3 ground every other menu uses, and the bordered box this used to
 * paint inside it made the panel read as two stacked cards. Nav moved above the
 * grid for the same reason it sits there in every calendar — you look at the
 * month name first.
 */
Column {
    id: content

    required property var colors
    required property var calendarState

    spacing: 6

    // --- building blocks --------------------------------------------------
    component NavButton: MouseArea {
        id: navBtn
        required property string glyph
        signal triggered()

        width: 26
        height: 26
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: navBtn.triggered()

        Rectangle {
            anchors.fill: parent
            radius: width / 2
            color: navBtn.containsMouse
                ? Qt.rgba(content.colors.textMain.r, content.colors.textMain.g,
                          content.colors.textMain.b, 0.10)
                : "transparent"
            Behavior on color { ColorAnimation { duration: 100 } }
        }
        Text {
            anchors.centerIn: parent
            text: navBtn.glyph
            color: navBtn.containsMouse ? content.colors.primary : content.colors.textDim
            font.pixelSize: content.colors.fontLg
        }
    }

    component TodayButton: MouseArea {
        id: todayMa
        signal triggered()

        width: 46
        height: 24
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: todayMa.triggered()

        // Lit only while the view has wandered off the current month: when
        // "Today" would do nothing, it shouldn't look like a button.
        readonly property bool armed: !content.calendarState.calendarIsCurrentMonth

        Rectangle {
            anchors.fill: parent
            radius: 12
            color: {
                var a = content.colors.primary
                if (todayMa.containsMouse && todayMa.armed) return Qt.rgba(a.r, a.g, a.b, 0.22)
                if (todayMa.armed) return Qt.rgba(a.r, a.g, a.b, 0.12)
                return Qt.rgba(content.colors.textMain.r, content.colors.textMain.g,
                               content.colors.textMain.b, 0.05)
            }
            Behavior on color { ColorAnimation { duration: 100 } }
        }
        Text {
            anchors.centerIn: parent
            text: "Today"
            color: todayMa.armed ? content.colors.primary : content.colors.textMuted
            font.pixelSize: content.colors.fontXs
        }
    }

    // ===== NAV =====
    Item {
        id: nav
        width: grid.implicitWidth
        height: 30

        NavButton {
            id: prevBtn
            glyph: "‹"
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            onTriggered: content.calendarState.calendarPreviousMonth()
        }

        TodayButton {
            id: todayBtn
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            onTriggered: content.calendarState.calendarGoToToday()
        }

        NavButton {
            id: nextBtn
            glyph: "›"
            anchors.right: todayBtn.left
            anchors.rightMargin: 2
            anchors.verticalCenter: parent.verticalCenter
            onTriggered: content.calendarState.calendarNextMonth()
        }

        Text {
            anchors.left: prevBtn.right
            anchors.right: nextBtn.left
            anchors.verticalCenter: parent.verticalCenter
            anchors.leftMargin: 2
            anchors.rightMargin: 2
            horizontalAlignment: Text.AlignHCenter
            elide: Text.ElideRight
            text: content.calendarState.calendarTitle
            color: content.colors.textMain
            font.pixelSize: content.colors.fontMd
            font.bold: true
        }
    }

    // ===== GRID =====
    StyledCalendarGrid {
        id: grid
        colors: content.colors
        calendarDays: content.calendarState.calendarDays
        calendarTodayDay: content.calendarState.calendarTodayDay
        calendarIsCurrentMonth: content.calendarState.calendarIsCurrentMonth
    }
}
