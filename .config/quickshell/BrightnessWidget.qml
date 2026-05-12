import QtQuick
import Quickshell.Io

import "."

Item {
    id: brightnessWidget
    required property var colors
    property int pillIndex: 6
    property string outputName: ""
    property int screenIndex: 0

    readonly property color pillColor: (colors.widgetPillColors && pillIndex >= 0 && pillIndex < colors.widgetPillColors.length) ? colors.widgetPillColors[pillIndex] : colors.primary
    readonly property color pillTextColor: (colors.widgetTextOnPillColors && pillIndex >= 0 && pillIndex < colors.widgetTextOnPillColors.length) ? colors.widgetTextOnPillColors[pillIndex] : colors.textMain

    readonly property bool hasBrightness: SystemServices.brightnessHas
    readonly property int brightness: SystemServices.brightnessLevel

    implicitWidth: Math.max(56, pill.width)
    implicitHeight: 28

    Process {
        id: openDisplaySettings
        command: ["wdisplays"]
        running: false
    }

    Rectangle {
        id: pill
        height: brightnessWidget.implicitHeight - (colors.widgetPillPaddingV) * 2
        width: row.implicitWidth + (colors.widgetPillPaddingH) * 2
        anchors.verticalCenter: parent.verticalCenter
        radius: colors.widgetPillRadius
        color: mouseArea.pressed ? Qt.darker(brightnessWidget.pillColor, 1.15) : mouseArea.containsMouse ? Qt.lighter(brightnessWidget.pillColor, 1.2) : brightnessWidget.pillColor
        border.width: 1
        border.color: mouseArea.containsMouse ? Qt.lighter(brightnessWidget.pillColor, 1.4) : brightnessWidget.pillColor
        scale: mouseArea.pressed ? 0.94 : 1.0
        Behavior on color { ColorAnimation { duration: 100 } }
        Behavior on border.color { ColorAnimation { duration: 100 } }
        Behavior on scale { NumberAnimation { duration: 80; easing.type: Easing.OutCubic } }

        MouseArea {
            id: mouseArea
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            acceptedButtons: Qt.LeftButton | Qt.RightButton
            onClicked: function(mouse) {
                if (mouse.button === Qt.RightButton) openDisplaySettings.running = true
            }
            onWheel: function(wheel) {
                if (!brightnessWidget.hasBrightness) return
                var delta = wheel.angleDelta.y > 0 ? 5 : -5
                SystemServices.brightnessScreenIndex = brightnessWidget.screenIndex
                SystemServices.setBrightness(brightnessWidget.brightness + delta)
            }
            Row {
                id: row
                anchors.centerIn: parent
                spacing: 4
                Text {
                    text: ""
                    color: brightnessWidget.pillTextColor
                    font.pixelSize: colors.cpuFontSize
                    font.family: colors.widgetIconFont
                }
                Text {
                    text: brightnessWidget.hasBrightness ? (brightnessWidget.brightness + "%") : "N/A"
                    color: brightnessWidget.pillTextColor
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
            width: brightTipCol.implicitWidth + 16
            height: brightTipCol.implicitHeight + 8
            radius: 4
            color: colors.surface
            border.width: 1
            border.color: colors.border
            z: 1000
            Column {
                id: brightTipCol
                anchors.centerIn: parent
                spacing: 3
                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "Brightness: " + brightnessWidget.brightness + "%"
                    color: colors.textMain
                    font.pixelSize: colors.fontSize - 1
                }
                Rectangle {
                    width: 80
                    height: 4
                    radius: 2
                    color: colors.borderSubtle
                    Rectangle {
                        width: parent.width * (brightnessWidget.brightness / 100)
                        height: parent.height
                        radius: 2
                        color: colors.tertiary
                        Behavior on width { NumberAnimation { duration: 80 } }
                    }
                }
            }
        }
    }
}
