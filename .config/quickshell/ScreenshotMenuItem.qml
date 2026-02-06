import QtQuick

import "."

Row {
    id: itemRow
    required property string label
    required property string icon
    required property var colors
    required property var onClicked

    height: 28
    spacing: 8
    leftPadding: 8
    rightPadding: 8

    MouseArea {
        id: ma
        anchors.fill: parent
        hoverEnabled: true
        onClicked: itemRow.onClicked()
        Rectangle {
            anchors.fill: parent
            radius: 4
            color: ma.containsMouse ? itemRow.colors.surfaceBright : "transparent"
        }
        Text {
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            leftPadding: 8
            text: itemRow.icon
            color: itemRow.colors.textMain
            font.pixelSize: 12
            font.family: itemRow.colors.widgetIconFont
        }
        Text {
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            leftPadding: 28
            text: itemRow.label
            color: itemRow.colors.textMain
            font.pixelSize: itemRow.colors.clockFontSize
        }
    }
}
