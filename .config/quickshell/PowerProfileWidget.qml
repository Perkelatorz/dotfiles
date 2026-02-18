import QtQuick
import Quickshell.Io

import "."

Item {
    id: powerWidget
    required property var colors
    property int pillIndex: 3

    readonly property color pillColor: (colors.widgetPillColors && pillIndex >= 0 && pillIndex < colors.widgetPillColors.length) ? colors.widgetPillColors[pillIndex] : colors.primary
    readonly property color pillTextColor: (colors.widgetTextOnPillColors && pillIndex >= 0 && pillIndex < colors.widgetTextOnPillColors.length) ? colors.widgetTextOnPillColors[pillIndex] : colors.textMain

    property string profile: "balanced"
    readonly property var profiles: ["balanced", "performance", "power-saver"]
    readonly property var profileLabels: ({ "balanced": "Bal", "performance": "Perf", "power-saver": "Save" })
    readonly property var profileIcons: ({ "balanced": "\uF24E", "performance": "\uF0E4", "power-saver": "\uF06C" })

    implicitWidth: pill.width
    implicitHeight: 28

    Process {
        id: getProc
        command: ["powerprofilesctl", "get"]
        stdout: StdioCollector {
            onStreamFinished: {
                var s = (getProc.stdout.text || "").trim()
                if (s) powerWidget.profile = s
                getProc.running = false
            }
        }
        Component.onCompleted: running = true
    }

    Process {
        id: setProc
        command: ["powerprofilesctl", "set", "balanced"]
        running: false
        onRunningChanged: if (!running) getProc.running = true
    }

    Timer {
        interval: 10000
        repeat: true
        running: powerWidget.visible
        onTriggered: if (!getProc.running) getProc.running = true
    }

    function cycleProfile() {
        var idx = profiles.indexOf(profile)
        var next = profiles[(idx + 1) % profiles.length]
        setProc.command = ["powerprofilesctl", "set", next]
        setProc.running = true
    }

    Rectangle {
        id: pill
        height: powerWidget.implicitHeight - colors.widgetPillPaddingV * 2
        width: Math.max(row.implicitWidth + colors.widgetPillPaddingH * 2, 52)
        anchors.verticalCenter: parent.verticalCenter
        radius: colors.widgetPillRadius
        color: mouseArea.pressed ? Qt.darker(powerWidget.pillColor, 1.15) : mouseArea.containsMouse ? Qt.lighter(powerWidget.pillColor, 1.2) : powerWidget.pillColor
        border.width: 1
        border.color: mouseArea.containsMouse ? Qt.lighter(powerWidget.pillColor, 1.4) : powerWidget.pillColor
        scale: mouseArea.pressed ? 0.94 : 1.0
        Behavior on color { ColorAnimation { duration: 100 } }
        Behavior on border.color { ColorAnimation { duration: 100 } }
        Behavior on scale { NumberAnimation { duration: 80; easing.type: Easing.OutCubic } }

        MouseArea {
            id: mouseArea
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: powerWidget.cycleProfile()
        }
        Row {
            id: row
            anchors.centerIn: parent
            spacing: 4
            Text {
                text: powerWidget.profileIcons[powerWidget.profile] || "\uF24E"
                color: powerWidget.pillTextColor
                font.pixelSize: colors.cpuFontSize
                font.family: colors.widgetIconFont
            }
            Text {
                text: powerWidget.profileLabels[powerWidget.profile] || "Bal"
                color: powerWidget.pillTextColor
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
            width: powerTip.implicitWidth + 12
            height: powerTip.implicitHeight + 6
            radius: 4
            color: colors.surface
            border.width: 1
            border.color: colors.border
            z: 1000
            Text {
                id: powerTip
                anchors.centerIn: parent
                text: "Power: " + powerWidget.profile
                color: colors.textMain
                font.pixelSize: colors.fontSize - 1
            }
        }
    }
}
