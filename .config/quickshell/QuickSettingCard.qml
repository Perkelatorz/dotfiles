import QtQuick

import "."

Rectangle {
    id: card
    required property var colors
    required property string icon
    required property string title
    required property string status
    property var onClick: null
    property var paletteColors: null
    property bool enabled: true

    implicitWidth: 168
    implicitHeight: paletteColors && paletteColors.length > 0 ? 66 : 62
    radius: 10
    color: !enabled ? colors.surfaceContainer
        : (cardMa.containsMouse ? colors.surfaceBright : colors.surfaceContainer)
    border.width: 1
    border.color: !enabled ? colors.borderSubtle
        : (cardMa.containsMouse ? colors.border : colors.borderSubtle)
    opacity: enabled ? 1 : 0.65

    Behavior on color { ColorAnimation { duration: 120 } }
    Behavior on border.color { ColorAnimation { duration: 120 } }
    Behavior on opacity { NumberAnimation { duration: 120 } }

    MouseArea {
        id: cardMa
        anchors.fill: parent
        hoverEnabled: enabled
        onClicked: if (enabled && typeof card.onClick === "function") card.onClick()
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
                color: card.enabled ? colors.primary : colors.textDim
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
                    color: card.enabled ? colors.textMain : colors.textDim
                    font.pixelSize: 12
                    font.bold: true
                    elide: Text.ElideRight
                    width: parent.width
                }
                Text {
                    text: card.status
                    color: colors.textDim
                    font.pixelSize: 11
                    width: parent.width
                    wrapMode: Text.Wrap
                    maximumLineCount: 2
                    elide: Text.ElideRight
                    height: Math.max(font.pixelSize * 1.2, Math.min(contentHeight, font.pixelSize * 1.35 * maximumLineCount))
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
