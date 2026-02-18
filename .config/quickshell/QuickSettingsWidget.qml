import QtQuick

import "."

Item {
    id: quickSettingsWidget
    required property var colors
    property int pillIndex: 5

    signal menuToggleRequested()

    readonly property color pillColor: (colors.widgetPillColors && pillIndex >= 0 && pillIndex < colors.widgetPillColors.length) ? colors.widgetPillColors[pillIndex] : colors.primary
    readonly property color pillTextColor: (colors.widgetTextOnPillColors && pillIndex >= 0 && pillIndex < colors.widgetTextOnPillColors.length) ? colors.widgetTextOnPillColors[pillIndex] : colors.textMain

    implicitWidth: pill.width
    implicitHeight: 28

    Rectangle {
        id: pill
        height: quickSettingsWidget.implicitHeight - (colors.widgetPillPaddingV) * 2
        width: row.implicitWidth + (colors.widgetPillPaddingH) * 2
        anchors.verticalCenter: parent.verticalCenter
        radius: colors.widgetPillRadius
        color: mouseArea.pressed ? Qt.darker(quickSettingsWidget.pillColor, 1.15) : mouseArea.containsMouse ? Qt.lighter(quickSettingsWidget.pillColor, 1.2) : quickSettingsWidget.pillColor
        border.width: 1
        border.color: mouseArea.containsMouse ? Qt.lighter(quickSettingsWidget.pillColor, 1.4) : quickSettingsWidget.pillColor
        scale: mouseArea.pressed ? 0.94 : 1.0
        Behavior on color { ColorAnimation { duration: 100 } }
        Behavior on border.color { ColorAnimation { duration: 100 } }
        Behavior on scale { NumberAnimation { duration: 80; easing.type: Easing.OutCubic } }

        MouseArea {
            id: mouseArea
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: quickSettingsWidget.menuToggleRequested()
            Row {
                id: row
                anchors.centerIn: parent
                spacing: 0
                leftPadding: colors.widgetPillPaddingH
                rightPadding: colors.widgetPillPaddingH
                // Vertical three dots (kebab) — universal "menu / more options" symbol, icon-only for a clean bar
                Text {
                    text: "\uF142"
                    color: quickSettingsWidget.pillTextColor
                    font.pixelSize: colors.cpuFontSize
                    font.family: colors.widgetIconFont
                }
            }
        }
        Rectangle {
            opacity: mouseArea.containsMouse ? 1 : 0
            visible: opacity > 0
            Behavior on opacity { NumberAnimation { duration: 150; easing.type: Easing.OutCubic } }
            anchors.bottom: parent.top
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottomMargin: 4
            width: qsTip.implicitWidth + 12
            height: qsTip.implicitHeight + 6
            radius: 4
            color: colors.surface
            border.width: 1
            border.color: colors.border
            z: 1000
            Text {
                id: qsTip
                anchors.centerIn: parent
                text: "Quick Settings"
                color: colors.textMain
                font.pixelSize: colors.fontSize - 1
            }
        }
    }
}
