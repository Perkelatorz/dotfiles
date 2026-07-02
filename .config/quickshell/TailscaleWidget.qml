import QtQuick
import Quickshell.Io

import "."

// Tailscale connection status. Green dot + IP when up. Click copies IP.
// Hidden when tailscaled not installed.
Item {
    id: tsWidget
    required property var colors
    property int pillIndex: 1
    property bool connected: false
    property string ipAddress: ""
    property string hostname: ""
    property string backendState: ""
    property bool installed: true

    readonly property color pillColor: (colors.widgetPillColors && pillIndex >= 0 && pillIndex < colors.widgetPillColors.length) ? colors.widgetPillColors[pillIndex] : colors.primary
    readonly property color pillTextColor: (colors.widgetTextOnPillColors && pillIndex >= 0 && pillIndex < colors.widgetTextOnPillColors.length) ? colors.widgetTextOnPillColors[pillIndex] : colors.textMain
    readonly property color dotColor: connected ? "#3dd57e" : "#ff5c5c"

    implicitWidth: installed ? pill.width : 0
    implicitHeight: installed ? 28 : 0
    visible: installed

    PollingProcess {
        command: ["sh", "-c", "command -v tailscale >/dev/null && tailscale status --json 2>/dev/null || echo MISSING"]
        interval: 30000
        active: tsWidget.visible
        onOutput: (text) => {
            var s = (text || "").trim()
            if (s === "MISSING" || s === "") {
                tsWidget.installed = false
                return
            }
            tsWidget.installed = true
            try {
                var obj = JSON.parse(s)
                tsWidget.backendState = obj.BackendState || ""
                tsWidget.connected = (obj.BackendState === "Running") && obj.Self && obj.Self.Online === true
                if (obj.Self && Array.isArray(obj.Self.TailscaleIPs) && obj.Self.TailscaleIPs.length > 0) {
                    tsWidget.ipAddress = String(obj.Self.TailscaleIPs[0])
                }
                if (obj.Self && obj.Self.HostName) tsWidget.hostname = String(obj.Self.HostName)
            } catch (_) {
                tsWidget.connected = false
            }
        }
    }

    property bool _copied: false
    Timer { id: copiedTimer; interval: 1500; onTriggered: tsWidget._copied = false }

    Process {
        id: copyProc
        command: []
        running: false
    }

    Rectangle {
        id: pill
        height: tsWidget.implicitHeight - colors.widgetPillPaddingV * 2
        width: row.implicitWidth + colors.widgetPillPaddingH * 2
        anchors.verticalCenter: parent.verticalCenter
        radius: colors.widgetPillRadius
        color: mouseArea.pressed ? Qt.darker(tsWidget.pillColor, 1.15) : mouseArea.containsMouse ? Qt.lighter(tsWidget.pillColor, 1.2) : tsWidget.pillColor
        border.width: 1
        border.color: mouseArea.containsMouse ? Qt.lighter(tsWidget.pillColor, 1.4) : tsWidget.pillColor
        scale: mouseArea.pressed ? 0.94 : 1.0
        Behavior on color { ColorAnimation { duration: 100 } }
        Behavior on border.color { ColorAnimation { duration: 100 } }
        Behavior on scale { NumberAnimation { duration: 80; easing.type: Easing.OutCubic } }

        MouseArea {
            id: mouseArea
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: {
                if (!tsWidget.ipAddress) return
                copyProc.command = ["wl-copy", tsWidget.ipAddress]
                copyProc.running = true
                tsWidget._copied = true
                copiedTimer.restart()
            }
        }

        Row {
            id: row
            anchors.centerIn: parent
            spacing: 4

            Rectangle {
                anchors.verticalCenter: parent.verticalCenter
                width: 8
                height: 8
                radius: 4
                color: tsWidget.dotColor
            }
            Text {
                anchors.verticalCenter: parent.verticalCenter
                text: tsWidget.connected ? (tsWidget.ipAddress || "tailscale") : (tsWidget.backendState || "off")
                color: tsWidget.pillTextColor
                font.pixelSize: colors.cpuFontSize
            }
        }

        Rectangle {
            opacity: mouseArea.containsMouse ? 1 : 0
            visible: opacity > 0
            Behavior on opacity { NumberAnimation { duration: 150; easing.type: Easing.OutCubic } }
            anchors.bottom: parent.top
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottomMargin: 4
            width: tip.implicitWidth + 12
            height: tip.implicitHeight + 6
            radius: 4
            color: colors.surface
            border.width: 1
            border.color: colors.border
            z: 1000
            Text {
                id: tip
                anchors.centerIn: parent
                text: tsWidget._copied
                    ? "Copied " + tsWidget.ipAddress
                    : (tsWidget.connected
                        ? (tsWidget.hostname + " — click to copy IP")
                        : ("Tailscale: " + (tsWidget.backendState || "unknown")))
                color: colors.textMain
                font.pixelSize: colors.fontSize - 1
            }
        }
    }
}
