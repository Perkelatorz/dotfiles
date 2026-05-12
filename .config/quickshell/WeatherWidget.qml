import QtQuick
import Quickshell.Io

import "."

Item {
    id: weatherWidget
    required property var colors
    property int pillIndex: 0

    signal openForecastRequested()

    readonly property color pillColor: (colors.widgetPillColors && pillIndex >= 0 && pillIndex < colors.widgetPillColors.length) ? colors.widgetPillColors[pillIndex] : colors.primary
    readonly property color pillTextColor: (colors.widgetTextOnPillColors && pillIndex >= 0 && pillIndex < colors.widgetTextOnPillColors.length) ? colors.widgetTextOnPillColors[pillIndex] : colors.textMain

    readonly property string temperature: SystemServices.weatherTemp
    readonly property string condition: SystemServices.weatherCondition
    readonly property string location: SystemServices.weatherLocationName
    readonly property bool hasData: SystemServices.weatherHasData

    implicitWidth: hasData ? pill.width : 0
    implicitHeight: hasData ? 28 : 0
    visible: hasData

    readonly property var conditionIcons: ({
        "Clear": "",
        "Sunny": "",
        "Partly cloudy": "",
        "Partly Cloudy": "",
        "Cloudy": "",
        "Overcast": "",
        "Mist": "",
        "Fog": "",
        "Patchy rain possible": "",
        "Patchy rain nearby": "",
        "Light rain": "",
        "Light Rain": "",
        "Moderate rain": "",
        "Heavy rain": "",
        "Rain": "",
        "Light drizzle": "",
        "Drizzle": "",
        "Patchy snow possible": "",
        "Light snow": "",
        "Snow": "",
        "Heavy snow": "",
        "Blizzard": "",
        "Thunderstorm": "",
        "Thunder": "",
        "Patchy light rain with thunder": ""
    })

    function weatherIcon(cond) {
        if (!cond) return ""
        if (conditionIcons[cond]) return conditionIcons[cond]
        var c = cond.toLowerCase()
        if (c.indexOf("sun") >= 0 || c.indexOf("clear") >= 0) return ""
        if (c.indexOf("thunder") >= 0 || c.indexOf("storm") >= 0) return ""
        if (c.indexOf("snow") >= 0 || c.indexOf("sleet") >= 0 || c.indexOf("ice") >= 0 || c.indexOf("blizzard") >= 0) return ""
        if (c.indexOf("rain") >= 0 || c.indexOf("drizzle") >= 0 || c.indexOf("shower") >= 0) return ""
        if (c.indexOf("fog") >= 0 || c.indexOf("mist") >= 0 || c.indexOf("haze") >= 0) return ""
        if (c.indexOf("cloud") >= 0 || c.indexOf("overcast") >= 0) return ""
        return ""
    }

    Process {
        id: openBrowser
        command: ["xdg-open", SystemServices.weatherLocation ? ("https://wttr.in/" + SystemServices.weatherLocation) : "https://wttr.in"]
        running: false
    }

    Rectangle {
        id: pill
        height: weatherWidget.implicitHeight - colors.widgetPillPaddingV * 2
        width: row.implicitWidth + colors.widgetPillPaddingH * 2
        anchors.verticalCenter: parent.verticalCenter
        radius: colors.widgetPillRadius
        color: mouseArea.pressed ? Qt.darker(weatherWidget.pillColor, 1.15) : mouseArea.containsMouse ? Qt.lighter(weatherWidget.pillColor, 1.2) : weatherWidget.pillColor
        border.width: 1
        border.color: mouseArea.containsMouse ? Qt.lighter(weatherWidget.pillColor, 1.4) : weatherWidget.pillColor
        scale: mouseArea.pressed ? 0.94 : 1.0
        visible: weatherWidget.hasData
        Behavior on color { ColorAnimation { duration: 100 } }
        Behavior on border.color { ColorAnimation { duration: 100 } }
        Behavior on scale { NumberAnimation { duration: 80; easing.type: Easing.OutCubic } }

        MouseArea {
            id: mouseArea
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            acceptedButtons: Qt.LeftButton | Qt.MiddleButton
            onClicked: function(mouse) {
                if (mouse.button === Qt.MiddleButton) openBrowser.running = true
                else weatherWidget.openForecastRequested()
            }
        }
        Row {
            id: row
            anchors.centerIn: parent
            spacing: 4
            Text {
                text: weatherWidget.weatherIcon(weatherWidget.condition)
                color: weatherWidget.pillTextColor
                font.pixelSize: colors.cpuFontSize
                font.family: colors.widgetIconFont
            }
            Text {
                text: weatherWidget.temperature || "--"
                color: weatherWidget.pillTextColor
                font.pixelSize: colors.cpuFontSize
            }
        }
        Rectangle {
            opacity: mouseArea.containsMouse ? 1 : 0
            visible: opacity > 0
            Behavior on opacity { NumberAnimation { duration: 150; easing.type: Easing.OutCubic } }
            anchors.bottom: parent.top
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottomMargin: 4
            width: weatherTip.implicitWidth + 12
            height: weatherTip.implicitHeight + 6
            radius: 4
            color: colors.surface
            border.width: 1
            border.color: colors.border
            z: 1000
            Text {
                id: weatherTip
                anchors.centerIn: parent
                text: (weatherWidget.condition || "Unknown") + " - " + (weatherWidget.location || "Unknown location")
                color: colors.textMain
                font.pixelSize: colors.fontSize - 1
            }
        }
    }
}
