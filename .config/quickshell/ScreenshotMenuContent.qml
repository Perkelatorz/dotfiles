import QtQuick

import "."

Column {
    id: screenshotMenuContent
    required property var colors
    required property var onClose
    required property var screenshotWidget

    spacing: 0
    width: 160
    padding: 4

    function runAndClose(mode) {
        if (screenshotWidget) {
            if (mode === "fullscreen") screenshotWidget.takeFullscreen()
            else if (mode === "select") screenshotWidget.takeSelect()
            else if (mode === "last") screenshotWidget.takeLast()
        }
        screenshotMenuContent.onClose()
    }

    Repeater {
        model: [
            { label: "Fullscreen", icon: "\uF0B2", mode: "fullscreen" },
            { label: "Select region", icon: "\uF030", mode: "select" },
            { label: "Same as last", icon: "\uF01E", mode: "last" }
        ]
        delegate: MouseArea {
            id: ma
            width: screenshotMenuContent.width - 8
            height: 28
            hoverEnabled: true
            onClicked: screenshotMenuContent.runAndClose(modelData.mode)
            Rectangle {
                anchors.fill: parent
                radius: 4
                color: ma.containsMouse ? colors.surfaceBright : "transparent"
            }
            Row {
                anchors.verticalCenter: parent.verticalCenter
                leftPadding: 8
                spacing: 8
                Text {
                    text: modelData.icon
                    color: colors.textMain
                    font.pixelSize: 12
                    font.family: colors.widgetIconFont
                }
                Text {
                    text: modelData.label
                    color: colors.textMain
                    font.pixelSize: colors.clockFontSize
                }
            }
        }
    }
}
