import QtQuick
import Quickshell.Io

import "."

Item {
    id: weatherWidget
    required property var colors
    property int pillIndex: 0

    readonly property color pillColor: (colors.widgetPillColors && pillIndex >= 0 && pillIndex < colors.widgetPillColors.length) ? colors.widgetPillColors[pillIndex] : colors.primary
    readonly property color pillTextColor: (colors.widgetTextOnPillColors && pillIndex >= 0 && pillIndex < colors.widgetTextOnPillColors.length) ? colors.widgetTextOnPillColors[pillIndex] : colors.textMain

    property string temperature: ""
    property string condition: ""
    property string location: ""
    property bool hasData: false

    implicitWidth: hasData ? pill.width : 0
    implicitHeight: hasData ? 28 : 0
    visible: hasData

    readonly property var conditionIcons: ({
        "Clear": "\uF185",
        "Sunny": "\uF185",
        "Partly cloudy": "\uF6C4",
        "Partly Cloudy": "\uF6C4",
        "Cloudy": "\uF0C2",
        "Overcast": "\uF0C2",
        "Mist": "\uF75F",
        "Fog": "\uF75F",
        "Patchy rain possible": "\uF73D",
        "Patchy rain nearby": "\uF73D",
        "Light rain": "\uF73D",
        "Light Rain": "\uF73D",
        "Moderate rain": "\uF740",
        "Heavy rain": "\uF740",
        "Rain": "\uF740",
        "Light drizzle": "\uF73D",
        "Drizzle": "\uF73D",
        "Patchy snow possible": "\uF2DC",
        "Light snow": "\uF2DC",
        "Snow": "\uF2DC",
        "Heavy snow": "\uF2DC",
        "Blizzard": "\uF2DC",
        "Thunderstorm": "\uF0E7",
        "Thunder": "\uF0E7",
        "Patchy light rain with thunder": "\uF0E7"
    })

    function weatherIcon(cond) {
        if (!cond) return "\uF0C2"
        if (conditionIcons[cond]) return conditionIcons[cond]
        var c = cond.toLowerCase()
        if (c.indexOf("sun") >= 0 || c.indexOf("clear") >= 0) return "\uF185"
        if (c.indexOf("thunder") >= 0 || c.indexOf("storm") >= 0) return "\uF0E7"
        if (c.indexOf("snow") >= 0 || c.indexOf("sleet") >= 0 || c.indexOf("ice") >= 0 || c.indexOf("blizzard") >= 0) return "\uF2DC"
        if (c.indexOf("rain") >= 0 || c.indexOf("drizzle") >= 0 || c.indexOf("shower") >= 0) return "\uF73D"
        if (c.indexOf("fog") >= 0 || c.indexOf("mist") >= 0 || c.indexOf("haze") >= 0) return "\uF75F"
        if (c.indexOf("cloud") >= 0 || c.indexOf("overcast") >= 0) return "\uF0C2"
        return "\uF0C2"
    }

    property string weatherLocation: ""
    readonly property string _weatherUrl: weatherLocation ? ("wttr.in/" + weatherLocation) : "wttr.in"

    Process {
        id: loadLocProc
        command: ["sh", "-c", "cat \"${XDG_CONFIG_HOME:-$HOME/.config}/quickshell/weather-location.txt\" 2>/dev/null || echo ''"]
        running: true
        stdout: StdioCollector {
            onStreamFinished: {
                weatherWidget.weatherLocation = (loadLocProc.stdout.text || "").trim()
                loadLocProc.running = false
            }
        }
    }

    Process {
        id: weatherProc
        command: ["sh", "-c", "curl -s '" + weatherWidget._weatherUrl + "?format=%C|%t' 2>/dev/null"]
        running: false
        stdout: StdioCollector {
            onStreamFinished: {
                var s = (weatherProc.stdout.text || "").trim()
                if (s && s.indexOf("|") >= 0) {
                    var parts = s.split("|")
                    weatherWidget.condition = (parts[0] || "").trim()
                    var t = (parts[1] || "").trim()
                    weatherWidget.temperature = t.replace(/^\+/, "")
                    weatherWidget.hasData = true
                } else {
                    weatherWidget.hasData = false
                }
                weatherProc.running = false
            }
        }
    }

    Process {
        id: locationProc
        command: ["sh", "-c", "curl -s '" + weatherWidget._weatherUrl + "?format=%l' 2>/dev/null"]
        running: false
        stdout: StdioCollector {
            onStreamFinished: {
                weatherWidget.location = (locationProc.stdout.text || "").trim()
                locationProc.running = false
            }
        }
    }

    Process {
        id: openBrowser
        command: ["xdg-open", "https://" + weatherWidget._weatherUrl]
        running: false
    }

    Timer {
        interval: 900000
        repeat: true
        running: weatherWidget.visible
        onTriggered: if (!weatherProc.running) weatherProc.running = true
    }

    Component.onCompleted: {
        weatherProc.running = true
        locationProc.running = true
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
            onClicked: openBrowser.running = true
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
