import QtQuick
import Quickshell.Io

import "."

Item {
    id: ipWidget
    required property var colors
    property int pillIndex: 1

    readonly property color pillColor: (colors.widgetPillColors && pillIndex >= 0 && pillIndex < colors.widgetPillColors.length) ? colors.widgetPillColors[pillIndex] : colors.error
    readonly property color pillTextColor: (colors.widgetTextOnPillColors && pillIndex >= 0 && pillIndex < colors.widgetTextOnPillColors.length) ? colors.widgetTextOnPillColors[pillIndex] : colors.textMain

    property string ipAddress: ""

    implicitWidth: pill.width
    implicitHeight: 28

    Process {
        id: ipProc
        command: ["sh", "-c", "ip -4 addr show scope global 2>/dev/null | grep -oE 'inet [0-9.]+/[0-9]+' | head -1 | awk '{print $2}'"]
        stdout: StdioCollector {
            onStreamFinished: {
                var s = (ipProc.stdout.text || "").trim()
                ipWidget.ipAddress = s || "--"
                ipProc.running = false
            }
        }
    }

    Process {
        id: runConnectionEditor
        command: ["nm-connection-editor"]
        running: false
    }

    Process {
        id: copyIpProc
        command: ["sh", "-c", "echo -n '" + ipWidget.ipAddress + "' | wl-copy"]
        running: false
    }

    Timer {
        interval: 60000
        repeat: true
        running: ipWidget.visible
        onTriggered: ipProc.running = true
    }

    property bool _copied: false
    Timer { id: copiedTimer; interval: 1500; onTriggered: ipWidget._copied = false }

    Component.onCompleted: ipProc.running = true

    Rectangle {
        id: pill
        height: ipWidget.implicitHeight - (colors.widgetPillPaddingV) * 2
        width: row.implicitWidth + colors.widgetPillPaddingH * 2
        anchors.verticalCenter: parent.verticalCenter
        radius: colors.widgetPillRadius
        color: mouseArea.pressed ? Qt.darker(ipWidget.pillColor, 1.15) : mouseArea.containsMouse ? Qt.lighter(ipWidget.pillColor, 1.2) : ipWidget.pillColor
        border.width: 1
        border.color: mouseArea.containsMouse ? Qt.lighter(ipWidget.pillColor, 1.4) : ipWidget.pillColor
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
                if (mouse.button === Qt.MiddleButton) {
                    copyIpProc.command = ["sh", "-c", "echo -n '" + ipWidget.ipAddress + "' | wl-copy"]
                    copyIpProc.running = true
                    ipWidget._copied = true
                    copiedTimer.restart()
                } else if (mouse.button === Qt.RightButton) {
                    runConnectionEditor.running = true
                }
            }
            Row {
                id: row
                anchors.centerIn: parent
                spacing: 4
                Text {
                    text: "\uF0AC"
                    color: ipWidget.pillTextColor
                    font.pixelSize: colors.cpuFontSize
                    font.family: colors.widgetIconFont
                }
                Text {
                    id: ipText
                    text: {
                        var a = (ipWidget.ipAddress || "").trim()
                        if (a === "" || a === "--") return "No network"
                        return a
                    }
                    color: ipWidget.pillTextColor
                    font.pixelSize: colors.cpuFontSize
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
            width: ipTip.implicitWidth + 12
            height: ipTip.implicitHeight + 6
            radius: 4
            color: colors.surface
            border.width: 1
            border.color: colors.border
            z: 1000
            Text {
                id: ipTip
                anchors.centerIn: parent
                text: ipWidget._copied ? "Copied!" : "Middle-click to copy"
                color: colors.textMain
                font.pixelSize: colors.fontSize - 1
            }
        }
    }
}
