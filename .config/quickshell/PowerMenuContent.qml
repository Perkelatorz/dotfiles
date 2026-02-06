import QtQuick
import Quickshell.Io

import "."

Column {
    id: powerMenuContent
    required property var colors
    required property var onClose

    property string lockCommand: "hyprlock"
    property string suspendCommand: "systemctl suspend"
    property string hibernateCommand: "systemctl hibernate"
    property string logoutCommand: "loginctl terminate-user $(id -un)"
    property string rebootCommand: "systemctl reboot"
    property string shutdownCommand: "systemctl poweroff"

    spacing: 0
    width: 180

    function runAndClose(cmd) {
        runProc.command = ["sh", "-c", cmd]
        runProc.running = true
        powerMenuContent.onClose()
    }

    Process {
        id: runProc
        command: []
        running: false
    }

    Repeater {
        model: [
            { label: "Lock", icon: "\uF023", cmd: powerMenuContent.lockCommand },
            { label: "Suspend", icon: "\uF186", cmd: powerMenuContent.suspendCommand },
            { label: "Hibernate", icon: "\uF2C1", cmd: powerMenuContent.hibernateCommand },
            { label: "Logout", icon: "\uF2F5", cmd: powerMenuContent.logoutCommand },
            { label: "Reboot", icon: "\uF021", cmd: powerMenuContent.rebootCommand },
            { label: "Shutdown", icon: "\uF011", cmd: powerMenuContent.shutdownCommand }
        ]
        delegate: Rectangle {
            width: powerMenuContent.width
            height: 36
            color: itemMouse.containsMouse ? colors.surfaceContainer : "transparent"

            MouseArea {
                id: itemMouse
                anchors.fill: parent
                hoverEnabled: true
                onClicked: powerMenuContent.runAndClose(modelData.cmd)

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
