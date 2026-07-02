import QtQuick
import Quickshell.Io

import "."

BarPill {
    id: brightnessWidget

    property string outputName: ""
    property int screenIndex: 0

    readonly property bool hasBrightness: SystemServices.brightnessHas
    readonly property int brightness: SystemServices.brightnessLevel

    icon: "\uF185"
    label: brightness + "%"
    present: hasBrightness

    Process {
        id: openDisplaySettings
        command: ["wdisplays"]
        running: false
    }

    onClicked: mouse => {
        if (mouse.button === Qt.RightButton) openDisplaySettings.running = true
    }
    onWheelMoved: wheel => {
        if (!hasBrightness) return
        var delta = wheel.angleDelta.y > 0 ? 5 : -5
        SystemServices.brightnessScreenIndex = brightnessWidget.screenIndex
        SystemServices.setBrightness(brightness + delta)
    }
}
