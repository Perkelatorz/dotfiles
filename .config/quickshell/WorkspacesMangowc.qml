import QtQuick
import Quickshell

import "."

Row {
    id: tagRow
    required property var colors
    required property string outputName
    required property var tagList
    required property var onTagClicked
    property var clientList: []

    spacing: 6
    leftPadding: 8
    rightPadding: 8
    height: parent ? parent.height : 24

    readonly property int maxAppIndicators: 5
    readonly property int appIconSize: 18
    readonly property int slotPadding: 6

    Repeater {
        model: tagRow.tagList
        delegate: Item {
            readonly property var tag: modelData
            readonly property bool isActive: !!(tag.active)
            readonly property bool occupied: !!(tag.occupied)
            readonly property bool hasUrgent: !!(tag.urgent)
            readonly property var tagClients: isActive ? tagRow.clientList : []
            readonly property int displayCount: Math.min(tagClients.length, tagRow.maxAppIndicators)
            readonly property int slotWidth: displayCount > 0
                ? tagRow.slotPadding * 2 + displayCount * (tagRow.appIconSize + 2) + (displayCount - 1) * 2
                : 28

            width: slotWidth
            height: 24

            Rectangle {
                anchors.fill: parent
                radius: 6
                border.width: isActive ? 1 : 0
                border.color: colors.primary
                color: {
                    if (hasUrgent) return colors.urgent
                    if (!isActive && !tagMouse.containsMouse) return "transparent"
                    if (!isActive && tagMouse.containsMouse) return colors.borderSubtle
                    return isActive ? colors.primary : colors.surfaceContainer
                }
                scale: tagMouse.pressed ? 0.90 : 1.0
                Behavior on color { ColorAnimation { duration: 100 } }
                Behavior on border.width { NumberAnimation { duration: 100 } }
                Behavior on scale { NumberAnimation { duration: 80; easing.type: Easing.OutCubic } }

                Row {
                    anchors.centerIn: parent
                    spacing: 2
                    layoutDirection: Qt.LeftToRight
                    visible: displayCount > 0
                    Repeater {
                        model: displayCount
                        delegate: Item {
                            width: tagRow.appIconSize + 2
                            height: tagRow.appIconSize + 2
                            anchors.verticalCenter: parent ? parent.verticalCenter : undefined
                            readonly property var client: tagClients[index]
                            readonly property string letter: {
                                if (!client) return "?"
                                var s = (client.class || client.title || "?").toString().trim()
                                return (s.charAt(0) || "?").toUpperCase()
                            }
                            readonly property string iconPath: (client && client.class) ? Quickshell.iconPath(String(client.class).toLowerCase(), true) : ""
                            readonly property bool hasIcon: iconPath !== ""
                            readonly property color badgeColor: {
                                var arr = colors.workspaceSlotColors || [colors.surfaceBright]
                                var i = index % Math.max(1, arr.length)
                                return arr[i] || colors.surfaceBright
                            }
                            readonly property color badgeOnColor: {
                                var arr = colors.workspaceSlotOnColors || [colors.textMain]
                                var i = index % Math.max(1, arr.length)
                                return arr[i] || colors.textMain
                            }
                            readonly property color letterColor: badgeOnColor !== badgeColor ? badgeOnColor : colors.textMain
                            Rectangle {
                                anchors.centerIn: parent
                                width: tagRow.appIconSize
                                height: tagRow.appIconSize
                                radius: width / 2
                                color: badgeColor
                                border.width: 1
                                border.color: isActive ? (colors.textOnPrimary || colors.textMain) : colors.borderSubtle
                                Text {
                                    anchors.centerIn: parent
                                    text: letter
                                    color: letterColor
                                    font.pixelSize: Math.max(9, tagRow.appIconSize - 5)
                                    font.bold: true
                                    z: 0
                                }
                                Image {
                                    anchors.centerIn: parent
                                    width: tagRow.appIconSize - 2
                                    height: tagRow.appIconSize - 2
                                    source: iconPath
                                    sourceSize.width: tagRow.appIconSize - 2
                                    sourceSize.height: tagRow.appIconSize - 2
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
                    width: isActive ? 20 : 12
                    height: 12
                    radius: 6
                    visible: displayCount === 0 && !hasUrgent
                    color: occupied ? (isActive ? colors.textOnPrimary : colors.textMain) : "transparent"
                    border.width: occupied ? 0 : 1
                    border.color: isActive ? colors.textOnPrimary : colors.border
                    Behavior on width { NumberAnimation { duration: 120 } }
                }
                Text {
                    anchors.centerIn: parent
                    visible: hasUrgent
                    text: "!"
                    color: colors.textOnUrgent
                    font.pixelSize: 14
                    font.bold: true
                    font.family: colors.fontMain || "sans-serif"
                }

                MouseArea {
                    id: tagMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    acceptedButtons: Qt.LeftButton
                    onClicked: tagRow.onTagClicked(tag.id)
                }
            }
        }
    }
}
