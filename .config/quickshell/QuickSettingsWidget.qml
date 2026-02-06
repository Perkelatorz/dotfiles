import QtQuick

import "."

Item {
    id: quickSettingsWidget
    required property var colors
    property int pillIndex: 1

    signal menuToggleRequested()

    readonly property color pillColor: (colors.widgetPillColors && pillIndex >= 0 && pillIndex < colors.widgetPillColors.length) ? colors.widgetPillColors[pillIndex] : colors.primary
    readonly property color pillTextColor: (colors.widgetTextOnPillColors && pillIndex >= 0 && pillIndex < colors.widgetPillColors.length) ? colors.widgetTextOnPillColors[pillIndex] : colors.textMain

    implicitWidth: pill.width
    implicitHeight: 28

    Rectangle {
        id: pill
        height: quickSettingsWidget.implicitHeight - (colors.widgetPillPaddingV) * 2
        width: row.implicitWidth + (colors.widgetPillPaddingH) * 2
        anchors.verticalCenter: parent.verticalCenter
        radius: colors.widgetPillRadius
        color: quickSettingsWidget.pillColor
        border.width: 1
        border.color: quickSettingsWidget.pillColor

        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            onClicked: quickSettingsWidget.menuToggleRequested()
            Row {
                id: row
                anchors.centerIn: parent
                spacing: 4
                leftPadding: colors.widgetPillPaddingH
                rightPadding: colors.widgetPillPaddingH
                Text {
                    text: "\uF2B9"
                    color: quickSettingsWidget.pillTextColor
                    font.pixelSize: colors.cpuFontSize
                    font.family: colors.widgetIconFont
                }
                Text {
                    text: "QS"
                    color: quickSettingsWidget.pillTextColor
                    font.pixelSize: colors.cpuFontSize
                }
            }
        }
    }
}
