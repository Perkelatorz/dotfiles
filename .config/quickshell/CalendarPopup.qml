import QtQuick

import "."

Item {
    id: calendarPopup
    required property var colors
    required property bool isOpen
    required property string title
    required property var days
    required property int todayDay
    required property bool isCurrentMonth

    signal previousMonthRequested()
    signal nextMonthRequested()

    readonly property int gridWidth: 7 * 28
    readonly property int gridHeight: 7 * 24
    readonly property int padding: 6
    readonly property int titleHeight: 18
    readonly property int contentWidth: gridWidth + padding * 2
    readonly property int contentHeight: padding * 2 + titleHeight + 4 + gridHeight

    width: contentWidth
    height: isOpen ? contentHeight : 0
    visible: isOpen

    Rectangle {
        anchors.fill: parent
        visible: isOpen
        color: colors.background
        border.width: 1
        border.color: colors.borderSubtle

        Column {
            anchors.fill: parent
            anchors.margins: padding
            spacing: 4

            Row {
                width: parent.width - padding * 2
                height: titleHeight
                spacing: 4
                layoutDirection: Qt.LeftToRight

                Item {
                    width: 24
                    height: parent.height
                    MouseArea {
                        anchors.fill: parent
                        onClicked: calendarPopup.previousMonthRequested()
                        Text {
                            anchors.centerIn: parent
                            text: "‹"
                            color: colors.textMain
                            font.pixelSize: colors.clockFontSize + 4
                        }
                    }
                }

                Text {
                    width: parent.width - 24 - 24 - parent.spacing * 2
                    height: parent.height
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    text: title
                    color: colors.textMain
                    font.pixelSize: colors.clockFontSize + 2
                    font.bold: true
                }

                Item {
                    width: 24
                    height: parent.height
                    MouseArea {
                        anchors.fill: parent
                        onClicked: calendarPopup.nextMonthRequested()
                        Text {
                            anchors.centerIn: parent
                            text: "›"
                            color: colors.textMain
                            font.pixelSize: colors.clockFontSize + 4
                        }
                    }
                }
            }

            Item {
                width: gridWidth
                height: gridHeight
                anchors.horizontalCenter: parent.horizontalCenter

                Repeater {
                    model: 49
                    delegate: Item {
                        x: (index % 7) * 28
                        y: Math.floor(index / 7) * 24
                        width: 24
                        height: 22

                        readonly property int dayNum: index >= 7 ? (days[index - 7] || 0) : 0
                        readonly property bool isToday: calendarPopup.isCurrentMonth && dayNum > 0 && dayNum === calendarPopup.todayDay

                        Rectangle {
                            anchors.centerIn: parent
                            width: 20
                            height: 18
                            radius: 4
                            color: parent.isToday ? (colors.primary) : "transparent"
                            visible: parent.isToday
                        }

                        Text {
                            anchors.centerIn: parent
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            text: index < 7 ? ["S", "M", "T", "W", "T", "F", "S"][index] : (dayNum > 0 ? dayNum : "")
                            color: index < 7 ? colors.borderSubtle : colors.textMain
                            font.pixelSize: colors.clockFontSize - 2
                            z: 1
                        }
                    }
                }
            }
        }
    }
}
