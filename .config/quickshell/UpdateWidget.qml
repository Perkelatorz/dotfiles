import QtQuick
import Quickshell.Io

import "."

Item {
    id: updateWidget
    required property var colors
    property int pillIndex: 1

    readonly property color pillColor: (colors.widgetPillColors && pillIndex >= 0 && pillIndex < colors.widgetPillColors.length) ? colors.widgetPillColors[pillIndex] : colors.primary
    readonly property color pillTextColor: (colors.widgetTextOnPillColors && pillIndex >= 0 && pillIndex < colors.widgetTextOnPillColors.length) ? colors.widgetTextOnPillColors[pillIndex] : colors.textMain

    readonly property int totalCount: SystemServices.repoUpdates + SystemServices.aurUpdates
    readonly property bool hasUpdates: totalCount > 0

    implicitWidth: hasUpdates ? pill.width : 0
    implicitHeight: hasUpdates ? 28 : 0
    visible: hasUpdates

    Process {
        id: runUpdate
        command: ["kitty", "-e", "paru"]
        running: false
    }

    Rectangle {
        id: pill
        height: updateWidget.implicitHeight - colors.widgetPillPaddingV * 2
        width: row.implicitWidth + colors.widgetPillPaddingH * 2
        anchors.verticalCenter: parent.verticalCenter
        radius: colors.widgetPillRadius
        color: mouseArea.pressed ? Qt.darker(updateWidget.pillColor, 1.15) : mouseArea.containsMouse ? Qt.lighter(updateWidget.pillColor, 1.2) : updateWidget.pillColor
        border.width: 1
        border.color: mouseArea.containsMouse ? Qt.lighter(updateWidget.pillColor, 1.4) : updateWidget.pillColor
        scale: mouseArea.pressed ? 0.94 : 1.0
        visible: updateWidget.hasUpdates
        Behavior on color { ColorAnimation { duration: 100 } }
        Behavior on border.color { ColorAnimation { duration: 100 } }
        Behavior on scale { NumberAnimation { duration: 80; easing.type: Easing.OutCubic } }

        MouseArea {
            id: mouseArea
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: runUpdate.running = true
        }
        Row {
            id: row
            anchors.centerIn: parent
            spacing: 4
            Text {
                text: ""
                color: updateWidget.pillTextColor
                font.pixelSize: colors.cpuFontSize
                font.family: colors.widgetIconFont
            }
            Text {
                text: String(updateWidget.totalCount)
                color: updateWidget.pillTextColor
                font.pixelSize: colors.cpuFontSize
            }
        }
        Rectangle {
            opacity: mouseArea.containsMouse ? 1 : 0
            visible: opacity > 0
            Behavior on opacity { NumberAnimation { duration: 150; easing.type: Easing.OutCubic } }
            anchors.bottom: parent.top
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottomMargin: 4
            width: updateTip.implicitWidth + 12
            height: updateTip.implicitHeight + 6
            radius: 4
            color: colors.surface
            border.width: 1
            border.color: colors.border
            z: 1000
            Text {
                id: updateTip
                anchors.centerIn: parent
                text: SystemServices.repoUpdates + " repo + " + SystemServices.aurUpdates + " AUR updates"
                color: colors.textMain
                font.pixelSize: colors.fontSize - 1
            }
        }
    }
}
