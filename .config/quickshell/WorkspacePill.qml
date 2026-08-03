import QtQuick
import Quickshell

import "."

// One workspace/tag indicator. Purely presentational: it takes already-resolved
// booleans and a plain client array, so Hyprland workspaces and mango tags can
// both feed it without this file knowing which compositor is running.
// Client entries only need { class, title }.
Item {
    id: pill

    required property var colors
    required property bool isActive
    required property bool isFocused
    required property bool hasUrgent
    required property bool occupied
    property var wsClients: []

    property int maxAppIndicators: 5
    property int appIconSize: 18
    property int slotPadding: 6

    signal activated()

    readonly property int displayCount: Math.min(wsClients.length, maxAppIndicators)
    readonly property int slotWidth: displayCount > 0
        ? slotPadding * 2 + displayCount * (appIconSize + 2) + (displayCount - 1) * 2
        : 28

    width: slotWidth
    height: 24

    Rectangle {
        anchors.fill: parent
        radius: 6
        border.width: pill.isFocused ? 1 : 0
        border.color: pill.colors.primary
        color: {
            if (pill.hasUrgent) return pill.colors.urgent
            if (!pill.isActive && !wsMouse.containsMouse) return "transparent"
            if (!pill.isActive && wsMouse.containsMouse) return pill.colors.borderSubtle
            return pill.isFocused ? pill.colors.primary : pill.colors.surfaceContainer
        }
        scale: wsMouse.pressed ? 0.90 : 1.0
        Behavior on color { ColorAnimation { duration: 100 } }
        Behavior on border.width { NumberAnimation { duration: 100 } }
        Behavior on scale { NumberAnimation { duration: 80; easing.type: Easing.OutCubic } }

        Row {
            anchors.centerIn: parent
            spacing: 2
            layoutDirection: Qt.LeftToRight
            Repeater {
                model: pill.displayCount
                delegate: Item {
                    width: pill.appIconSize + 2
                    height: pill.appIconSize + 2
                    anchors.verticalCenter: parent ? parent.verticalCenter : undefined
                    readonly property var client: pill.wsClients[index]
                    readonly property string letter: {
                        if (!client) return "?"
                        var s = (client.class || client.title || "?").toString().trim()
                        return (s.charAt(0) || "?").toUpperCase()
                    }
                    readonly property string iconPath: (client && client.class) ? Quickshell.iconPath(String(client.class).toLowerCase(), true) : ""
                    readonly property bool hasIcon: iconPath !== ""
                    readonly property color badgeColor: {
                        var arr = pill.colors.workspaceSlotColors || [pill.colors.surfaceBright]
                        var i = index % Math.max(1, arr.length)
                        return arr[i] || pill.colors.surfaceBright
                    }
                    readonly property color badgeOnColor: {
                        var arr = pill.colors.workspaceSlotOnColors || [pill.colors.textMain]
                        var i = index % Math.max(1, arr.length)
                        return arr[i] || pill.colors.textMain
                    }
                    readonly property color letterColor: badgeOnColor !== badgeColor ? badgeOnColor : pill.colors.textMain
                    Rectangle {
                        anchors.centerIn: parent
                        width: pill.appIconSize
                        height: pill.appIconSize
                        radius: width / 2
                        color: badgeColor
                        border.width: 1
                        border.color: pill.isActive ? (pill.colors.textOnPrimary || pill.colors.textMain) : pill.colors.borderSubtle
                        Text {
                            anchors.centerIn: parent
                            text: letter
                            color: letterColor
                            font.pixelSize: Math.max(9, pill.appIconSize - 5)
                            font.bold: true
                            z: 0
                        }
                        Image {
                            anchors.centerIn: parent
                            width: pill.appIconSize - 2
                            height: pill.appIconSize - 2
                            source: iconPath
                            sourceSize.width: pill.appIconSize - 2
                            sourceSize.height: pill.appIconSize - 2
                            visible: hasIcon && source !== "" && status === Image.Ready
                            smooth: true
                            mipmap: true
                            z: 1
                        }
                    }
                }
            }
        }

        Rectangle {
            anchors.centerIn: parent
            width: pill.isActive ? 20 : 12
            height: 12
            radius: 6
            visible: pill.displayCount === 0 && !pill.hasUrgent
            color: pill.occupied ? (pill.isActive ? pill.colors.textOnPrimary : pill.colors.textMain) : "transparent"
            border.width: pill.occupied ? 0 : 1
            border.color: pill.isActive ? pill.colors.textOnPrimary : pill.colors.border
            Behavior on width { NumberAnimation { duration: 120 } }
        }
        Text {
            anchors.centerIn: parent
            visible: pill.hasUrgent
            text: "!"
            color: pill.colors.textOnUrgent
            font.pixelSize: 14
            font.bold: true
            font.family: pill.colors.fontMain || "sans-serif"
        }

        MouseArea {
            id: wsMouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            acceptedButtons: Qt.LeftButton
            onClicked: pill.activated()
        }
    }
}
