import QtQuick

import "."

Item {
    id: settingsMenuContent
    required property var colors
    required property var onClose
    required property var settingsState

    implicitWidth: 320
    implicitHeight: 360

    Rectangle {
        anchors.fill: parent
        radius: 8
        color: colors.surfaceContainer
        border.width: 1
        border.color: colors.border

        Column {
            id: mainColumn
            anchors.fill: parent
            anchors.margins: 10
            spacing: 8

            Row {
                width: parent.width - 20
                height: 28
                Item {
                    width: 24
                    height: parent.height
                    MouseArea {
                        anchors.fill: parent
                        onClicked: settingsMenuContent.onClose()
                        Text {
                            anchors.centerIn: parent
                            text: "\uF00D"
                            color: colors.textDim
                            font.pixelSize: 14
                            font.family: colors.widgetIconFont
                        }
                        hoverEnabled: true
                    }
                }
                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text: "Widgets & settings"
                    color: colors.primary
                    font.pixelSize: colors.clockFontSize + 1
                    font.bold: true
                }
            }

            Text {
                text: "Bar widgets"
                color: colors.textDim
                font.pixelSize: colors.clockFontSize - 1
            }

            Grid {
                id: widgetGrid
                width: parent.width - 20
                columns: 2
                rowSpacing: 4
                columnSpacing: 8

                WidgetToggleRow { isOn: settingsState.volumeWidgetVisible; onToggle: function() { settingsState.volumeWidgetVisible = !settingsState.volumeWidgetVisible; if (settingsState.saveWidgetVisibility) settingsState.saveWidgetVisibility() }; label: "Volume"; icon: "\uF028"; colors: settingsMenuContent.colors }
                WidgetToggleRow { isOn: settingsState.nowPlayingWidgetVisible; onToggle: function() { settingsState.nowPlayingWidgetVisible = !settingsState.nowPlayingWidgetVisible; if (settingsState.saveWidgetVisibility) settingsState.saveWidgetVisibility() }; label: "Now playing"; icon: "\uF001"; colors: settingsMenuContent.colors }
                WidgetToggleRow { isOn: settingsState.performanceWidgetVisible; onToggle: function() { settingsState.performanceWidgetVisible = !settingsState.performanceWidgetVisible; if (settingsState.saveWidgetVisibility) settingsState.saveWidgetVisibility() }; label: "Performance"; icon: "\uF2DB"; colors: settingsMenuContent.colors }
                WidgetToggleRow { isOn: settingsState.batteryWidgetVisible; onToggle: function() { settingsState.batteryWidgetVisible = !settingsState.batteryWidgetVisible; if (settingsState.saveWidgetVisibility) settingsState.saveWidgetVisibility() }; label: "Battery"; icon: "\uF240"; colors: settingsMenuContent.colors }
                WidgetToggleRow { isOn: settingsState.brightnessWidgetVisible; onToggle: function() { settingsState.brightnessWidgetVisible = !settingsState.brightnessWidgetVisible; if (settingsState.saveWidgetVisibility) settingsState.saveWidgetVisibility() }; label: "Brightness"; icon: "\uF185"; colors: settingsMenuContent.colors }
                WidgetToggleRow { isOn: settingsState.microphoneWidgetVisible; onToggle: function() { settingsState.microphoneWidgetVisible = !settingsState.microphoneWidgetVisible; if (settingsState.saveWidgetVisibility) settingsState.saveWidgetVisibility() }; label: "Microphone"; icon: "\uF3A5"; colors: settingsMenuContent.colors }
                WidgetToggleRow { isOn: settingsState.ipAddressWidgetVisible; onToggle: function() { settingsState.ipAddressWidgetVisible = !settingsState.ipAddressWidgetVisible; if (settingsState.saveWidgetVisibility) settingsState.saveWidgetVisibility() }; label: "IP address"; icon: "\uF0AC"; colors: settingsMenuContent.colors }
                WidgetToggleRow { isOn: settingsState.screenshotWidgetVisible; onToggle: function() { settingsState.screenshotWidgetVisible = !settingsState.screenshotWidgetVisible; if (settingsState.saveWidgetVisibility) settingsState.saveWidgetVisibility() }; label: "Screenshot"; icon: "\uF030"; colors: settingsMenuContent.colors }
                WidgetToggleRow { isOn: settingsState.weatherWidgetVisible; onToggle: function() { settingsState.weatherWidgetVisible = !settingsState.weatherWidgetVisible; if (settingsState.saveWidgetVisibility) settingsState.saveWidgetVisibility() }; label: "Weather"; icon: "\uF0C2"; colors: settingsMenuContent.colors }
                WidgetToggleRow { isOn: settingsState.updatesWidgetVisible; onToggle: function() { settingsState.updatesWidgetVisible = !settingsState.updatesWidgetVisible; if (settingsState.saveWidgetVisibility) settingsState.saveWidgetVisibility() }; label: "Updates"; icon: "\uF49E"; colors: settingsMenuContent.colors }
                WidgetToggleRow { isOn: settingsState.netSpeedWidgetVisible; onToggle: function() { settingsState.netSpeedWidgetVisible = !settingsState.netSpeedWidgetVisible; if (settingsState.saveWidgetVisibility) settingsState.saveWidgetVisibility() }; label: "Net speed"; icon: "\uF0AC"; colors: settingsMenuContent.colors }
                WidgetToggleRow { isOn: settingsState.notificationsWidgetVisible; onToggle: function() { settingsState.notificationsWidgetVisible = !settingsState.notificationsWidgetVisible; if (settingsState.saveWidgetVisibility) settingsState.saveWidgetVisibility() }; label: "Notifications"; icon: "\uF0F3"; colors: settingsMenuContent.colors }
                WidgetToggleRow { isOn: settingsState.powerProfileWidgetVisible; onToggle: function() { settingsState.powerProfileWidgetVisible = !settingsState.powerProfileWidgetVisible; if (settingsState.saveWidgetVisibility) settingsState.saveWidgetVisibility() }; label: "Power profile"; icon: "\uF24E"; colors: settingsMenuContent.colors }
            }
        }
    }
}
