import QtQuick
import QtQuick.Layouts
import Quickshell.Io

import "."

RowLayout {
    id: header
    required property var colors
    property bool active: true

    signal runCommand(string cmd)
    signal powerRequested()
    signal settingsRequested()

    spacing: 12
    Layout.fillWidth: true
    Layout.bottomMargin: 4

    property string userName: "user"
    property string userInitial: "?"
    property string homePath: ""
    property string uptimeText: "..."

    Process {
        id: userProc
        command: ["sh", "-c", "id -un 2>/dev/null"]
        running: true
        stdout: StdioCollector {
            onStreamFinished: {
                var n = (userProc.stdout.text || "").trim()
                if (n) {
                    header.userName = n
                    header.userInitial = n.charAt(0).toUpperCase()
                }
                userProc.running = false
            }
        }
    }
    Process {
        id: homeProc
        command: ["sh", "-c", "echo ${HOME:-}"]
        running: true
        stdout: StdioCollector {
            onStreamFinished: {
                var h = (homeProc.stdout.text || "").trim()
                if (h) header.homePath = h
                homeProc.running = false
            }
        }
    }
    Process {
        id: uptimeProc
        command: ["sh", "-c", "awk '{s=int($1); d=int(s/86400); h=int((s%86400)/3600); m=int((s%3600)/60); if(d>0) printf \"%d day%s, \", d, (d==1?\"\":\"s\"); printf \"%d hour%s, %d min\", h, (h==1?\"\":\"s\"), m; exit}' /proc/uptime 2>/dev/null"]
        running: true
        stdout: StdioCollector {
            onStreamFinished: {
                var t = (uptimeProc.stdout.text || "").trim()
                if (t) header.uptimeText = t
                uptimeProc.running = false
            }
        }
    }
    Timer {
        interval: 60000
        repeat: true
        running: header.active
        onTriggered: { uptimeProc.running = true }
    }

    Rectangle {
        width: 48
        height: 48
        radius: 24
        color: colors.surfaceBright
        border.width: 1
        border.color: colors.border
        clip: true
        Image {
            id: avatarImage
            anchors.fill: parent
            fillMode: Image.PreserveAspectCrop
            source: (colors.avatarPath && colors.avatarPath.length > 0)
                ? ("file://" + colors.avatarPath)
                : (header.homePath ? ("file://" + header.homePath + "/.face") : "")
            visible: status === Image.Ready
            onStatusChanged: if (status === Image.Error && source !== "") source = ""
        }
        Text {
            anchors.centerIn: parent
            text: header.userInitial
            color: colors.primary
            font.pixelSize: 20
            font.bold: true
            visible: !avatarImage.visible
        }
    }
    Column {
        spacing: 2
        Layout.fillWidth: true
        Text {
            text: header.userName
            color: colors.textMain
            font.pixelSize: 16
            font.bold: true
        }
        Text {
            text: "up " + header.uptimeText
            color: colors.textDim
            font.pixelSize: 12
        }
    }
    Row {
        spacing: 6
        Repeater {
            model: [
                { icon: "\uF023", action: "lock" },
                { icon: "\uF011", action: "power" },
                { icon: "\uF013", action: "settings" },
                { icon: "\uF304", action: "edit" }
            ]
            delegate: Rectangle {
                width: 32
                height: 32
                radius: 16
                color: actionMa.containsMouse ? colors.surfaceBright : "transparent"
                MouseArea {
                    id: actionMa
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: {
                        if (modelData.action === "lock") header.runCommand("hyprlock")
                        else if (modelData.action === "power") header.powerRequested()
                        else if (modelData.action === "settings") header.settingsRequested()
                        else if (modelData.action === "edit") header.runCommand("sh -c 'xdg-open \"$HOME/.config/quickshell\"'")
                    }
                }
                Text {
                    anchors.centerIn: parent
                    text: modelData.icon
                    color: colors.textMain
                    font.pixelSize: 14
                    font.family: colors.widgetIconFont
                }
            }
        }
    }
}
