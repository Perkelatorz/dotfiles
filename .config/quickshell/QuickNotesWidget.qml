import QtQuick
import Quickshell.Io

import "."

Item {
    id: notesWidget
    required property var colors
    property int pillIndex: 3
    property string compositorName: "hyprland"

    readonly property color pillColor: (colors.widgetPillColors && pillIndex >= 0 && pillIndex < colors.widgetPillColors.length) ? colors.widgetPillColors[pillIndex] : colors.primary
    readonly property color pillTextColor: (colors.widgetTextOnPillColors && pillIndex >= 0 && pillIndex < colors.widgetTextOnPillColors.length) ? colors.widgetTextOnPillColors[pillIndex] : colors.textMain

    implicitWidth: pill.width
    implicitHeight: 28

    SessionRunner {
        id: sessionRunner
        compositorName: notesWidget.compositorName
    }

    Rectangle {
        id: pill
        height: notesWidget.implicitHeight - colors.widgetPillPaddingV * 2
        width: row.implicitWidth + colors.widgetPillPaddingH * 2
        anchors.verticalCenter: parent.verticalCenter
        radius: colors.widgetPillRadius
        color: mouseArea.pressed ? Qt.darker(notesWidget.pillColor, 1.15) : mouseArea.containsMouse ? Qt.lighter(notesWidget.pillColor, 1.2) : notesWidget.pillColor
        border.width: 1
        border.color: mouseArea.containsMouse ? Qt.lighter(notesWidget.pillColor, 1.4) : notesWidget.pillColor
        scale: mouseArea.pressed ? 0.94 : 1.0
        Behavior on color { ColorAnimation { duration: 100 } }
        Behavior on border.color { ColorAnimation { duration: 100 } }
        Behavior on scale { NumberAnimation { duration: 80; easing.type: Easing.OutCubic } }

        MouseArea {
            id: mouseArea
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            acceptedButtons: Qt.LeftButton
            onClicked: sessionRunner.run("kitty --class quick-notes -e nvim ~/notes.md")
            Row {
                id: row
                anchors.centerIn: parent
                spacing: 0
                leftPadding: colors.widgetPillPaddingH
                rightPadding: colors.widgetPillPaddingH
                Text {
                    text: "\uF249"
                    color: notesWidget.pillTextColor
                    font.pixelSize: colors.cpuFontSize
                    font.family: colors.widgetIconFont
                }
            }
        }
    }
}
