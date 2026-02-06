import QtQuick

import "."

Item {
    id: calOutput
    required property var colors
    required property bool isOpen
    required property string calText

    Rectangle {
        anchors.fill: parent
        visible: isOpen
        color: colors.background
        border.width: 1
        border.color: colors.borderSubtle

        Text {
            anchors.fill: parent
            anchors.margins: 10
            text: calText || "Calendar unavailable"
            color: colors.textMain
            font.pixelSize: colors.clockFontSize - 1
            font.family: "monospace"
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignHCenter
        }
    }
}
