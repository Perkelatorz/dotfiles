import QtQuick
import Quickshell.Io
import Quickshell.Services.Pipewire

import "."

Item {
    id: volumeWidget
    required property var colors
    property int pillIndex: 5

    readonly property color pillColor: (colors.widgetPillColors && pillIndex >= 0 && pillIndex < colors.widgetPillColors.length) ? colors.widgetPillColors[pillIndex] : colors.tertiary
    readonly property color pillTextColor: (colors.widgetTextOnPillColors && pillIndex >= 0 && pillIndex < colors.widgetTextOnPillColors.length) ? colors.widgetTextOnPillColors[pillIndex] : colors.textMain

    // Command to run when clicked (volume control app). Change to e.g. "pulsemixer" or "ncpamixer" if preferred.
    property string volumeControlCommand: "pavucontrol"

    implicitWidth: pill.width
    implicitHeight: 28

    // Bind default sink so we can read volume (and optional mute)
    property var sink: Pipewire.defaultAudioSink
    PwObjectTracker {
        objects: volumeWidget.sink ? [volumeWidget.sink] : []
    }

    property real volume: volumeWidget.sink && volumeWidget.sink.audio ? volumeWidget.sink.audio.volume : 0
    property bool muted: volumeWidget.sink && volumeWidget.sink.audio ? volumeWidget.sink.audio.muted : false

    Process {
        id: runVolumeControl
        command: volumeWidget.volumeControlCommand.trim().split(/\s+/)
        running: false
    }

    Process {
        id: volumeUpProc
        command: ["wpctl", "set-volume", "@DEFAULT_AUDIO_SINK@", "2%+"]
        running: false
    }
    Process {
        id: volumeDownProc
        command: ["wpctl", "set-volume", "@DEFAULT_AUDIO_SINK@", "2%-"]
        running: false
    }

    Rectangle {
        id: pill
        height: volumeWidget.implicitHeight - (colors.widgetPillPaddingV) * 2
        width: row.implicitWidth + (colors.widgetPillPaddingH) * 2
        anchors.verticalCenter: parent.verticalCenter
        radius: colors.widgetPillRadius
        color: volumeWidget.pillColor
        border.width: 1
        border.color: volumeWidget.pillColor

        MouseArea {
            anchors.fill: parent
            acceptedButtons: Qt.LeftButton
            onClicked: runVolumeControl.running = true
            onWheel: function(wheel) {
                if (wheel.angleDelta.y > 0)
                    volumeUpProc.running = true
                else if (wheel.angleDelta.y < 0)
                    volumeDownProc.running = true
            }
            Row {
                id: row
                anchors.centerIn: parent
                spacing: 4
                Text {
                    text: volumeWidget.muted ? "\uF6A9" : "\uF028"
                    color: volumeWidget.pillTextColor
                    font.pixelSize: colors.cpuFontSize
                    font.family: colors.widgetIconFont
                }
                Text {
                    id: volumeText
                    text: {
                        if (!volumeWidget.sink)
                            return "--"
                        if (volumeWidget.muted)
                            return "M"
                        var v = volumeWidget.volume
                        if (v <= 1)
                            return Math.round(v * 100) + "%"
                        return Math.round(Math.min(100, v)) + "%"
                    }
                    color: volumeWidget.pillTextColor
                    font.pixelSize: colors.cpuFontSize
                }
            }
        }
    }
}
