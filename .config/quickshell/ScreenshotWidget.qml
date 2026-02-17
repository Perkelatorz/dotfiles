import QtQuick

import "."

Item {
    id: screenshotWidget
    required property var colors
    property int pillIndex: 0

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

    function takeFullscreen() {
        var out = screenshotWidget.fullscreenOutput
        var envPrefix = (out && out.length) ? ("OUTPUT=" + JSON.stringify(out)) : ""
        runScript("screenshot-fullscreen.sh", envPrefix)
    }

    function takeSelect() {
        selectDelayTimer.start()
    }

    function takeLast() {
        runScript("screenshot-last.sh", "")
    }

    Rectangle {
        id: pill
        height: screenshotWidget.implicitHeight - (colors.widgetPillPaddingV) * 2
        width: row.implicitWidth + (colors.widgetPillPaddingH) * 2
        anchors.verticalCenter: parent.verticalCenter
        radius: colors.widgetPillRadius
        color: screenshotWidget.pillColor
        border.width: 1
        border.color: screenshotWidget.pillColor

        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            acceptedButtons: Qt.LeftButton
            onClicked: screenshotWidget.menuToggleRequested()
            Row {
                id: row
                anchors.centerIn: parent
                spacing: 0
                leftPadding: colors.widgetPillPaddingH
                rightPadding: colors.widgetPillPaddingH
                Text {
                    text: "\uF030"
                    color: screenshotWidget.pillTextColor
                    font.pixelSize: colors.cpuFontSize
                    font.family: colors.widgetIconFont
                }
            }
        }
    }
}
