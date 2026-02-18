import QtQuick

import "."

Item {
    id: screenshotWidget
    required property var colors
    property int pillIndex: 2

    property string compositorName: "hyprland"
    signal menuToggleRequested()

    readonly property color pillColor: (colors.widgetPillColors && pillIndex >= 0 && pillIndex < colors.widgetPillColors.length) ? colors.widgetPillColors[pillIndex] : colors.primary
    readonly property color pillTextColor: (colors.widgetTextOnPillColors && pillIndex >= 0 && pillIndex < colors.widgetTextOnPillColors.length) ? colors.widgetTextOnPillColors[pillIndex] : colors.textMain

    // When set, fullscreen captures this output only (e.g. from bar's screen). Empty = whole session.
    property string fullscreenOutput: ""

    implicitWidth: pill.width
    implicitHeight: 28

    SessionRunner {
        id: sessionRunner
        compositorName: screenshotWidget.compositorName
    }

    readonly property string _scriptDir: "$HOME/.config/scripts"
    function runScript(scriptName, envPrefix) {
        var ex = (envPrefix && envPrefix.length) ? (envPrefix + " ") : ""
        var path = screenshotWidget._scriptDir + "/" + scriptName
        var cmd = ex + "bash " + path
        Qt.callLater(function() { sessionRunner.run(cmd) })
    }
    function runInSession(shellCommand) {
        Qt.callLater(function() { sessionRunner.run("sh -c " + JSON.stringify(shellCommand)) })
    }

    Timer {
        id: selectDelayTimer
        interval: 280
        repeat: false
        onTriggered: runScript("screenshot-region.sh", "")
    }

    property bool _flash: false

    function takeFullscreen() {
        var out = screenshotWidget.fullscreenOutput
        var envPrefix = (out && out.length) ? ("OUTPUT=" + JSON.stringify(out)) : ""
        runScript("screenshot-fullscreen.sh", envPrefix)
        _flash = true; flashTimer.restart()
    }

    function takeSelect() {
        selectDelayTimer.start()
    }

    function takeLast() {
        runScript("screenshot-last.sh", "")
        _flash = true; flashTimer.restart()
    }

    Timer { id: flashTimer; interval: 600; onTriggered: screenshotWidget._flash = false }

    Rectangle {
        id: pill
        height: screenshotWidget.implicitHeight - (colors.widgetPillPaddingV) * 2
        width: row.implicitWidth + (colors.widgetPillPaddingH) * 2
        anchors.verticalCenter: parent.verticalCenter
        radius: colors.widgetPillRadius
        color: mouseArea.pressed ? Qt.darker(screenshotWidget.pillColor, 1.15) : mouseArea.containsMouse ? Qt.lighter(screenshotWidget.pillColor, 1.2) : screenshotWidget.pillColor
        border.width: 1
        border.color: mouseArea.containsMouse ? Qt.lighter(screenshotWidget.pillColor, 1.4) : screenshotWidget.pillColor
        scale: mouseArea.pressed ? 0.94 : 1.0
        Behavior on color { ColorAnimation { duration: 100 } }
        Behavior on border.color { ColorAnimation { duration: 100 } }
        Behavior on scale { NumberAnimation { duration: 80; easing.type: Easing.OutCubic } }

        Rectangle {
            id: flashOverlay
            anchors.fill: parent
            radius: colors.widgetPillRadius
            color: "white"
            opacity: screenshotWidget._flash ? 0.5 : 0
            Behavior on opacity { NumberAnimation { duration: 300; easing.type: Easing.OutCubic } }
        }

        MouseArea {
            id: mouseArea
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            acceptedButtons: Qt.LeftButton
            onClicked: screenshotWidget.menuToggleRequested()
            Row {
                id: row
                anchors.centerIn: parent
                spacing: 0
                leftPadding: colors.widgetPillPaddingH
                rightPadding: colors.widgetPillPaddingH
                Text {
                    text: screenshotWidget._flash ? "\uF00C" : "\uF030"
                    color: screenshotWidget.pillTextColor
                    font.pixelSize: colors.cpuFontSize
                    font.family: colors.widgetIconFont
                }
            }
        }
    }
}
