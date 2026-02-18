import QtQuick
import Quickshell.Io
import Quickshell.Services.Pipewire

import "."

Item {
    id: volumeWidget
    required property var colors
    property int pillIndex: 7

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
    Process {
        id: toggleMuteProc
        command: ["wpctl", "set-mute", "@DEFAULT_AUDIO_SINK@", "toggle"]
        running: false
    }

    Rectangle {
        id: pill
        height: volumeWidget.implicitHeight - (colors.widgetPillPaddingV) * 2
        width: row.implicitWidth + (colors.widgetPillPaddingH) * 2
        anchors.verticalCenter: parent.verticalCenter
        radius: colors.widgetPillRadius
        color: mouseArea.pressed ? Qt.darker(volumeWidget.pillColor, 1.15) : mouseArea.containsMouse ? Qt.lighter(volumeWidget.pillColor, 1.2) : volumeWidget.pillColor
        border.width: 1
        border.color: mouseArea.containsMouse ? Qt.lighter(volumeWidget.pillColor, 1.4) : volumeWidget.pillColor
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
                if (mouse.button === Qt.RightButton) runVolumeControl.running = true
                else if (mouse.button === Qt.MiddleButton) toggleMuteProc.running = true
            }
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
        Rectangle {
            opacity: mouseArea.containsMouse ? 1 : 0
            visible: opacity > 0
            Behavior on opacity { NumberAnimation { duration: 150; easing.type: Easing.OutCubic } }
            anchors.bottom: parent.top
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottomMargin: 4
            width: volTipCol.implicitWidth + 16
            height: volTipCol.implicitHeight + 8
            radius: 4
            color: colors.surface
            border.width: 1
            border.color: colors.border
            z: 1000
            Column {
                id: volTipCol
                anchors.centerIn: parent
                spacing: 3
                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: volumeWidget.muted ? "Muted" : ("Volume: " + Math.round(volumeWidget.volume * 100) + "%")
                    color: colors.textMain
                    font.pixelSize: colors.fontSize - 1
                }
                Rectangle {
                    width: 80
                    height: 4
                    radius: 2
                    color: colors.borderSubtle
                    visible: !volumeWidget.muted
                    Rectangle {
                        width: parent.width * Math.min(1, volumeWidget.volume)
                        height: parent.height
                        radius: 2
                        color: colors.primary
                        Behavior on width { NumberAnimation { duration: 80 } }
                    }
                }
            }
        }
    }
}
