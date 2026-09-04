import QtQuick
import Quickshell

import "."

// One workspace/tag indicator.
//
//   empty     a 6px dot
//   occupied  the icons of the apps living there
//   focused   the same, on a wash of the accent
//
// The icons are the point — they are how you know which tag holds what without
// switching to it. What they lost in the redesign is the coloured disc that
// used to sit behind each one: workspaceSlotColors put up to five different
// hues inside a single pill, which is what made the left end of the bar shout.
// An app icon is already its own colour and needs no plate under it.
//
// Purely presentational: it takes already-resolved booleans, so it never
// touches compositor state.
Item {
    id: pill

    required property var colors
    required property bool isActive
    required property bool isFocused
    required property bool hasUrgent
    required property bool occupied
    property var wsClients: []

    property int maxAppIndicators: 5
    property int appIconSize: 16
    property int slotPadding: 8

    signal activated()

    readonly property int displayCount: Math.min(wsClients ? wsClients.length : 0, maxAppIndicators)
    readonly property bool expanded: displayCount > 0
    readonly property int dot: 6
    readonly property int iconGap: 4

    readonly property color _accent: hasUrgent ? colors.urgent : colors.primary

    implicitHeight: 22
    implicitWidth: expanded
        ? slotPadding * 2 + displayCount * appIconSize + (displayCount - 1) * iconGap
        : dot

    Rectangle {
        id: ground
        anchors.centerIn: parent
        width: pill.implicitWidth
        height: pill.expanded ? pill.implicitHeight : pill.dot
        radius: pill.expanded ? 8 : pill.dot / 2
        color: {
            var a = pill._accent
            if (pill.hasUrgent) return Qt.rgba(a.r, a.g, a.b, 0.22)
            if (pill.isFocused) return Qt.rgba(a.r, a.g, a.b, 0.18)
            if (wsMouse.containsMouse)
                return Qt.rgba(pill.colors.textMain.r, pill.colors.textMain.g,
                               pill.colors.textMain.b, 0.10)
            if (pill.isActive) return Qt.rgba(a.r, a.g, a.b, 0.08)
            if (pill.expanded)
                return Qt.rgba(pill.colors.textMain.r, pill.colors.textMain.g,
                               pill.colors.textMain.b, 0.05)
            // Collapsed: the dot is the mark.
            return pill.occupied
                ? pill.colors.textMuted
                : Qt.rgba(pill.colors.textMain.r, pill.colors.textMain.g,
                          pill.colors.textMain.b, 0.14)
        }
        Behavior on width  { NumberAnimation { duration: 140; easing.type: Easing.OutCubic } }
        Behavior on height { NumberAnimation { duration: 140; easing.type: Easing.OutCubic } }
        Behavior on color  { ColorAnimation  { duration: 120 } }

        Row {
            anchors.centerIn: parent
            spacing: pill.iconGap
            visible: pill.expanded
            Repeater {
                model: pill.displayCount
                delegate: Item {
                    width: pill.appIconSize
                    height: pill.appIconSize
                    anchors.verticalCenter: parent ? parent.verticalCenter : undefined
                    readonly property var client: pill.wsClients[index]
                    readonly property string iconPath: (client && client.class)
                        ? Quickshell.iconPath(String(client.class).toLowerCase(), true) : ""
                    readonly property bool hasIcon: iconPath !== ""
                    readonly property string letter: {
                        if (!client) return "?"
                        var s = (client.class || client.title || "?").toString().trim()
                        return (s.charAt(0) || "?").toUpperCase()
                    }
                    // Letter fallback, shown only when there is genuinely no icon.
                    Text {
                        anchors.centerIn: parent
                        visible: !parent.hasIcon
                        text: parent.letter
                        color: pill.colors.textDim
                        font.pixelSize: Math.max(9, pill.appIconSize - 6)
                        font.bold: true
                    }
                    Image {
                        anchors.centerIn: parent
                        width: pill.appIconSize
                        height: pill.appIconSize
                        source: parent.iconPath
                        sourceSize.width: pill.appIconSize
                        sourceSize.height: pill.appIconSize
                        // Not `=== Ready`: that blanks the icon for any frame a
                        // reload is in flight, which is visible as a flicker.
                        visible: parent.hasIcon && status !== Image.Error
                        smooth: true
                        mipmap: true
                    }
                }
            }
        }

        Text {
            anchors.centerIn: parent
            visible: pill.hasUrgent && !pill.expanded
            text: "!"
            color: pill.colors.textOnUrgent
            font.pixelSize: 12
            font.bold: true
        }
    }

    MouseArea {
        id: wsMouse
        anchors.fill: parent
        anchors.margins: -4          // a 6px dot is not a hit target
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: pill.activated()
    }
}
