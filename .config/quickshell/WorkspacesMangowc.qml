import QtQuick

import "."

Row {
    id: tagRow
    required property var colors
    required property string outputName
    required property var tagList
    required property var onTagClicked

    spacing: 6
    leftPadding: 8
    rightPadding: 8
    height: parent ? parent.height : 24

    readonly property int slotWidth: 28

    Repeater {
        model: tagRow.tagList
        delegate: Item {
            readonly property var tag: modelData
            readonly property bool isActive: !!(tag.active)
            readonly property bool occupied: !!(tag.occupied)
            readonly property bool hasUrgent: !!(tag.urgent)

            width: tagRow.slotWidth
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
                Behavior on color { ColorAnimation { duration: 100 } }
                Behavior on border.width { NumberAnimation { duration: 100 } }

                Rectangle {
                    anchors.centerIn: parent
                    width: isActive ? 20 : 12
                    height: 12
                    radius: 6
                    visible: !hasUrgent
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
                    acceptedButtons: Qt.LeftButton
                    onClicked: tagRow.onTagClicked(tag.id)
                }
            }
        }
    }
}
