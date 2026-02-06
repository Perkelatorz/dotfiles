import QtQuick

import "."

Rectangle {
    id: card
    required property var colors
    required property string icon
    required property string title
    required property string status
    property var onClick: null

    implicitWidth: 140
    implicitHeight: 56
    radius: 8
    color: cardMa.containsMouse ? colors.surfaceBright : colors.surfaceContainer
    border.width: 1
    border.color: colors.borderSubtle

    MouseArea {
        id: cardMa
        anchors.fill: parent
        hoverEnabled: true
        onClicked: if (typeof card.onClick === "function") card.onClick()
    }

    Row {
        anchors.fill: parent
        anchors.margins: 10
        spacing: 10
        Text {
            text: card.icon
            color: colors.primary
            font.pixelSize: 20
            font.family: colors.widgetIconFont
            anchors.verticalCenter: parent.verticalCenter
        }
        Column {
            spacing: 2
            anchors.verticalCenter: parent.verticalCenter
            width: parent.width - 40
            Text {
                text: card.title
                color: colors.textMain
                font.pixelSize: 12
                font.bold: true
                elide: Text.ElideRight
                width: parent.width
            }
            Text {
                text: card.status
                color: colors.textDim
                font.pixelSize: 11
                elide: Text.ElideRight
                width: parent.width
            }
        }
    }
}
