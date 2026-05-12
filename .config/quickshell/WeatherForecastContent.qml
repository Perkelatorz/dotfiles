import QtQuick
import QtQuick.Layouts

import "."

Item {
    id: forecastContent
    required property var colors
    required property var onClose

    implicitWidth: 320
    implicitHeight: column.implicitHeight + 16

    Rectangle {
        anchors.fill: parent
        radius: 8
        color: colors.surfaceContainer
        border.width: 1
        border.color: colors.border

        ColumnLayout {
            id: column
            anchors.fill: parent
            anchors.margins: 12
            spacing: 8

            // Header row: location + close
            RowLayout {
                Layout.fillWidth: true
                spacing: 8
                Text {
                    text: SystemServices.weatherIcon
                    color: colors.primary
                    font.pixelSize: 22
                    font.family: colors.widgetIconFont
                }
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 1
                    Text {
                        text: SystemServices.weatherTemp + " · " + SystemServices.weatherCondition
                        color: colors.textMain
                        font.pixelSize: colors.fontSize + 1
                        font.bold: true
                        elide: Text.ElideRight
                        Layout.fillWidth: true
                    }
                    Text {
                        text: SystemServices.weatherLocationName || "Auto location"
                        color: colors.textDim
                        font.pixelSize: colors.fontSize - 1
                        elide: Text.ElideRight
                        Layout.fillWidth: true
                    }
                }
                MouseArea {
                    id: closeMa
                    width: 22
                    height: 22
                    hoverEnabled: true
                    onClicked: forecastContent.onClose()
                    Rectangle {
                        anchors.fill: parent
                        radius: 4
                        color: closeMa.containsMouse ? colors.surfaceBright : "transparent"
                        Text {
                            anchors.centerIn: parent
                            text: ""
                            color: colors.textDim
                            font.pixelSize: 11
                            font.family: colors.widgetIconFont
                        }
                    }
                }
            }

            // Current details row
            GridLayout {
                Layout.fillWidth: true
                columns: 3
                rowSpacing: 4
                columnSpacing: 12
                Text {
                    text: "Feels"
                    color: colors.textDim
                    font.pixelSize: colors.fontSize - 1
                }
                Text {
                    text: "Humidity"
                    color: colors.textDim
                    font.pixelSize: colors.fontSize - 1
                }
                Text {
                    text: "Wind"
                    color: colors.textDim
                    font.pixelSize: colors.fontSize - 1
                }
                Text {
                    text: SystemServices.weatherFeelsLike || "—"
                    color: colors.textMain
                    font.pixelSize: colors.fontSize
                }
                Text {
                    text: SystemServices.weatherHumidity || "—"
                    color: colors.textMain
                    font.pixelSize: colors.fontSize
                }
                Text {
                    text: SystemServices.weatherWind || "—"
                    color: colors.textMain
                    font.pixelSize: colors.fontSize
                }
            }

            Rectangle {
                Layout.fillWidth: true
                height: 1
                color: colors.borderSubtle
            }

            // 3-day forecast
            Repeater {
                model: SystemServices.weatherForecast || []
                delegate: RowLayout {
                    Layout.fillWidth: true
                    spacing: 12
                    Text {
                        Layout.preferredWidth: 80
                        text: {
                            if (!modelData.date) return ""
                            var d = new Date(modelData.date)
                            if (isNaN(d.getTime())) return modelData.date
                            if (index === 0) return "Today"
                            if (index === 1) return "Tomorrow"
                            return d.toLocaleDateString(Qt.locale(), "ddd MMM d")
                        }
                        color: colors.textMain
                        font.pixelSize: colors.fontSize
                    }
                    Text {
                        Layout.preferredWidth: 22
                        text: modelData.icon || ""
                        color: colors.tertiary
                        font.pixelSize: colors.fontSize + 2
                        font.family: colors.widgetIconFont
                        horizontalAlignment: Text.AlignHCenter
                    }
                    Text {
                        Layout.fillWidth: true
                        text: modelData.condition || ""
                        color: colors.textDim
                        font.pixelSize: colors.fontSize - 1
                        elide: Text.ElideRight
                    }
                    Text {
                        text: (modelData.high || "?") + "° / " + (modelData.low || "?") + "°"
                        color: colors.textMain
                        font.pixelSize: colors.fontSize
                    }
                }
            }

            Text {
                Layout.fillWidth: true
                visible: !SystemServices.weatherForecast || SystemServices.weatherForecast.length === 0
                text: SystemServices.weatherHasData ? "Loading forecast…" : "Weather unavailable"
                color: colors.textDim
                font.pixelSize: colors.fontSize - 1
                horizontalAlignment: Text.AlignHCenter
            }
        }
    }
}
