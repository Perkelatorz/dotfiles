import QtQuick
import Quickshell

import "."

Item {
    id: powerMenuWidget
    required property var colors
    property int pillIndex: 3

    readonly property color pillColor: (colors.widgetPillColors && pillIndex >= 0 && pillIndex < colors.widgetPillColors.length) ? colors.widgetPillColors[pillIndex] : colors.surfaceContainer
    readonly property color pillTextColor: (colors.widgetTextOnPillColors && pillIndex >= 0 && pillIndex < colors.widgetTextOnPillColors.length) ? colors.widgetTextOnPillColors[pillIndex] : colors.textMain

    signal menuToggleRequested()

    implicitWidth: pill.width
    implicitHeight: 28

    Rectangle {
        id: pill
        height: powerMenuWidget.implicitHeight - (colors.widgetPillPaddingV) * 2
        width: row.implicitWidth + (colors.widgetPillPaddingH) * 2
        anchors.verticalCenter: parent.verticalCenter
        radius: colors.widgetPillRadius
        color: powerMenuWidget.pillColor
        border.width: 1
        border.color: powerMenuWidget.pillColor

        MouseArea {
            anchors.fill: parent
            onClicked: powerMenuWidget.menuToggleRequested()
            Row {
                id: row
                anchors.centerIn: parent
                spacing: 4
                Text {
                    text: "\uF011"
                    color: powerMenuWidget.pillTextColor
                    font.pixelSize: colors.clockFontSize
                    font.family: colors.widgetIconFont
                }
            }
        }
    }
}
