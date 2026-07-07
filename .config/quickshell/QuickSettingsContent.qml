import QtQuick
import QtQuick.Layouts

import "."

ColumnLayout {
    id: quickSettingsRoot
    required property var colors
    required property var onClose
    property string compositorName: "hyprland"
    property int screenIndex: 0

    signal openPowerRequested()
    signal openSettingsRequested()
    signal openWifiRequested()
    signal openBluetoothRequested()

    property string audioSettingsCommand: "pavucontrol"
    property string displaySettingsCommand: "wdisplays"
    property string diskSettingsCommand: "sh -c \"thunar \\$HOME\""
    property string systemMonitorCommand: "kitty -e btop"

    spacing: 12
    Layout.fillWidth: true

    Component.onCompleted: SystemServices.brightnessScreenIndex = screenIndex
    onScreenIndexChanged: SystemServices.brightnessScreenIndex = screenIndex
    onVisibleChanged: SystemServices.qsOpen = visible

    SessionRunner {
        id: sessionRunner
        compositorName: quickSettingsRoot.compositorName
    }
    function runInSession(cmd) { sessionRunner.run(cmd) }

    QuickSettingsHeader {
        colors: quickSettingsRoot.colors
        active: quickSettingsRoot.visible
        onRunCommand: cmd => quickSettingsRoot.runInSession(cmd)
        onPowerRequested: quickSettingsRoot.openPowerRequested()
        onSettingsRequested: quickSettingsRoot.openSettingsRequested()
    }

    QuickSettingsSliders {
        colors: quickSettingsRoot.colors
        audioSettingsCommand: quickSettingsRoot.audioSettingsCommand
        displaySettingsCommand: quickSettingsRoot.displaySettingsCommand
        onRunCommand: cmd => quickSettingsRoot.runInSession(cmd)
    }

    QuickSettingsGrid {
        colors: quickSettingsRoot.colors
        audioSettingsCommand: quickSettingsRoot.audioSettingsCommand
        diskSettingsCommand: quickSettingsRoot.diskSettingsCommand
        onRunCommand: cmd => quickSettingsRoot.runInSession(cmd)
        onOpenWifiRequested: quickSettingsRoot.openWifiRequested()
        onOpenBluetoothRequested: quickSettingsRoot.openBluetoothRequested()
    }

    Item { Layout.fillHeight: true }
}
