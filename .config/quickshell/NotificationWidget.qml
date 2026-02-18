import QtQuick
import Quickshell.Io

import "."

Item {
    id: notifWidget
    required property var colors
    property int pillIndex: 4

    readonly property color pillColor: (colors.widgetPillColors && pillIndex >= 0 && pillIndex < colors.widgetPillColors.length) ? colors.widgetPillColors[pillIndex] : colors.primary
    readonly property color pillTextColor: (colors.widgetTextOnPillColors && pillIndex >= 0 && pillIndex < colors.widgetTextOnPillColors.length) ? colors.widgetTextOnPillColors[pillIndex] : colors.textMain

    property int notifCount: 0
    property bool dndActive: false

    implicitWidth: pill.width
    implicitHeight: 28

    Process {
        id: countProc
        command: ["swaync-client", "-c"]
        running: false
        stdout: StdioCollector {
            onStreamFinished: {
                var s = (countProc.stdout.text || "").trim()
                var n = parseInt(s, 10)
                notifWidget.notifCount = isNaN(n) ? 0 : Math.max(0, n)
                countProc.running = false
            }
        }
    }

    Process {
        id: dndProc
        command: ["swaync-client", "-D"]
        running: false
        stdout: StdioCollector {
            onStreamFinished: {
                var s = (dndProc.stdout.text || "").trim().toLowerCase()
                notifWidget.dndActive = (s === "true")
                dndProc.running = false
            }
        }
    }

    Process {
        id: togglePanelProc
        command: ["swaync-client", "-t"]
        running: false
        stdout: StdioCollector {
            onStreamFinished: togglePanelProc.running = false
        }
    }

    Process {
        id: dismissAllProc
        command: ["swaync-client", "-C"]
        running: false
        stdout: StdioCollector {
            onStreamFinished: {
                dismissAllProc.running = false
                countProc.running = true
            }
        }
    }

    Process {
        id: toggleDndProc
        command: ["swaync-client", "-d"]
        running: false
        stdout: StdioCollector {
            onStreamFinished: {
                toggleDndProc.running = false
                dndProc.running = true
            }
        }
    }

    Timer {
        interval: 3000
        repeat: true
        running: notifWidget.visible
        onTriggered: {
            if (!countProc.running) countProc.running = true
            if (!dndProc.running) dndProc.running = true
        }
    }

    Component.onCompleted: {
        countProc.running = true
        dndProc.running = true
    }

    Rectangle {
        id: pill
        height: notifWidget.implicitHeight - colors.widgetPillPaddingV * 2
        width: row.implicitWidth + colors.widgetPillPaddingH * 2
        anchors.verticalCenter: parent.verticalCenter
        radius: colors.widgetPillRadius
        color: mouseArea.pressed ? Qt.darker(notifWidget.pillColor, 1.15) : mouseArea.containsMouse ? Qt.lighter(notifWidget.pillColor, 1.2) : notifWidget.pillColor
        border.width: 1
        border.color: mouseArea.containsMouse ? Qt.lighter(notifWidget.pillColor, 1.4) : notifWidget.pillColor
        scale: mouseArea.pressed ? 0.94 : 1.0
        Behavior on color { ColorAnimation { duration: 100 } }
        Behavior on border.color { ColorAnimation { duration: 100 } }
        Behavior on scale { NumberAnimation { duration: 80; easing.type: Easing.OutCubic } }

        MouseArea {
            id: mouseArea
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            acceptedButtons: Qt.LeftButton | Qt.MiddleButton | Qt.RightButton
            onClicked: function(mouse) {
                if (mouse.button === Qt.RightButton)
                    dismissAllProc.running = true
                else if (mouse.button === Qt.MiddleButton)
                    toggleDndProc.running = true
                else
                    togglePanelProc.running = true
            }
        }
        Item {
            id: row
            anchors.centerIn: parent
            width: bellIcon.implicitWidth + 4
            height: bellIcon.implicitHeight
            Text {
                id: bellIcon
                anchors.centerIn: parent
                text: notifWidget.dndActive ? "\uF1F6" : "\uF0F3"
                color: notifWidget.pillTextColor
                font.pixelSize: colors.cpuFontSize
                font.family: colors.widgetIconFont
            }
            Rectangle {
                visible: notifWidget.notifCount > 0 && !notifWidget.dndActive
                anchors.right: bellIcon.right
                anchors.top: bellIcon.top
                anchors.rightMargin: -4
                anchors.topMargin: -2
                width: Math.max(12, badgeText.implicitWidth + 4)
                height: 12
                radius: 6
                color: colors.error
                z: 2
                Text {
                    id: badgeText
                    anchors.centerIn: parent
                    text: notifWidget.notifCount > 99 ? "99+" : String(notifWidget.notifCount)
                    color: colors.textOnError
                    font.pixelSize: 8
                    font.bold: true
                }
            }
        }
        Rectangle {
            opacity: mouseArea.containsMouse ? 1 : 0
            visible: opacity > 0
            Behavior on opacity { NumberAnimation { duration: 150; easing.type: Easing.OutCubic } }
            anchors.bottom: parent.top
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottomMargin: 4
            width: notifTip.implicitWidth + 12
            height: notifTip.implicitHeight + 6
            radius: 4
            color: colors.surface
            border.width: 1
            border.color: colors.border
            z: 1000
            Text {
                id: notifTip
                anchors.centerIn: parent
                text: notifWidget.dndActive ? "Do Not Disturb" : (notifWidget.notifCount + " notification" + (notifWidget.notifCount !== 1 ? "s" : ""))
                color: colors.textMain
                font.pixelSize: colors.fontSize - 1
            }
        }
    }
}
