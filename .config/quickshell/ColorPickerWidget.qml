import QtQuick
import Quickshell.Io

import "."

Item {
    id: pickerWidget
    required property var colors
    property int pillIndex: 4

    readonly property color pillColor: (colors.widgetPillColors && pillIndex >= 0 && pillIndex < colors.widgetPillColors.length) ? colors.widgetPillColors[pillIndex] : colors.primary
    readonly property color pillTextColor: (colors.widgetTextOnPillColors && pillIndex >= 0 && pillIndex < colors.widgetTextOnPillColors.length) ? colors.widgetTextOnPillColors[pillIndex] : colors.textMain

    property string lastPickedColor: ""
    property bool picking: false

    implicitWidth: pill.width
    implicitHeight: 28

    Process {
        id: pickerProc
        command: ["hyprpicker", "-a", "-f", "hex"]
        running: false
        stdout: StdioCollector {
            onStreamFinished: {
                var hex = (pickerProc.stdout.text || "").trim()
                if (hex.length > 0) {
                    pickerWidget.lastPickedColor = hex
                    pickerWidget.picking = false
                    flashTimer.restart()
                } else {
                    pickerWidget.picking = false
                }
                pickerProc.running = false
            }
        }
    }

    Timer { id: flashTimer; interval: 3000; onTriggered: pickerWidget.lastPickedColor = "" }

    Rectangle {
        id: pill
        height: pickerWidget.implicitHeight - colors.widgetPillPaddingV * 2
        width: row.implicitWidth + colors.widgetPillPaddingH * 2
        anchors.verticalCenter: parent.verticalCenter
        radius: colors.widgetPillRadius
        color: {
            if (pickerWidget.lastPickedColor) return pickerWidget.lastPickedColor
            if (mouseArea.pressed) return Qt.darker(pickerWidget.pillColor, 1.15)
            if (mouseArea.containsMouse) return Qt.lighter(pickerWidget.pillColor, 1.2)
            return pickerWidget.pillColor
        }
        border.width: 1
        border.color: mouseArea.containsMouse ? Qt.lighter(pickerWidget.pillColor, 1.4) : pickerWidget.pillColor
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
            onClicked: {
                if (!pickerProc.running) {
                    pickerWidget.picking = true
                    pickerProc.running = true
                }
            }

            Row {
                id: row
                anchors.centerIn: parent
                spacing: 4
                leftPadding: colors.widgetPillPaddingH
                rightPadding: colors.widgetPillPaddingH
                Text {
                    text: pickerWidget.picking ? "\uF110" : "\uF1FB"
                    color: pickerWidget.lastPickedColor ? (Qt.colorEqual(Qt.darker(pickerWidget.lastPickedColor, 1.5), "#000000") ? "#ffffff" : "#000000") : pickerWidget.pillTextColor
                    font.pixelSize: colors.cpuFontSize
                    font.family: colors.widgetIconFont
                }
                Text {
                    visible: pickerWidget.lastPickedColor !== ""
                    text: pickerWidget.lastPickedColor
                    color: Qt.colorEqual(Qt.darker(pickerWidget.lastPickedColor, 1.5), "#000000") ? "#ffffff" : "#000000"
                    font.pixelSize: 10
                    font.bold: true
                    font.family: colors.fontMain
                }
            }
        }
    }

    Rectangle {
        id: tooltip
        visible: mouseArea.containsMouse && pickerWidget.lastPickedColor !== ""
        x: pill.x + (pill.width - width) / 2
        y: pill.y + pill.height + 4
        width: tooltipText.implicitWidth + 12
        height: tooltipText.implicitHeight + 6
        radius: 4
        color: colors.surfaceContainer
        border.width: 1
        border.color: colors.borderSubtle
        opacity: visible ? 1 : 0
        Behavior on opacity { NumberAnimation { duration: 150; easing.type: Easing.OutCubic } }
        Text {
            id: tooltipText
            anchors.centerIn: parent
            text: "Copied: " + pickerWidget.lastPickedColor
            color: colors.textMain
            font.pixelSize: 10
        }
    }
}
