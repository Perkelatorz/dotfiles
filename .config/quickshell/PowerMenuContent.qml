import QtQuick
import Quickshell.Io

import "."

Column {
    id: powerMenuContent
    required property var colors
    required property var onClose

    property string lockCommand: "swaylock"
    property string suspendCommand: "systemctl suspend"
    property string hibernateCommand: "systemctl hibernate"
    property string logoutCommand: "loginctl terminate-user $(id -un)"
    property string rebootCommand: "systemctl reboot"
    property string shutdownCommand: "systemctl poweroff"

    spacing: 0
    width: 180

    function runAndClose(cmd, inSession) {
        powerMenuContent.onClose()
        if (inSession) {
            runInSessionProc.command = ["hyprctl", "dispatch", "exec", cmd]
            runInSessionProc.running = true
        } else {
            runProc.command = ["sh", "-c", cmd]
            runProc.running = true
        }
    }

    Process {
        id: runProc
        command: []
        running: false
    }
    Process {
        id: runInSessionProc
        command: []
        running: false
    }

    Repeater {
        model: [
            { label: "Lock", icon: "\uF023", cmd: powerMenuContent.lockCommand, inSession: true },
            { label: "Suspend", icon: "\uF186", cmd: powerMenuContent.suspendCommand, inSession: false },
            { label: "Hibernate", icon: "\uF2C1", cmd: powerMenuContent.hibernateCommand, inSession: false },
            { label: "Logout", icon: "\uF2F5", cmd: powerMenuContent.logoutCommand, inSession: false },
            { label: "Reboot", icon: "\uF021", cmd: powerMenuContent.rebootCommand, inSession: false },
            { label: "Shutdown", icon: "\uF011", cmd: powerMenuContent.shutdownCommand, inSession: false }
        ]
        delegate: Rectangle {
            width: powerMenuContent.width
            height: 36
            color: itemMouse.containsMouse ? colors.surfaceContainer : "transparent"

            MouseArea {
                id: itemMouse
                anchors.fill: parent
                hoverEnabled: true
                onClicked: powerMenuContent.runAndClose(modelData.cmd, modelData.inSession)

                Row {
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                    leftPadding: 12
                    spacing: 10
                    Text {
                        text: modelData.icon
                        color: colors.textMain
                        font.pixelSize: 14
                        font.family: colors.widgetIconFont
                    }
                    Text {
                        text: modelData.label
                        color: colors.textMain
                        font.pixelSize: colors.clockFontSize
                    }
                }
            }
        }
    }
}
