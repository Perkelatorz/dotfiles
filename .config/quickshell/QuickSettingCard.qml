import QtQuick

import "."

Rectangle {
    id: card
    required property var colors
    required property string icon
    required property string title
    required property string status
    property var onClick: null
    property var onRightClick: null
    property var paletteColors: null
    property bool enabled: true
    property bool active: false
    property real progress: -1

    readonly property bool hasProgress: progress >= 0
    readonly property bool hasPalette: paletteColors != null && paletteColors.length > 0

    implicitWidth: 168
    implicitHeight: hasPalette ? 66 : (hasProgress ? 70 : 62)
    radius: 10
    color: {
        if (!enabled) return colors.surfaceContainer
        if (cardMa.pressed) return active ? Qt.darker(colors.primaryContainer, 1.15) : Qt.darker(colors.surfaceBright, 1.1)
        if (active) return cardMa.containsMouse ? Qt.lighter(colors.primaryContainer, 1.1) : colors.primaryContainer
        return cardMa.containsMouse ? colors.surfaceBright : colors.surfaceContainer
    }
    border.width: 1
    border.color: {
        if (!enabled) return colors.borderSubtle
        if (active) return cardMa.containsMouse ? colors.primary : Qt.darker(colors.primary, 1.3)
        return cardMa.containsMouse ? colors.border : colors.borderSubtle
    }
    opacity: enabled ? 1 : 0.65
    scale: cardMa.pressed ? 0.96 : 1.0

    Behavior on color { ColorAnimation { duration: 120 } }
    Behavior on border.color { ColorAnimation { duration: 120 } }
    Behavior on opacity { NumberAnimation { duration: 120 } }
    Behavior on scale { NumberAnimation { duration: 80; easing.type: Easing.OutCubic } }

    MouseArea {
        id: cardMa
        anchors.fill: parent
        hoverEnabled: enabled
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        cursorShape: enabled && (typeof card.onClick === "function" || typeof card.onRightClick === "function") ? Qt.PointingHandCursor : Qt.ArrowCursor
        onClicked: function(mouse) {
            if (!enabled) return
            if (mouse.button === Qt.RightButton && typeof card.onRightClick === "function")
                card.onRightClick()
            else if (typeof card.onClick === "function")
                card.onClick()
        }
    }

    Column {
        anchors.fill: parent
        anchors.margins: 10
        spacing: hasPalette ? 4 : (hasProgress ? 4 : 0)
        Row {
            width: parent.width - 20
            spacing: 10
            Text {
                text: card.icon
                color: active ? colors.textOnPrimaryContainer : (card.enabled ? colors.primary : colors.textDim)
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
                    color: active ? colors.textOnPrimaryContainer : (card.enabled ? colors.textMain : colors.textDim)
                    font.pixelSize: 12
                    font.bold: true
                    elide: Text.ElideRight
                    width: parent.width
                }
                Text {
                    text: card.status
                    color: active ? Qt.darker(colors.textOnPrimaryContainer, 1.2) : colors.textDim
                    font.pixelSize: 11
                    width: parent.width
                    wrapMode: Text.Wrap
                    maximumLineCount: 2
                    elide: Text.ElideRight
                    height: Math.max(font.pixelSize * 1.2, Math.min(contentHeight, font.pixelSize * 1.35 * maximumLineCount))
                }
            }
        }
        Rectangle {
            visible: hasProgress
            width: parent.width
            height: 4
            radius: 2
            color: active ? Qt.darker(colors.primaryContainer, 1.3) : colors.surfaceBright
            Rectangle {
                width: parent.width * Math.min(1, Math.max(0, card.progress))
                height: parent.height
                radius: 2
                color: {
                    if (card.progress > 0.9) return colors.error
                    if (card.progress > 0.75) return colors.tertiary
                    return active ? colors.textOnPrimaryContainer : colors.primary
                }
                Behavior on width { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }
                Behavior on color { ColorAnimation { duration: 200 } }
            }
        }
        Row {
            visible: hasPalette
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
