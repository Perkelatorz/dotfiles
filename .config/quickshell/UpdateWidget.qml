import QtQuick
import Quickshell.Io

import "."

Item {
    id: updateWidget
    required property var colors
    property int pillIndex: 1

    readonly property color pillColor: (colors.widgetPillColors && pillIndex >= 0 && pillIndex < colors.widgetPillColors.length) ? colors.widgetPillColors[pillIndex] : colors.primary
    readonly property color pillTextColor: (colors.widgetTextOnPillColors && pillIndex >= 0 && pillIndex < colors.widgetTextOnPillColors.length) ? colors.widgetTextOnPillColors[pillIndex] : colors.textMain

    property int repoCount: 0
    property int aurCount: 0
    readonly property int totalCount: repoCount + aurCount
    readonly property bool hasUpdates: totalCount > 0

    implicitWidth: hasUpdates ? pill.width : 0
    implicitHeight: hasUpdates ? 28 : 0
    visible: hasUpdates

    Process {
        id: repoProc
        command: ["sh", "-c", "checkupdates 2>/dev/null | wc -l"]
        running: false
        stdout: StdioCollector {
            onStreamFinished: {
                var n = parseInt((repoProc.stdout.text || "").trim(), 10)
                updateWidget.repoCount = isNaN(n) ? 0 : Math.max(0, n)
                repoProc.running = false
            }
        }
    }

    Process {
        id: aurProc
        command: ["sh", "-c", "paru -Qua 2>/dev/null | wc -l"]
        running: false
        stdout: StdioCollector {
            onStreamFinished: {
                var n = parseInt((aurProc.stdout.text || "").trim(), 10)
                updateWidget.aurCount = isNaN(n) ? 0 : Math.max(0, n)
                aurProc.running = false
            }
        }
    }

    Process {
        id: runUpdate
        command: ["kitty", "-e", "paru"]
        running: false
    }

    Timer {
        interval: 1800000
        repeat: true
        running: updateWidget.visible || updateWidget.totalCount === 0
        onTriggered: {
            if (!repoProc.running) repoProc.running = true
            if (!aurProc.running) aurProc.running = true
        }
    }

    Component.onCompleted: {
        repoProc.running = true
        aurProc.running = true
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
                text: "\uF49E"
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
                text: updateWidget.repoCount + " repo + " + updateWidget.aurCount + " AUR updates"
                color: colors.textMain
                font.pixelSize: colors.fontSize - 1
            }
        }
    }
}
