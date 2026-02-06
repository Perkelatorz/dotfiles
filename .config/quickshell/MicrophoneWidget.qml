import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.Pipewire

import "."

Item {
    id: micWidget
    required property var colors
    property int pillIndex: 6

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
        color: micWidget.pillColor
        border.width: 1
        border.color: micWidget.pillColor

        MouseArea {
            anchors.fill: parent
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
    }
}
