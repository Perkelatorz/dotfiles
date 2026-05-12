import QtQuick
import Quickshell.Io

import "."

Item {
    id: batteryWidget
    required property var colors
    property int pillIndex: 5

    readonly property bool hasBattery: SystemServices.batteryHas
    readonly property int capacity: SystemServices.batteryCapacity
    readonly property string status: SystemServices.batteryStatus
    readonly property bool lowBattery: hasBattery && status !== "Charging" && capacity < 15
    readonly property color pillColor: lowBattery ? colors.urgent : ((colors.widgetPillColors && pillIndex >= 0 && pillIndex < colors.widgetPillColors.length) ? colors.widgetPillColors[pillIndex] : colors.primary)
    readonly property color pillTextColor: lowBattery ? colors.textOnUrgent : ((colors.widgetTextOnPillColors && pillIndex >= 0 && pillIndex < colors.widgetTextOnPillColors.length) ? colors.widgetTextOnPillColors[pillIndex] : colors.textMain)

    implicitWidth: hasBattery ? pill.width : 0
    implicitHeight: hasBattery ? 28 : 0
    visible: hasBattery

    Process {
        id: openPowerSettings
        command: ["xdg-open", "power"]
        running: false
    }

    Rectangle {
        id: pill
        height: batteryWidget.implicitHeight - (colors.widgetPillPaddingV) * 2
        width: row.implicitWidth + (colors.widgetPillPaddingH) * 2
        anchors.verticalCenter: parent.verticalCenter
        radius: colors.widgetPillRadius
        color: batteryHover.pressed ? Qt.darker(batteryWidget.pillColor, 1.15) : batteryHover.containsMouse ? Qt.lighter(batteryWidget.pillColor, 1.2) : batteryWidget.pillColor
        border.width: 1
        border.color: batteryHover.containsMouse ? Qt.lighter(batteryWidget.pillColor, 1.4) : batteryWidget.pillColor
        scale: batteryHover.pressed ? 0.94 : 1.0
        visible: batteryWidget.hasBattery
        Behavior on color { ColorAnimation { duration: 100 } }
        Behavior on border.color { ColorAnimation { duration: 100 } }
        Behavior on scale { NumberAnimation { duration: 80; easing.type: Easing.OutCubic } }

        SequentialAnimation {
            id: lowBatteryPulse
            loops: Animation.Infinite
            running: batteryWidget.lowBattery
            NumberAnimation { target: pill; property: "opacity"; from: 1; to: 0.5; duration: 800; easing.type: Easing.InOutSine }
            NumberAnimation { target: pill; property: "opacity"; from: 0.5; to: 1; duration: 800; easing.type: Easing.InOutSine }
            onRunningChanged: if (!running) pill.opacity = 1
        }

        MouseArea {
            id: batteryHover
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            acceptedButtons: Qt.RightButton
            onClicked: openPowerSettings.running = true
        }
        Row {
            id: row
            anchors.centerIn: parent
            spacing: 4
            Text {
                text: {
                    if (batteryWidget.status === "Charging") return ""
                    if (batteryWidget.capacity <= 10) return ""
                    if (batteryWidget.capacity <= 25) return ""
                    if (batteryWidget.capacity <= 50) return ""
                    if (batteryWidget.capacity <= 75) return ""
                    return ""
                }
                color: batteryWidget.pillTextColor
                font.pixelSize: colors.cpuFontSize
                font.family: colors.widgetIconFont
            }
            Text {
                text: batteryWidget.capacity + "%"
                color: batteryWidget.pillTextColor
                font.pixelSize: colors.cpuFontSize
            }
        }
        Rectangle {
            opacity: batteryHover.containsMouse ? 1 : 0
            visible: opacity > 0
            Behavior on opacity { NumberAnimation { duration: 150; easing.type: Easing.OutCubic } }
            anchors.bottom: parent.top
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottomMargin: 4
            width: tipText.implicitWidth + 12
            height: tipText.implicitHeight + 6
            radius: 4
            color: colors.surface
            border.width: 1
            border.color: colors.border
            z: 1000
            Text {
                id: tipText
                anchors.centerIn: parent
                text: {
                    var t = SystemServices.batteryTimeText
                    if (batteryWidget.status === "Charging")
                        return t ? ("Charging · " + t + " to full") : "Charging"
                    return t ? (batteryWidget.capacity + "% · " + t + " remaining") : (batteryWidget.capacity + "% remaining")
                }
                color: colors.textMain
                font.pixelSize: colors.fontSize - 1
            }
        }
    }
}
