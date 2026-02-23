import QtQuick

import "."

Item {
    id: clipWidget
    required property var colors
    property int pillIndex: 5

    signal toggleRequested()

    readonly property color pillColor: (colors.widgetPillColors && pillIndex >= 0 && pillIndex < colors.widgetPillColors.length) ? colors.widgetPillColors[pillIndex] : colors.primary
    readonly property color pillTextColor: (colors.widgetTextOnPillColors && pillIndex >= 0 && pillIndex < colors.widgetTextOnPillColors.length) ? colors.widgetTextOnPillColors[pillIndex] : colors.textMain

    implicitWidth: pill.width
    implicitHeight: 28

    Rectangle {
        id: pill
        height: clipWidget.implicitHeight - colors.widgetPillPaddingV * 2
        width: row.implicitWidth + colors.widgetPillPaddingH * 2
        anchors.verticalCenter: parent.verticalCenter
        radius: colors.widgetPillRadius
        color: mouseArea.pressed ? Qt.darker(clipWidget.pillColor, 1.15) : mouseArea.containsMouse ? Qt.lighter(clipWidget.pillColor, 1.2) : clipWidget.pillColor
        border.width: 1
        border.color: mouseArea.containsMouse ? Qt.lighter(clipWidget.pillColor, 1.4) : clipWidget.pillColor
        scale: mouseArea.pressed ? 0.94 : 1.0
        Behavior on color { ColorAnimation { duration: 100 } }
        Behavior on border.color { ColorAnimation { duration: 100 } }
        Behavior on scale { NumberAnimation { duration: 80; easing.type: Easing.OutCubic } }

        MouseArea {
            id: mouseArea
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            acceptedButtons: Qt.LeftButton
            onClicked: clipWidget.toggleRequested()
            Row {
                id: row
                anchors.centerIn: parent
                spacing: 0
                leftPadding: colors.widgetPillPaddingH
                rightPadding: colors.widgetPillPaddingH
                Text {
                    text: "\uF328"
                    color: clipWidget.pillTextColor
                    font.pixelSize: colors.cpuFontSize
                    font.family: colors.widgetIconFont
                }
            }
        }
    }
}
