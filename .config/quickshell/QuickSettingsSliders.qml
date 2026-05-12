import QtQuick
import QtQuick.Layouts
import Quickshell.Io
import Quickshell.Services.Pipewire

import "."

ColumnLayout {
    id: sliders
    required property var colors
    property string audioSettingsCommand: "pavucontrol"
    property string displaySettingsCommand: "wdisplays"

    signal runCommand(string cmd)

    spacing: 0
    Layout.fillWidth: true

    // ===== VOLUME =====
    property var defaultSink: Pipewire.defaultAudioSink
    PwObjectTracker { objects: defaultSink ? [defaultSink] : [] }
    property real volumeLevel: defaultSink && defaultSink.audio ? defaultSink.audio.volume : 0
    property bool volumeMuted: defaultSink && defaultSink.audio ? defaultSink.audio.muted : false

    Process {
        id: setVolumeProc
        command: []
        running: false
    }

    RowLayout {
        Layout.fillWidth: true
        spacing: 8
        Text {
            text: sliders.volumeMuted ? "\uF6A9" : "\uF028"
            color: colors.textMain
            font.pixelSize: 16
            font.family: colors.widgetIconFont
            Layout.preferredWidth: 24
        }
        Item {
            Layout.fillWidth: true
            Layout.preferredHeight: 28
            property real dragVal: -1
            readonly property real val: volSliderMa.pressed ? (dragVal >= 0 ? dragVal : sliders.volumeLevel) : sliders.volumeLevel
            Rectangle {
                width: parent.width
                height: 6
                radius: 3
                anchors.verticalCenter: parent.verticalCenter
                color: colors.surfaceBright
                Rectangle {
                    width: parent.width * parent.parent.val
                    height: parent.height
                    radius: 3
                    color: colors.primary
                }
            }
            Rectangle {
                width: 18
                height: 18
                radius: 9
                anchors.verticalCenter: parent.verticalCenter
                x: (parent.width - width) * parent.val
                color: volSliderMa.pressed ? colors.primaryContainer : colors.primary
                border.width: 1
                border.color: colors.border
            }
            MouseArea {
                id: volSliderMa
                anchors.fill: parent
                anchors.leftMargin: -9
                anchors.rightMargin: -9
                function setVal(x) {
                    var w = parent.width
                    var p = Math.min(1, Math.max(0, (x - 9) / w))
                    parent.dragVal = p
                    setVolumeProc.command = ["wpctl", "set-volume", "@DEFAULT_AUDIO_SINK@", Math.round(p * 100) + "%"]
                    setVolumeProc.running = true
                }
                onPressed: setVal(mouse.x)
                onPositionChanged: if (pressed) setVal(mouse.x)
                onReleased: parent.dragVal = -1
            }
        }
        Text {
            text: Math.round(sliders.volumeLevel * 100) + "%"
            color: colors.textDim
            font.pixelSize: 12
            Layout.minimumWidth: 40
        }
    }
    RowLayout {
        Layout.fillWidth: true
        Layout.leftMargin: 32
        spacing: 4
        Item { Layout.fillWidth: true }
        MouseArea {
            id: volGearMa
            width: 24
            height: 24
            hoverEnabled: true
            onClicked: sliders.runCommand(sliders.audioSettingsCommand)
            Rectangle {
                anchors.fill: parent
                radius: 4
                color: volGearMa.containsMouse ? colors.surfaceBright : "transparent"
            }
            Text {
                anchors.centerIn: parent
                text: "\uF013"
                color: colors.textDim
                font.pixelSize: 12
                font.family: colors.widgetIconFont
            }
        }
    }

    // ===== BRIGHTNESS =====
    RowLayout {
        Layout.fillWidth: true
        Layout.topMargin: 12
        spacing: 8
        visible: SystemServices.brightnessHas
        Text {
            text: "\uF185"
            color: colors.textMain
            font.pixelSize: 16
            font.family: colors.widgetIconFont
            Layout.preferredWidth: 24
        }
        Item {
            Layout.fillWidth: true
            Layout.preferredHeight: 28
            visible: SystemServices.brightnessHas
            property real dragVal: -1
            readonly property real val: (brightSliderMa.pressed && dragVal >= 0) ? dragVal : (SystemServices.brightnessLevel / 100)
            Rectangle {
                width: parent.width
                height: 6
                radius: 3
                anchors.verticalCenter: parent.verticalCenter
                color: colors.surfaceBright
                Rectangle {
                    width: parent.width * parent.parent.val
                    height: parent.height
                    radius: 3
                    color: colors.primary
                }
            }
            Rectangle {
                width: 18
                height: 18
                radius: 9
                anchors.verticalCenter: parent.verticalCenter
                x: (parent.width - width) * parent.val
                color: brightSliderMa.pressed ? colors.primaryContainer : colors.primary
                border.width: 1
                border.color: colors.border
            }
            MouseArea {
                id: brightSliderMa
                anchors.fill: parent
                anchors.leftMargin: -9
                anchors.rightMargin: -9
                function setVal(x) {
                    var w = parent.width
                    var p = Math.min(1, Math.max(0, (x - 9) / w))
                    parent.dragVal = p
                    SystemServices.setBrightness(Math.round(p * 100))
                }
                onPressed: setVal(mouse.x)
                onPositionChanged: if (pressed) setVal(mouse.x)
                onReleased: parent.dragVal = -1
            }
        }
        Text {
            text: SystemServices.brightnessLevel + "%"
            color: colors.textDim
            font.pixelSize: 12
            Layout.minimumWidth: 40
        }
    }
    RowLayout {
        Layout.fillWidth: true
        Layout.leftMargin: 32
        spacing: 4
        visible: SystemServices.brightnessHas
        Item { Layout.fillWidth: true }
        MouseArea {
            id: brightGearMa
            width: 24
            height: 24
            hoverEnabled: true
            onClicked: sliders.runCommand(sliders.displaySettingsCommand)
            Rectangle {
                anchors.fill: parent
                radius: 4
                color: brightGearMa.containsMouse ? colors.surfaceBright : "transparent"
            }
            Text {
                anchors.centerIn: parent
                text: "\uF108"
                color: colors.textDim
                font.pixelSize: 12
                font.family: colors.widgetIconFont
            }
        }
    }
}
