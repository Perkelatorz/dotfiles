import QtQuick
import Quickshell.Io

import "."

Item {
    id: networkWidget
    required property var colors
    property int pillIndex: 5

    readonly property color pillColor: (colors.widgetPillColors && pillIndex >= 0 && pillIndex < colors.widgetPillColors.length) ? colors.widgetPillColors[pillIndex] : colors.primary
    readonly property color pillTextColor: (colors.widgetTextOnPillColors && pillIndex >= 0 && pillIndex < colors.widgetTextOnPillColors.length) ? colors.widgetTextOnPillColors[pillIndex] : colors.textMain

    property string connectionName: ""
    property bool isWifi: false

    implicitWidth: pill.width
    implicitHeight: 28

    Process {
        id: nmProc
        command: ["sh", "-c", "if nmcli -t -f ACTIVE,NAME,TYPE dev status 2>/dev/null | grep -q '^yes:'; then nmcli -t -f ACTIVE,NAME,TYPE dev status | grep '^yes:' | head -1; else echo ''; fi"]
        stdout: StdioCollector {
            onStreamFinished: {
                var line = (nmProc.stdout.text || "").trim()
                if (line) {
                    var parts = line.split(":")
                    networkWidget.connectionName = parts.length >= 2 ? parts[1] : "Connected"
                    networkWidget.isWifi = parts.length >= 3 && String(parts[2]).toLowerCase().indexOf("wifi") >= 0
                } else {
                    networkWidget.connectionName = ""
                }
                nmProc.running = false
            }
        }
    }

    Timer {
        interval: 30000
        repeat: true
        running: true
        onTriggered: nmProc.running = true
    }

    Component.onCompleted: nmProc.running = true

    Rectangle {
        id: pill
        height: networkWidget.implicitHeight - (colors.widgetPillPaddingV) * 2
        width: row.implicitWidth + (colors.widgetPillPaddingH) * 2
        anchors.verticalCenter: parent.verticalCenter
        radius: colors.widgetPillRadius
        color: networkWidget.pillColor
        border.width: 1
        border.color: networkWidget.pillColor

        MouseArea {
            anchors.fill: parent
            onClicked: runConnEditor.running = true
            Row {
                id: row
                anchors.centerIn: parent
                spacing: 4
                Text {
                    text: networkWidget.isWifi ? "\uF1EB" : "\uF0AC"
                    color: networkWidget.pillTextColor
                    font.pixelSize: colors.cpuFontSize
                    font.family: colors.widgetIconFont
                }
                Text {
                    text: networkWidget.connectionName || "No network"
                    color: networkWidget.pillTextColor
                    font.pixelSize: colors.cpuFontSize
                    elide: Text.ElideRight
                    width: Math.min(implicitWidth, 120)
                }
            }
        }
    }

    Process {
        id: runConnEditor
        command: ["nm-connection-editor"]
        running: false
    }
}
