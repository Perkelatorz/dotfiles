import QtQuick
import Quickshell

import "."

Item {
    id: clockWidget
    required property var colors
    property int pillIndex: 1

    readonly property color pillColor: (colors.widgetPillColors && pillIndex >= 0 && pillIndex < colors.widgetPillColors.length) ? colors.widgetPillColors[pillIndex] : colors.primary
    readonly property color pillTextColor: (colors.widgetTextOnPillColors && pillIndex >= 0 && pillIndex < colors.widgetTextOnPillColors.length) ? colors.widgetTextOnPillColors[pillIndex] : colors.textMain

    signal calendarToggleRequested()

    SystemClock {
        id: systemClock
        precision: SystemClock.Seconds
    }

    implicitWidth: pill.width
    implicitHeight: 28

    Rectangle {
        id: pill
        height: clockWidget.implicitHeight - colors.widgetPillPaddingV * 2
        width: Math.max(row.implicitWidth + colors.widgetPillPaddingH * 2, 56)
        anchors.verticalCenter: parent.verticalCenter
        radius: colors.widgetPillRadius
        color: clockWidget.pillColor
        border.width: 1
        border.color: clockWidget.pillColor

        MouseArea {
            id: clockMouse
            anchors.fill: parent
            hoverEnabled: true
            onClicked: clockWidget.calendarToggleRequested()
            Row {
                id: row
                anchors.centerIn: parent
                spacing: 4
                Text {
                    text: "\uF017"
                    color: clockWidget.pillTextColor
                    font.pixelSize: colors.clockFontSize
                    font.family: colors.widgetIconFont
                }
                Text {
                    id: clockText
                    text: Qt.formatTime(systemClock.date, "HH:mm")
                    color: clockWidget.pillTextColor
                    font.pixelSize: colors.clockFontSize
                }
            }
        }
        Rectangle {
            visible: clockMouse.containsMouse
            anchors.bottom: parent.top
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottomMargin: 4
            width: dateTip.implicitWidth + 12
            height: dateTip.implicitHeight + 6
            radius: 4
            color: colors.surface
            border.width: 1
            border.color: colors.border
            z: 1000
            Text {
                id: dateTip
                anchors.centerIn: parent
                text: Qt.formatDateTime(systemClock.date, "dddd, d MMMM yyyy")
                color: colors.textMain
                font.pixelSize: colors.clockFontSize - 1
            }
        }
    }
}
