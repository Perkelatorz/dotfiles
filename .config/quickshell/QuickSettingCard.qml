import QtQuick

import "."

Rectangle {
    id: card
    required property var colors
    required property string icon
    required property string title
    required property string status
    property var onClick: null
    /// Optional: array of color values to show as swatches (e.g. [colors.primary, colors.secondary, ...])
    property var paletteColors: null

    implicitWidth: 140
    implicitHeight: paletteColors && paletteColors.length > 0 ? 62 : 56
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

    Column {
        anchors.fill: parent
        anchors.margins: 10
        spacing: paletteColors && paletteColors.length > 0 ? 4 : 0
        Row {
            width: parent.width - 20
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
        Row {
            visible: paletteColors != null && paletteColors.length > 0
            spacing: 2
            Repeater {
                model: visible ? paletteColors : 0
                delegate: Rectangle {
                    width: 10
                    height: 10
                    radius: 5
                    color: modelData
                    border.width: 1
                    border.color: colors.borderSubtle
                }
            }
        }
    }
}
