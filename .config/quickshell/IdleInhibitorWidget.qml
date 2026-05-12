import QtQuick
import Quickshell.Io

import "."

// Toggles hypridle service. Active hypridle = system idles normally. Inactive =
// stays awake (good for video calls / long downloads). Polls every 10 s and
// after each toggle to reflect external changes.
Item {
    id: idleWidget
    required property var colors
    property int pillIndex: 6
    property bool inhibited: false  // true = idle disabled, stay awake

    readonly property color pillColor: inhibited
        ? colors.urgent
        : ((colors.widgetPillColors && pillIndex >= 0 && pillIndex < colors.widgetPillColors.length) ? colors.widgetPillColors[pillIndex] : colors.primary)
    readonly property color pillTextColor: inhibited
        ? colors.textOnUrgent
        : ((colors.widgetTextOnPillColors && pillIndex >= 0 && pillIndex < colors.widgetTextOnPillColors.length) ? colors.widgetTextOnPillColors[pillIndex] : colors.textMain)

    implicitWidth: pill.width
    implicitHeight: 28

    PollingProcess {
        id: statePoll
        command: ["sh", "-c", "systemctl --user is-active hypridle 2>/dev/null"]
        interval: 10000
        active: idleWidget.visible
        onOutput: (text) => {
            var s = (text || "").trim()
            // "active" = hypridle running = idle works normally (NOT inhibited).
            // anything else (inactive, failed, unknown) = inhibited.
            idleWidget.inhibited = (s !== "active")
        }
    }

    Process {
        id: toggleProc
        running: false
        onRunningChanged: if (!running) statePoll.refresh()
    }

    function toggle() {
        toggleProc.command = idleWidget.inhibited
            ? ["systemctl", "--user", "start", "hypridle"]
            : ["systemctl", "--user", "stop", "hypridle"]
        toggleProc.running = true
    }

    Rectangle {
        id: pill
        height: idleWidget.implicitHeight - colors.widgetPillPaddingV * 2
        width: row.implicitWidth + colors.widgetPillPaddingH * 2
        anchors.verticalCenter: parent.verticalCenter
        radius: colors.widgetPillRadius
        color: mouseArea.pressed ? Qt.darker(idleWidget.pillColor, 1.15) : mouseArea.containsMouse ? Qt.lighter(idleWidget.pillColor, 1.2) : idleWidget.pillColor
        border.width: 1
        border.color: mouseArea.containsMouse ? Qt.lighter(idleWidget.pillColor, 1.4) : idleWidget.pillColor
        scale: mouseArea.pressed ? 0.94 : 1.0
        Behavior on color { ColorAnimation { duration: 100 } }
        Behavior on border.color { ColorAnimation { duration: 100 } }
        Behavior on scale { NumberAnimation { duration: 80; easing.type: Easing.OutCubic } }

        MouseArea {
            id: mouseArea
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: idleWidget.toggle()
        }

        Row {
            id: row
            anchors.centerIn: parent
            spacing: 4
            Text {
                // F0F4 = coffee (stay-awake), F236 = bed (idle-allowed)
                text: idleWidget.inhibited ? "" : ""
                color: idleWidget.pillTextColor
                font.pixelSize: colors.cpuFontSize
                font.family: colors.widgetIconFont
            }
        }

        Rectangle {
            opacity: mouseArea.containsMouse ? 1 : 0
            visible: opacity > 0
            Behavior on opacity { NumberAnimation { duration: 150; easing.type: Easing.OutCubic } }
            anchors.bottom: parent.top
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottomMargin: 4
            width: tip.implicitWidth + 12
            height: tip.implicitHeight + 6
            radius: 4
            color: colors.surface
            border.width: 1
            border.color: colors.border
            z: 1000
            Text {
                id: tip
                anchors.centerIn: parent
                text: idleWidget.inhibited ? "Idle disabled — click to allow sleep" : "Idle enabled — click to stay awake"
                color: colors.textMain
                font.pixelSize: colors.fontSize - 1
            }
        }
    }
}
