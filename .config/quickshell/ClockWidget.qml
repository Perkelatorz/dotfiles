import QtQuick
import Quickshell

import "."

Item {
    id: clockWidget
    required property var colors
    property int pillIndex: 3

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
        color: clockMouse.pressed ? Qt.darker(clockWidget.pillColor, 1.15) : clockMouse.containsMouse ? Qt.lighter(clockWidget.pillColor, 1.2) : clockWidget.pillColor
        border.width: 1
        border.color: clockMouse.containsMouse ? Qt.lighter(clockWidget.pillColor, 1.4) : clockWidget.pillColor
        scale: clockMouse.pressed ? 0.94 : 1.0
        Behavior on color { ColorAnimation { duration: 100 } }
        Behavior on border.color { ColorAnimation { duration: 100 } }
        Behavior on scale { NumberAnimation { duration: 80; easing.type: Easing.OutCubic } }

        MouseArea {
            id: clockMouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
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
            opacity: clockMouse.containsMouse ? 1 : 0
            visible: opacity > 0
            Behavior on opacity { NumberAnimation { duration: 150; easing.type: Easing.OutCubic } }
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
                font.pixelSize: colors.fontSize - 1
            }
        }
    }
}
