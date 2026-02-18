import QtQuick
import Quickshell.Io
import Quickshell.Services.Pipewire

import "."

Item {
    id: micWidget
    required property var colors
    property int pillIndex: 0

    readonly property color pillColor: (colors.widgetPillColors && pillIndex >= 0 && pillIndex < colors.widgetPillColors.length) ? colors.widgetPillColors[pillIndex] : colors.tertiary
    readonly property color pillTextColor: (colors.widgetTextOnPillColors && pillIndex >= 0 && pillIndex < colors.widgetTextOnPillColors.length) ? colors.widgetTextOnPillColors[pillIndex] : colors.textMain

    property var source: Pipewire.defaultAudioSource
    PwObjectTracker {
        objects: micWidget.source ? [micWidget.source] : []
    }

    property bool muted: micWidget.source && micWidget.source.audio ? micWidget.source.audio.muted : false

    implicitWidth: pill.width
    implicitHeight: 28

    Process {
        id: toggleMuteProc
        command: ["wpctl", "set-mute", "@DEFAULT_AUDIO_SOURCE@", micWidget.muted ? "0" : "1"]
        running: false
    }

    Rectangle {
        id: pill
        height: micWidget.implicitHeight - (colors.widgetPillPaddingV) * 2
        width: row.implicitWidth + (colors.widgetPillPaddingH) * 2
        anchors.verticalCenter: parent.verticalCenter
        radius: colors.widgetPillRadius
        color: mouseArea.pressed ? Qt.darker(micWidget.pillColor, 1.15) : mouseArea.containsMouse ? Qt.lighter(micWidget.pillColor, 1.2) : micWidget.pillColor
        border.width: 1
        border.color: mouseArea.containsMouse ? Qt.lighter(micWidget.pillColor, 1.4) : micWidget.pillColor
        scale: mouseArea.pressed ? 0.94 : 1.0
        Behavior on color { ColorAnimation { duration: 100 } }
        Behavior on border.color { ColorAnimation { duration: 100 } }
        Behavior on scale { NumberAnimation { duration: 80; easing.type: Easing.OutCubic } }

        MouseArea {
            id: mouseArea
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: toggleMuteProc.running = true
            Row {
                id: row
                anchors.centerIn: parent
                spacing: 4
                Text {
                    text: micWidget.muted ? "\uF131" : "\uF130"
                    color: micWidget.pillTextColor
                    font.pixelSize: colors.cpuFontSize
                    font.family: colors.widgetIconFont
                }
                Text {
                    text: micWidget.muted ? "Muted" : "Mic"
                    color: micWidget.pillTextColor
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
            width: micTip.implicitWidth + 12
            height: micTip.implicitHeight + 6
            radius: 4
            color: colors.surface
            border.width: 1
            border.color: colors.border
            z: 1000
            Text {
                id: micTip
                anchors.centerIn: parent
                text: micWidget.muted ? "Mic muted" : "Mic active"
                color: colors.textMain
                font.pixelSize: colors.fontSize - 1
            }
        }
    }
}
