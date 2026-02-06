import QtQuick

import "."

Item {
    id: settingsWidget
    required property var colors
    property int pillIndex: 2

    signal menuToggleRequested()

    readonly property color pillColor: (colors.widgetPillColors && pillIndex >= 0 && pillIndex < colors.widgetPillColors.length) ? colors.widgetPillColors[pillIndex] : colors.primary
    readonly property color pillTextColor: (colors.widgetTextOnPillColors && pillIndex >= 0 && pillIndex < colors.widgetTextOnPillColors.length) ? colors.widgetTextOnPillColors[pillIndex] : colors.textMain

    implicitWidth: pill.width
    implicitHeight: 28

    Rectangle {
        id: pill
        height: settingsWidget.implicitHeight - (colors.widgetPillPaddingV) * 2
        width: row.implicitWidth + (colors.widgetPillPaddingH) * 2
        anchors.verticalCenter: parent.verticalCenter
        radius: colors.widgetPillRadius
        color: settingsWidget.pillColor
        border.width: 1
        border.color: settingsWidget.pillColor

        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            onClicked: settingsWidget.menuToggleRequested()
            Row {
                id: row
                anchors.centerIn: parent
                spacing: 4
                leftPadding: colors.widgetPillPaddingH
                rightPadding: colors.widgetPillPaddingH
                Text {
                    text: "\uF013"
                    color: settingsWidget.pillTextColor
                    font.pixelSize: colors.cpuFontSize
                    font.family: colors.widgetIconFont
                }
            }
        }
    }
}
