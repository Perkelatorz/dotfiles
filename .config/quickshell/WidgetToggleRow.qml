import QtQuick

import "."

Row {
    id: toggleRow
    required property bool isOn
    required property var onToggle
    required property string label
    required property string icon
    required property var colors

    width: 140
    height: 28
    spacing: 6

    Text {
        text: toggleRow.icon
        color: toggleRow.colors.textMain
        font.pixelSize: 14
        font.family: toggleRow.colors.widgetIconFont
        anchors.verticalCenter: parent.verticalCenter
        width: 20
    }
    Text {
        text: toggleRow.label
        color: toggleRow.colors.textMain
        font.pixelSize: toggleRow.colors.clockFontSize
        anchors.verticalCenter: parent.verticalCenter
        width: parent.width - 20 - 6 - 36
        elide: Text.ElideRight
    }
    Rectangle {
        width: 32
        height: 18
        radius: 9
        anchors.verticalCenter: parent.verticalCenter
        color: toggleRow.isOn ? toggleRow.colors.primary : toggleRow.colors.surfaceBright
        border.width: 1
        border.color: toggleRow.colors.borderSubtle
        MouseArea {
            anchors.fill: parent
            onClicked: toggleRow.onToggle()
        }
        Rectangle {
            width: 14
            height: 14
            radius: 7
            anchors.verticalCenter: parent.verticalCenter
            x: toggleRow.isOn ? parent.width - width - 2 : 2
            color: toggleRow.colors.textMain
            Behavior on x { NumberAnimation { duration: 100 } }
        }
    }
}
