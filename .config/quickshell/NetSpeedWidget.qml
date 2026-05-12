import QtQuick
import Quickshell.Io

import "."

Item {
    id: netWidget
    required property var colors
    property int pillIndex: 2

    readonly property color pillColor: (colors.widgetPillColors && pillIndex >= 0 && pillIndex < colors.widgetPillColors.length) ? colors.widgetPillColors[pillIndex] : colors.primary
    readonly property color pillTextColor: (colors.widgetTextOnPillColors && pillIndex >= 0 && pillIndex < colors.widgetTextOnPillColors.length) ? colors.widgetTextOnPillColors[pillIndex] : colors.textMain

    readonly property string iface: SystemServices.netIface
    readonly property real rxRate: SystemServices.rxRate
    readonly property real txRate: SystemServices.txRate

    implicitWidth: pill.width
    implicitHeight: 28

    function formatSpeed(bytesPerSec) {
        if (bytesPerSec < 1024) return Math.round(bytesPerSec) + " B/s"
        if (bytesPerSec < 1024 * 1024) return Math.round(bytesPerSec / 1024) + " KB/s"
        return (bytesPerSec / (1024 * 1024)).toFixed(1) + " MB/s"
    }

    Process {
        id: runConnectionEditor
        command: ["nm-connection-editor"]
        running: false
    }

    Rectangle {
        id: pill
        height: netWidget.implicitHeight - colors.widgetPillPaddingV * 2
        width: Math.max(row.implicitWidth + colors.widgetPillPaddingH * 2, 80)
        anchors.verticalCenter: parent.verticalCenter
        radius: colors.widgetPillRadius
        color: mouseArea.pressed ? Qt.darker(netWidget.pillColor, 1.15) : mouseArea.containsMouse ? Qt.lighter(netWidget.pillColor, 1.2) : netWidget.pillColor
        border.width: 1
        border.color: mouseArea.containsMouse ? Qt.lighter(netWidget.pillColor, 1.4) : netWidget.pillColor
        scale: mouseArea.pressed ? 0.94 : 1.0
        Behavior on color { ColorAnimation { duration: 100 } }
        Behavior on border.color { ColorAnimation { duration: 100 } }
        Behavior on scale { NumberAnimation { duration: 80; easing.type: Easing.OutCubic } }

        MouseArea {
            id: mouseArea
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: runConnectionEditor.running = true
        }
        Row {
            id: row
            anchors.centerIn: parent
            spacing: 6
            Row {
                spacing: 2
                Text {
                    text: ""
                    color: netWidget.pillTextColor
                    font.pixelSize: colors.cpuFontSize - 1
                    font.family: colors.widgetIconFont
                }
                Text {
                    text: netWidget.formatSpeed(netWidget.rxRate)
                    color: netWidget.pillTextColor
                    font.pixelSize: colors.cpuFontSize - 1
                }
            }
            Row {
                spacing: 2
                Text {
                    text: ""
                    color: netWidget.pillTextColor
                    font.pixelSize: colors.cpuFontSize - 1
                    font.family: colors.widgetIconFont
                }
                Text {
                    text: netWidget.formatSpeed(netWidget.txRate)
                    color: netWidget.pillTextColor
                    font.pixelSize: colors.cpuFontSize - 1
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
            width: netTip.implicitWidth + 12
            height: netTip.implicitHeight + 6
            radius: 4
            color: colors.surface
            border.width: 1
            border.color: colors.border
            z: 1000
            Text {
                id: netTip
                anchors.centerIn: parent
                text: netWidget.iface ? (netWidget.iface + " - " + netWidget.formatSpeed(netWidget.rxRate) + " down / " + netWidget.formatSpeed(netWidget.txRate) + " up") : "No network"
                color: colors.textMain
                font.pixelSize: colors.fontSize - 1
            }
        }
    }
}
