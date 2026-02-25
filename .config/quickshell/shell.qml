//@ pragma UseQApplication
import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import Quickshell.Services.SystemTray
import Quickshell.Wayland

import "."

ShellRoot {
    id: shellRoot
    property var fullscreenMonitorNames: []
    property alias shellColors: colors
    property string compositorName: "hyprland"
    property bool workspaceOverviewTriggered: false

    function refreshFullscreenMonitors() {
        if (compositorName === "hyprland" && !fullscreenProcess.running)
            fullscreenProcess.running = true
    }

    Process {
        id: compositorDetectProc
        command: ["sh", "-c", "echo \"${XDG_CURRENT_DESKTOP:-}\""]
        running: true
        stdout: StdioCollector {
            onStreamFinished: {
                var s = (compositorDetectProc.stdout.text || "").trim().toLowerCase()
                var next = s.indexOf("hyprland") >= 0 ? "hyprland"
                    : s.indexOf("niri") >= 0 ? "niri"
                    : "other"
                shellRoot.compositorName = next
                compositorDetectProc.running = false
            }
        }
    }

    Process {
        id: fullscreenProcess
        command: ["hyprctl", "clients", "-j"]
        running: false
        stdout: StdioCollector {
            onStreamFinished: {
                if (shellRoot.compositorName !== "hyprland") {
                    fullscreenProcess.running = false
                    return
                }
                var names = []
                try {
                    var clients = JSON.parse(this.text)
                    if (Array.isArray(clients)) {
                        for (var i = 0; i < clients.length; i++) {
                            var c = clients[i]
                            // 1 = maximize, 2 = fullscreen (entire screen), 3 = both — hide bar for 2 and 3
                            var fs = c.fullscreen
                            if ((fs === 2 || fs === 3) && c.monitor != null) {
                                var mon = String(c.monitor)
                                if (names.indexOf(mon) < 0)
                                    names.push(mon)
                            }
                        }
                    }
                } catch (_) { }
                shellRoot.fullscreenMonitorNames = names
                fullscreenProcess.running = false
            }
        }
    }

    Connections {
        target: Hyprland
        enabled: shellRoot.compositorName === "hyprland"
        function onRawEvent(event) {
            var n = event.name || ""
            if (n === "fullscreen") {
                shellRoot.refreshFullscreenMonitors()
            }
        }
    }

    // Compositor detected once at startup by compositorDetectProc (running: true)

    Process {
        id: overviewTriggerProc
        command: ["sh", "-c", "f=\"${XDG_RUNTIME_DIR:-/tmp}/quickshell-open-overview\"; if [ -f \"$f\" ]; then rm -f \"$f\"; echo 1; fi"]
        running: false
        stdout: StdioCollector {
            onStreamFinished: {
                if ((overviewTriggerProc.stdout.text || "").trim() !== "") {
                    shellRoot.workspaceOverviewTriggered = true
                }
                overviewTriggerProc.running = false
            }
        }
    }
    Timer {
        interval: 400
        repeat: true
        running: true
        onTriggered: {
            if (!shellRoot.workspaceOverviewTriggered && !overviewTriggerProc.running)
                overviewTriggerProc.running = true
        }
    }

    Component.onCompleted: Qt.callLater(shellRoot.refreshFullscreenMonitors)

    // Colors from matugen: Colors.qml is loaded as a QML component. Restart quickshell after wallpaper change to pick up new theme.
    Colors {
        id: colors
    }

    Variants {
        model: Quickshell.screens

        Item {
            id: screenDelegate
            property var modelData
            // Vertical/portrait screen: turn off optional widgets so they appear off in settings (user can re-enable there)
            readonly property bool isVerticalScreen: screenDelegate.modelData && (screenDelegate.modelData.height > screenDelegate.modelData.width)
            function resetWidgetVisibility() {
                volumeWidgetVisible = false
                nowPlayingWidgetVisible = false
                performanceWidgetVisible = false
                batteryWidgetVisible = false
                brightnessWidgetVisible = false
                microphoneWidgetVisible = false
                ipAddressWidgetVisible = false
                screenshotWidgetVisible = false
                weatherWidgetVisible = false
                updatesWidgetVisible = false
                netSpeedWidgetVisible = false
                notificationsWidgetVisible = false
                powerProfileWidgetVisible = false
            }
            onIsVerticalScreenChanged: {
                if (screenDelegate.isVerticalScreen) {
                    resetWidgetVisibility()
                }
            }
            property bool calendarVisible: false
            property bool nowPlayingPopupVisible: false
            property bool quickSettingsMenuVisible: false
            property string quickSettingsSubView: "main"
            property bool screenshotMenuVisible: false
            property bool workspaceOverviewVisible: false
            property bool clipboardPanelVisible: false
            property bool keybindsPanelVisible: false
            property bool toolsMenuVisible: false
            property int toolsMenuMarginRight: 0

            function closeAllPanels() {
                calendarVisible = false
                nowPlayingPopupVisible = false
                quickSettingsMenuVisible = false
                screenshotMenuVisible = false
                workspaceOverviewVisible = false
                shellRoot.workspaceOverviewTriggered = false
                clipboardPanelVisible = false
                keybindsPanelVisible = false
                toolsMenuVisible = false
            }
            property var screenshotWidgetRef: null
            property int screenshotMenuMarginLeft: 0
            property int calendarMarginLeft: 0
            // Widget visibility (toggle from settings menu)
            property bool volumeWidgetVisible: true
            property bool nowPlayingWidgetVisible: true
            property bool performanceWidgetVisible: true
            property bool batteryWidgetVisible: true
            property bool brightnessWidgetVisible: true
            property bool microphoneWidgetVisible: true
            property bool ipAddressWidgetVisible: false
            property bool screenshotWidgetVisible: true
            property bool clockWidgetVisible: true
            property bool weatherWidgetVisible: false
            property bool updatesWidgetVisible: true
            property bool netSpeedWidgetVisible: true
            property bool notificationsWidgetVisible: true
            property bool powerProfileWidgetVisible: false
            property bool quickNotesWidgetVisible: true
            property bool colorPickerWidgetVisible: true
            property bool clipboardWidgetVisible: true
            property bool keybindsWidgetVisible: true
            property bool workspaceOverviewWidgetVisible: true

            function loadBarWidgets() {
                loadBarWidgetsProc.running = true
            }
            function saveWidgetVisibility() {
                var args = [
                    "volume=" + (volumeWidgetVisible ? "true" : "false"),
                    "nowPlaying=" + (nowPlayingWidgetVisible ? "true" : "false"),
                    "performance=" + (performanceWidgetVisible ? "true" : "false"),
                    "battery=" + (batteryWidgetVisible ? "true" : "false"),
                    "brightness=" + (brightnessWidgetVisible ? "true" : "false"),
                    "microphone=" + (microphoneWidgetVisible ? "true" : "false"),
                    "ipAddress=" + (ipAddressWidgetVisible ? "true" : "false"),
                    "screenshot=" + (screenshotWidgetVisible ? "true" : "false"),
                    "clock=" + (clockWidgetVisible ? "true" : "false"),
                    "weather=" + (weatherWidgetVisible ? "true" : "false"),
                    "updates=" + (updatesWidgetVisible ? "true" : "false"),
                    "netSpeed=" + (netSpeedWidgetVisible ? "true" : "false"),
                    "notifications=" + (notificationsWidgetVisible ? "true" : "false"),
                    "powerProfile=" + (powerProfileWidgetVisible ? "true" : "false")
                ]
                saveBarWidgetsProc.command = ["sh", "-c", "SCRIPT=\"${XDG_CONFIG_HOME:-$HOME/.config}/scripts/write-bar-widgets.sh\"; exec \"$SCRIPT\" " + args.join(" ")]
                saveBarWidgetsProc.running = true
            }
            Process {
                id: loadBarWidgetsProc
                command: ["sh", "-c", "cat \"${XDG_CONFIG_HOME:-$HOME/.config}/quickshell/bar-widgets.json\" 2>/dev/null || echo '{}'"]
                running: false
                stdout: StdioCollector {
                    onStreamFinished: {
                        try {
                            var o = JSON.parse(loadBarWidgetsProc.stdout.text || "{}")
                            if (typeof o.volume === "boolean") screenDelegate.volumeWidgetVisible = o.volume
                            if (typeof o.nowPlaying === "boolean") screenDelegate.nowPlayingWidgetVisible = o.nowPlaying
                            if (typeof o.performance === "boolean") screenDelegate.performanceWidgetVisible = o.performance
                            if (typeof o.battery === "boolean") screenDelegate.batteryWidgetVisible = o.battery
                            if (typeof o.brightness === "boolean") screenDelegate.brightnessWidgetVisible = o.brightness
                            if (typeof o.microphone === "boolean") screenDelegate.microphoneWidgetVisible = o.microphone
                            if (typeof o.ipAddress === "boolean") screenDelegate.ipAddressWidgetVisible = o.ipAddress
                            if (typeof o.screenshot === "boolean") screenDelegate.screenshotWidgetVisible = o.screenshot
                            if (typeof o.clock === "boolean") screenDelegate.clockWidgetVisible = o.clock
                            if (typeof o.weather === "boolean") screenDelegate.weatherWidgetVisible = o.weather
                            if (typeof o.updates === "boolean") screenDelegate.updatesWidgetVisible = o.updates
                            if (typeof o.netSpeed === "boolean") screenDelegate.netSpeedWidgetVisible = o.netSpeed
                            if (typeof o.notifications === "boolean") screenDelegate.notificationsWidgetVisible = o.notifications
                            if (typeof o.powerProfile === "boolean") screenDelegate.powerProfileWidgetVisible = o.powerProfile
                            if (screenDelegate.isVerticalScreen) {
                                screenDelegate.resetWidgetVisibility()
                            }
                        } catch (_) { }
                        loadBarWidgetsProc.running = false
                    }
                }
            }
            Process {
                id: saveBarWidgetsProc
                command: []
                running: false
            }
            Component.onCompleted: loadBarWidgets()

            property string calendarTitle: ""
            property var calendarDays: []
            property int calendarTodayDay: 0
            property int displayedMonth: 0
            property int displayedYear: 2000
            property bool calendarIsCurrentMonth: displayedMonth === new Date().getMonth() && displayedYear === new Date().getFullYear()

            function getCalendarDaysFor(month, year) {
                var first = new Date(year, month, 1)
                var last = new Date(year, month + 1, 0)
                var firstDayMonday = (first.getDay() + 6) % 7
                var lastDate = last.getDate()
                var out = []
                for (var i = 0; i < 42; i++) {
                    if (i < firstDayMonday || i >= firstDayMonday + lastDate)
                        out.push(0)
                    else
                        out.push(i - firstDayMonday + 1)
                }
                return out
            }

            function updateCalendarDisplay() {
                screenDelegate.calendarTitle = Qt.formatDate(new Date(displayedYear, displayedMonth, 1), "MMMM yyyy")
                screenDelegate.calendarDays = screenDelegate.getCalendarDaysFor(displayedMonth, displayedYear)
            }

            function calendarGoToToday() {
                var now = new Date()
                displayedMonth = now.getMonth()
                displayedYear = now.getFullYear()
                screenDelegate.calendarTodayDay = now.getDate()
                updateCalendarDisplay()
            }

            function calendarPreviousMonth() {
                displayedMonth--
                if (displayedMonth < 0) {
                    displayedMonth = 11
                    displayedYear--
                }
                updateCalendarDisplay()
            }

            function calendarNextMonth() {
                displayedMonth++
                if (displayedMonth > 11) {
                    displayedMonth = 0
                    displayedYear++
                }
                updateCalendarDisplay()
            }

            PanelWindow {
                id: bar
                property var modelData: screenDelegate.modelData
                property string compositorName: shellRoot.compositorName
                property var hyprMonitor: bar.compositorName === "hyprland" ? Hyprland.monitorFor(modelData) : null
                readonly property bool panelsVisible: {
                    if (bar.compositorName === "hyprland")
                        return !bar.hyprMonitor || shellRoot.fullscreenMonitorNames.indexOf(bar.hyprMonitor.name) < 0
                    return true
                }
                property int screenIndex: {
                    var s = Quickshell.screens
                    if (!s || !bar.modelData) return 0
                    for (var i = 0; i < s.length; i++)
                        if (s[i] === bar.modelData) return i
                    return 0
                }

                screen: screenDelegate.modelData
                visible: bar.panelsVisible

                anchors {
                    left: true
                    right: true
                    top: true
                }
                implicitHeight: 30
                color: "transparent"

                Component.onCompleted: {
                    if (this.WlrLayershell != null) {
                        this.WlrLayershell.layer = WlrLayer.Top
                        this.WlrLayershell.namespace = "quickshell-workspace-bar"
                    }
                }

                Item {
                    id: root
                    anchors.fill: parent
                    property var hyprMonitor: bar.hyprMonitor
                    property var clientList: []
                    property var occupiedWorkspaceIds: ({})
                    property var clientsByWorkspace: ({})
                    property string activeWindowAddress: ""

                    function refreshClients() {
                        if (root.hyprMonitor) {
                            if (!clientsProcess.running) clientsProcess.running = true
                            if (!activeWindowProcess.running) activeWindowProcess.running = true
                        }
                    }

                    Connections {
                        target: Hyprland
                        enabled: bar.compositorName === "hyprland"
                        function onRawEvent(event) {
                            var n = event.name || ""
                            if (n === "workspace" || n === "workspacev2") {
                                Hyprland.refreshWorkspaces()
                                root.refreshClients()
                            } else if (n === "openwindow" || n === "closewindow" || n === "activewindow" || n === "activewindowv2") {
                                root.refreshClients()
                            }
                        }
                    }

                    Timer {
                        interval: 1000
                        repeat: true
                        running: root.hyprMonitor != null
                        onTriggered: root.refreshClients()
                    }

                    Process {
                        id: activeWindowProcess
                        command: ["hyprctl", "activewindow", "-j"]
                        stdout: StdioCollector {
                            onStreamFinished: {
                                if (bar.compositorName !== "hyprland") {
                                    activeWindowProcess.running = false
                                    return
                                }
                                try {
                                    var obj = JSON.parse(this.text)
                                    root.activeWindowAddress = obj && obj.address ? String(obj.address) : ""
                                } catch (_) {
                                    root.activeWindowAddress = ""
                                }
                                activeWindowProcess.running = false
                            }
                        }
                    }

                    Process {
                        id: clientsProcess
                        command: ["hyprctl", "clients", "-j"]
                        stdout: StdioCollector {
                            onStreamFinished: {
                                if (bar.compositorName !== "hyprland") {
                                    root.clientList = []
                                    root.occupiedWorkspaceIds = {}
                                    root.clientsByWorkspace = {}
                                    clientsProcess.running = false
                                    return
                                }
                                var list = []
                                var occ = {}
                                var byWs = {}
                                try {
                                    var clients = JSON.parse(this.text)
                                    if (Array.isArray(clients)) {
                                        var ws = root.hyprMonitor && root.hyprMonitor.activeWorkspace
                                        for (var i = 0; i < clients.length; i++) {
                                            var c = clients[i]
                                            var cws = c.workspace
                                            if (cws) {
                                                var cwsId = cws.id
                                                var cwsName = cws.name != null ? String(cws.name) : (cwsId != null ? String(cwsId) : "")
                                                occ[cwsId] = true
                                                occ[cwsName] = true
                                                var entry = { address: c.address, title: c.title || "", class: c.class || "" }
                                                if (ws && (cwsId === ws.id || cwsName === String(ws.name)))
                                                    list.push(entry)
                                                var key = cwsId != null ? cwsId : cwsName
                                                if (!byWs[key]) byWs[key] = []
                                                byWs[key].push(entry)
                                                var arr = byWs[key]
                                                if (cwsId != null) byWs[String(cwsId)] = arr
                                                if (cwsName) byWs[cwsName] = arr
                                            }
                                        }
                                    }
                                } catch (_) { }
                                root.clientList = list
                                root.occupiedWorkspaceIds = occ
                                root.clientsByWorkspace = byWs
                                clientsProcess.running = false
                            }
                        }
                    }

                    Component.onCompleted: {
                        if (root.hyprMonitor) {
                            if (!clientsProcess.running) clientsProcess.running = true
                            if (!activeWindowProcess.running) activeWindowProcess.running = true
                        }
                    }

                    RowLayout {
                        id: barLayout
                        anchors.fill: parent
                        spacing: 0

                        WorkspaceOverviewWidget {
                            colors: shellRoot.shellColors
                            Layout.alignment: Qt.AlignVCenter
                            Layout.leftMargin: 4
                            Layout.rightMargin: 4
                            visible: bar.compositorName === "hyprland" && screenDelegate.workspaceOverviewWidgetVisible
                            onToggleRequested: {
                                screenDelegate.calendarVisible = false
                                screenDelegate.quickSettingsMenuVisible = false
                                screenDelegate.screenshotMenuVisible = false
                                screenDelegate.nowPlayingPopupVisible = false
                                screenDelegate.clipboardPanelVisible = false
                                screenDelegate.keybindsPanelVisible = false
                                screenDelegate.toolsMenuVisible = false
                                screenDelegate.workspaceOverviewVisible = !screenDelegate.workspaceOverviewVisible
                            }
                        }
                        Workspaces {
                            id: workspaceRow
                            visible: bar.compositorName === "hyprland"
                            colors: shellRoot.shellColors
                            hyprMonitor: root.hyprMonitor
                            occupiedWorkspaceIds: root.occupiedWorkspaceIds
                            clientsByWorkspace: root.clientsByWorkspace
                            Layout.leftMargin: 0
                            Layout.rightMargin: 4
                        }
                        NowPlayingWidget {
                            id: nowPlayingWidget
                            colors: shellRoot.shellColors
                            Layout.alignment: Qt.AlignVCenter
                            Layout.leftMargin: 4
                            Layout.rightMargin: 4
                            visible: screenDelegate.nowPlayingWidgetVisible
                            onOpenMiniPlayerRequested: {
                                        screenDelegate.calendarVisible = false
                                        screenDelegate.quickSettingsMenuVisible = false
                                        screenDelegate.screenshotMenuVisible = false
                                        screenDelegate.workspaceOverviewVisible = false
                                        screenDelegate.clipboardPanelVisible = false
                                        screenDelegate.keybindsPanelVisible = false
                                        screenDelegate.toolsMenuVisible = false
                                        screenDelegate.nowPlayingPopupVisible = !screenDelegate.nowPlayingPopupVisible
                                    }
                        }

                        Item {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            Layout.leftMargin: 4
                            Layout.rightMargin: 4
                            visible: bar.compositorName === "hyprland"
                            ClientList {
                                anchors.centerIn: parent
                                colors: shellRoot.shellColors
                                clientList: root.clientList
                                activeWindowAddress: root.activeWindowAddress
                            }
                        }

                        Item {
                            id: rightSectionWrapper
                            Layout.minimumWidth: rightSectionLayout.implicitWidth + 16
                            Layout.maximumHeight: parent.height
                            Layout.alignment: Qt.AlignRight
                            Layout.rightMargin: 8
                            z: 2

                            RowLayout {
                                id: rightSectionLayout
                                anchors.right: parent.right
                                anchors.verticalCenter: parent.verticalCenter
                                spacing: 6
                                layoutDirection: Qt.LeftToRight

                                WeatherWidget {
                                    colors: shellRoot.shellColors
                                    Layout.alignment: Qt.AlignVCenter
                                    visible: screenDelegate.weatherWidgetVisible
                                }

                                UpdateWidget {
                                    colors: shellRoot.shellColors
                                    Layout.alignment: Qt.AlignVCenter
                                    visible: screenDelegate.updatesWidgetVisible
                                }

                                NetSpeedWidget {
                                    colors: shellRoot.shellColors
                                    Layout.alignment: Qt.AlignVCenter
                                    visible: screenDelegate.netSpeedWidgetVisible
                                }

                                PowerProfileWidget {
                                    colors: shellRoot.shellColors
                                    Layout.alignment: Qt.AlignVCenter
                                    visible: screenDelegate.powerProfileWidgetVisible
                                }

                                PerformanceWidget {
                                    colors: shellRoot.shellColors
                                    Layout.alignment: Qt.AlignVCenter
                                    visible: screenDelegate.performanceWidgetVisible
                                }

                                BatteryWidget {
                                    id: batteryWidget
                                    colors: shellRoot.shellColors
                                    Layout.alignment: Qt.AlignVCenter
                                    visible: screenDelegate.batteryWidgetVisible
                                }

                                BrightnessWidget {
                                    colors: shellRoot.shellColors
                                    Layout.alignment: Qt.AlignVCenter
                                    visible: screenDelegate.brightnessWidgetVisible
                                    outputName: bar.hyprMonitor ? bar.hyprMonitor.name : ""
                                    screenIndex: bar.screenIndex
                                }

                                VolumeWidget {
                                    colors: shellRoot.shellColors
                                    Layout.alignment: Qt.AlignVCenter
                                    visible: screenDelegate.volumeWidgetVisible
                                }

                                MicrophoneWidget {
                                    colors: shellRoot.shellColors
                                    Layout.alignment: Qt.AlignVCenter
                                    visible: screenDelegate.microphoneWidgetVisible
                                }

                                IpAddressWidget {
                                    colors: shellRoot.shellColors
                                    Layout.alignment: Qt.AlignVCenter
                                    visible: screenDelegate.ipAddressWidgetVisible
                                }

                                ScreenshotWidget {
                                    id: screenshotWidget
                                    colors: shellRoot.shellColors
                                    compositorName: bar.compositorName
                                    Layout.alignment: Qt.AlignVCenter
                                    visible: false
                                    fullscreenOutput: screenDelegate.modelData && screenDelegate.modelData.name ? String(screenDelegate.modelData.name) : ""
                                    Component.onCompleted: screenDelegate.screenshotWidgetRef = screenshotWidget
                                }

                                ToolsMenuWidget {
                                    id: toolsMenuWidget
                                    colors: shellRoot.shellColors
                                    Layout.alignment: Qt.AlignVCenter
                                    onToggleRequested: {
                                        var anyToolOpen = screenDelegate.toolsMenuVisible || screenDelegate.clipboardPanelVisible || screenDelegate.keybindsPanelVisible || screenDelegate.screenshotMenuVisible
                                        screenDelegate.calendarVisible = false
                                        screenDelegate.quickSettingsMenuVisible = false
                                        screenDelegate.nowPlayingPopupVisible = false
                                        screenDelegate.workspaceOverviewVisible = false
                                        screenDelegate.clipboardPanelVisible = false
                                        screenDelegate.keybindsPanelVisible = false
                                        screenDelegate.screenshotMenuVisible = false
                                        screenDelegate.toolsMenuVisible = false
                                        if (!anyToolOpen) {
                                            var pt = toolsMenuWidget.mapToItem(root, 0, 0)
                                            var screenW = root.width || 1920
                                            screenDelegate.toolsMenuMarginRight = Math.max(0, Math.floor(screenW - pt.x - toolsMenuWidget.width / 2 - 90))
                                            screenDelegate.toolsMenuVisible = true
                                        }
                                    }
                                }

                                ClockWidget {
                                    id: clockWidget
                                    colors: shellRoot.shellColors
                                    visible: screenDelegate.clockWidgetVisible
                                    Layout.alignment: Qt.AlignVCenter
                                    Layout.leftMargin: 2
                                    Layout.rightMargin: 2
                                    onCalendarToggleRequested: function() {
                                        screenDelegate.calendarVisible = !screenDelegate.calendarVisible
                                        if (screenDelegate.calendarVisible) {
                                            screenDelegate.nowPlayingPopupVisible = false
                                            screenDelegate.quickSettingsMenuVisible = false
                                            screenDelegate.screenshotMenuVisible = false
                                            screenDelegate.workspaceOverviewVisible = false
                                            screenDelegate.clipboardPanelVisible = false
                                            screenDelegate.keybindsPanelVisible = false
                                            screenDelegate.toolsMenuVisible = false
                                            var pt = clockWidget.mapToItem(root, 0, 0)
                                            screenDelegate.calendarMarginLeft = Math.max(0, Math.floor(pt.x + (clockWidget.width - 200) / 2))
                                            var now = new Date()
                                            screenDelegate.displayedMonth = now.getMonth()
                                            screenDelegate.displayedYear = now.getFullYear()
                                            screenDelegate.calendarTodayDay = now.getDate()
                                            screenDelegate.updateCalendarDisplay()
                                        }
                                    }
                                }

                                Tray {
                                    colors: shellRoot.shellColors
                                    barWindow: bar
                                    Layout.alignment: Qt.AlignVCenter
                                    visible: !screenDelegate.isVerticalScreen
                                }

                                NotificationWidget {
                                    colors: shellRoot.shellColors
                                    Layout.alignment: Qt.AlignVCenter
                                    visible: screenDelegate.notificationsWidgetVisible
                                }

                                QuickSettingsWidget {
                                    colors: shellRoot.shellColors
                                    Layout.alignment: Qt.AlignVCenter
                                    onMenuToggleRequested: {
                                            screenDelegate.quickSettingsMenuVisible = !screenDelegate.quickSettingsMenuVisible
                                            if (screenDelegate.quickSettingsMenuVisible) {
                                            screenDelegate.quickSettingsSubView = "main"
                                            screenDelegate.calendarVisible = false
                                            screenDelegate.nowPlayingPopupVisible = false
                                            screenDelegate.screenshotMenuVisible = false
                                            screenDelegate.workspaceOverviewVisible = false
                                            screenDelegate.clipboardPanelVisible = false
                                            screenDelegate.keybindsPanelVisible = false
                                            screenDelegate.toolsMenuVisible = false
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }

            PanelWindow {
                id: quickSettingsPanel
                screen: screenDelegate.modelData
                visible: screenDelegate.quickSettingsMenuVisible && bar.panelsVisible
                color: "transparent"
                exclusiveZone: -1
                anchors { top: true; bottom: true; left: true; right: true }

                readonly property int _qsH: screenDelegate.quickSettingsSubView === "settings"
                    ? Math.min(qsSettingsContent.implicitHeight + 60, 500)
                    : (screenDelegate.quickSettingsSubView === "power"
                        ? Math.min(qsPowerContent.implicitHeight + 60, 400)
                        : Math.min(qsContent.implicitHeight + 40, 700))

                focusable: true
                onVisibleChanged: {
                    if (visible) {
                        qsContainer.opacity = 0
                        qsContainer.y = bar.implicitHeight + 5 - 8
                        qsPanelOpenAnim.restart()
                        qsEscScope.forceActiveFocus()
                    }
                }
                Item { id: qsEscScope; focus: true; Keys.onEscapePressed: screenDelegate.closeAllPanels() }
                ParallelAnimation {
                    id: qsPanelOpenAnim
                    NumberAnimation { target: qsContainer; property: "opacity"; from: 0; to: 1; duration: 200; easing.type: Easing.OutCubic }
                    NumberAnimation { target: qsContainer; property: "y"; from: bar.implicitHeight + 5 - 8; to: bar.implicitHeight + 5; duration: 200; easing.type: Easing.OutCubic }
                }

                Component.onCompleted: {
                    if (this.WlrLayershell != null) {
                        this.WlrLayershell.layer = WlrLayer.Overlay
                        this.WlrLayershell.keyboardFocus = WlrKeyboardFocus.Exclusive
                        this.WlrLayershell.namespace = "quickshell-quick-settings"
                    }
                }

                MouseArea { anchors.fill: parent; onClicked: screenDelegate.closeAllPanels() }

                Item {
                    id: qsContainer
                    x: parent.width - 440 - 8
                    y: bar.implicitHeight + 5
                    width: 440
                    height: quickSettingsPanel._qsH
                    MouseArea { anchors.fill: parent }
                    Rectangle {
                        id: qsPanelShadow
                        anchors.fill: parent
                        anchors.leftMargin: 2
                        anchors.topMargin: 3
                        z: -1
                        radius: 14
                        color: shellRoot.shellColors.panelShadow
                    }
                    Rectangle {
                        id: qsPanelBg
                        anchors.fill: parent
                        radius: 12
                        color: shellRoot.shellColors.surfaceContainer
                        border.width: 1
                        border.color: shellRoot.shellColors.borderSubtle
                        Column {
                            anchors.fill: parent
                        spacing: 0
                        Row {
                            visible: screenDelegate.quickSettingsSubView !== "main"
                            width: parent.width - 40
                            height: 40
                            leftPadding: 12
                            rightPadding: 12
                            spacing: 8
                            MouseArea {
                                id: backButtonMa
                                width: 32
                                height: 32
                                anchors.verticalCenter: parent.verticalCenter
                                hoverEnabled: true
                                onClicked: screenDelegate.quickSettingsSubView = "main"
                                Rectangle {
                                    anchors.fill: parent
                                    radius: 6
                                    color: backButtonMa.containsMouse ? shellRoot.shellColors.surfaceBright : "transparent"
                                }
                                Text {
                                    anchors.centerIn: parent
                                    text: "\uF060"
                                    color: shellRoot.shellColors.textMain
                                    font.pixelSize: 14
                                    font.family: shellRoot.shellColors.widgetIconFont
                                }
                            }
                            Item { width: 1; height: 1 }
                            Text {
                                anchors.verticalCenter: parent.verticalCenter
                                text: screenDelegate.quickSettingsSubView === "power" ? "Power" : "Widgets & settings"
                                color: shellRoot.shellColors.primary
                                font.pixelSize: 14
                                font.bold: true
                            }
                        }
                        Rectangle {
                            visible: screenDelegate.quickSettingsSubView !== "main"
                            width: parent.width - 40
                            height: 1
                            anchors.horizontalCenter: parent.horizontalCenter
                            color: shellRoot.shellColors.borderSubtle
                        }
                        Item {
                            width: parent.width - 40
                            height: parent.height - (screenDelegate.quickSettingsSubView !== "main" ? 41 : 0)
                            anchors.horizontalCenter: parent.horizontalCenter
                            clip: true
                            Flickable {
                                id: qsFlick
                                visible: screenDelegate.quickSettingsSubView === "main"
                                anchors.fill: parent
                                anchors.margins: 20
                                contentWidth: width
                                contentHeight: qsContent.implicitHeight
                                flickableDirection: Flickable.VerticalFlick
                                boundsBehavior: Flickable.StopAtBounds
                                QuickSettingsContent {
                                    id: qsContent
                                    width: parent.width
                                    colors: shellRoot.shellColors
                                    compositorName: shellRoot.compositorName
                                    screenIndex: bar.screenIndex
                                    onClose: function() { screenDelegate.quickSettingsMenuVisible = false }
                                    onOpenPowerRequested: screenDelegate.quickSettingsSubView = "power"
                                    onOpenSettingsRequested: screenDelegate.quickSettingsSubView = "settings"
                                }
                            }
                            MouseArea {
                                anchors.fill: parent
                                anchors.margins: 20
                                visible: screenDelegate.quickSettingsSubView === "main"
                                acceptedButtons: Qt.MiddleButton
                                onWheel: function(wheel) {
                                    var step = (wheel.angleDelta.y / 120) * 80
                                    qsFlick.contentY = Math.max(0, Math.min(qsFlick.contentY - step, Math.max(0, qsFlick.contentHeight - qsFlick.height)))
                                }
                            }
                            Item {
                                visible: screenDelegate.quickSettingsSubView === "power"
                                anchors.fill: parent
                                PowerMenuContent {
                                    id: qsPowerContent
                                    anchors.centerIn: parent
                                    width: Math.min(180, parent.width - 24)
                                    colors: shellRoot.shellColors
                                    compositorName: shellRoot.compositorName
                                    onClose: function() {
                                        screenDelegate.quickSettingsMenuVisible = false
                                    }
                                }
                            }
                            Item {
                                visible: screenDelegate.quickSettingsSubView === "settings"
                                anchors.fill: parent
                                SettingsMenuContent {
                                    id: qsSettingsContent
                                    anchors.fill: parent
                                    anchors.margins: 8
                                    colors: shellRoot.shellColors
                                    settingsState: screenDelegate
                                    onClose: function() {
                                        screenDelegate.quickSettingsSubView = "main"
                                    }
                                }
                            }
                        }
                    }
                }
                }
            }

            PanelWindow {
                id: toolsMenuPanel
                screen: screenDelegate.modelData
                visible: screenDelegate.toolsMenuVisible && bar.panelsVisible
                color: "transparent"
                exclusiveZone: -1
                anchors { top: true; bottom: true; left: true; right: true }

                focusable: true
                onVisibleChanged: {
                    if (visible) {
                        toolsContainer.opacity = 0
                        toolsContainer.y = bar.implicitHeight + 5 - 8
                        toolsOpenAnim.restart()
                        toolsEscScope.forceActiveFocus()
                    }
                }
                Item { id: toolsEscScope; focus: true; Keys.onEscapePressed: screenDelegate.closeAllPanels() }
                ParallelAnimation {
                    id: toolsOpenAnim
                    NumberAnimation { target: toolsContainer; property: "opacity"; from: 0; to: 1; duration: 200; easing.type: Easing.OutCubic }
                    NumberAnimation { target: toolsContainer; property: "y"; from: bar.implicitHeight + 5 - 8; to: bar.implicitHeight + 5; duration: 200; easing.type: Easing.OutCubic }
                }

                Component.onCompleted: {
                    if (this.WlrLayershell != null) {
                        this.WlrLayershell.layer = WlrLayer.Overlay
                        this.WlrLayershell.keyboardFocus = WlrKeyboardFocus.Exclusive
                        this.WlrLayershell.namespace = "quickshell-tools-menu"
                    }
                }

                MouseArea { anchors.fill: parent; onClicked: screenDelegate.closeAllPanels() }

                Item {
                    id: toolsContainer
                    x: parent.width - 188 - screenDelegate.toolsMenuMarginRight
                    y: bar.implicitHeight + 5
                    width: 188
                    height: 168
                    MouseArea { anchors.fill: parent }
                    Rectangle {
                        id: toolsShadow
                        anchors.fill: parent
                        anchors.leftMargin: 2
                        anchors.topMargin: 3
                        z: -1
                        radius: 14
                        color: shellRoot.shellColors.panelShadow
                    }
                    Rectangle {
                        id: toolsBg
                        anchors.fill: parent
                        radius: 12
                        color: shellRoot.shellColors.surfaceContainer
                        border.width: 1
                        border.color: shellRoot.shellColors.borderSubtle
                        ToolsMenuContent {
                            anchors.fill: parent
                            anchors.margins: 4
                            colors: shellRoot.shellColors
                            compositorName: shellRoot.compositorName
                            screenshotWidget: screenDelegate.screenshotWidgetRef
                            onClose: function() { screenDelegate.toolsMenuVisible = false }
                            onClipboardRequested: {
                                screenDelegate.clipboardPanelVisible = !screenDelegate.clipboardPanelVisible
                            }
                            onKeybindsRequested: {
                                screenDelegate.keybindsPanelVisible = !screenDelegate.keybindsPanelVisible
                            }
                            onScreenshotMenuRequested: {
                                if (!screenDelegate.screenshotMenuVisible) {
                                    var pt = toolsMenuWidget.mapToItem(root, 0, 0)
                                    var screenW = root.width || 1920
                                    screenDelegate.screenshotMenuMarginLeft = Math.max(0, Math.floor(screenW - screenDelegate.toolsMenuMarginRight - 168))
                                }
                                screenDelegate.screenshotMenuVisible = !screenDelegate.screenshotMenuVisible
                            }
                        }
                    }
                }
            }

            PanelWindow {
                id: screenshotMenuPanel
                screen: screenDelegate.modelData
                visible: screenDelegate.screenshotMenuVisible && bar.panelsVisible
                color: "transparent"
                exclusiveZone: -1
                anchors { top: true; bottom: true; left: true; right: true }

                focusable: true
                onVisibleChanged: {
                    if (visible) {
                        ssContainer.opacity = 0
                        ssContainer.y = bar.implicitHeight + 5 - 8
                        ssMenuOpenAnim.restart()
                        ssEscScope.forceActiveFocus()
                    }
                }
                Item { id: ssEscScope; focus: true; Keys.onEscapePressed: screenDelegate.closeAllPanels() }
                ParallelAnimation {
                    id: ssMenuOpenAnim
                    NumberAnimation { target: ssContainer; property: "opacity"; from: 0; to: 1; duration: 200; easing.type: Easing.OutCubic }
                    NumberAnimation { target: ssContainer; property: "y"; from: bar.implicitHeight + 5 - 8; to: bar.implicitHeight + 5; duration: 200; easing.type: Easing.OutCubic }
                }

                Component.onCompleted: {
                    if (this.WlrLayershell != null) {
                        this.WlrLayershell.layer = WlrLayer.Overlay
                        this.WlrLayershell.keyboardFocus = WlrKeyboardFocus.Exclusive
                        this.WlrLayershell.namespace = "quickshell-screenshot-menu"
                    }
                }

                MouseArea { anchors.fill: parent; onClicked: screenDelegate.closeAllPanels() }

                Item {
                    id: ssContainer
                    x: screenDelegate.screenshotMenuMarginLeft
                    y: bar.implicitHeight + 5
                    width: 168
                    height: 128
                    MouseArea { anchors.fill: parent }
                    Rectangle {
                        id: ssMenuShadow
                        anchors.fill: parent
                        anchors.leftMargin: 2
                        anchors.topMargin: 3
                        z: -1
                        radius: 14
                        color: shellRoot.shellColors.panelShadow
                    }
                    Rectangle {
                        id: ssMenuBg
                        anchors.fill: parent
                        radius: 12
                        color: shellRoot.shellColors.surfaceContainer
                        border.width: 1
                        border.color: shellRoot.shellColors.borderSubtle
                        ScreenshotMenuContent {
                            id: ssMenuContentItem
                            anchors.fill: parent
                            anchors.margins: 4
                            colors: shellRoot.shellColors
                            screenshotWidget: screenDelegate.screenshotWidgetRef
                            onClose: function() { screenDelegate.screenshotMenuVisible = false }
                        }
                    }
                }
            }

            PanelWindow {
                id: workspaceOverviewPanel
                screen: screenDelegate.modelData
                visible: (screenDelegate.workspaceOverviewVisible || shellRoot.workspaceOverviewTriggered) && bar.panelsVisible && bar.compositorName === "hyprland"
                color: "transparent"
                exclusiveZone: -1
                anchors { top: true; bottom: true; left: true; right: true }

                focusable: true
                onVisibleChanged: {
                    if (visible) {
                        wsContainer.opacity = 0
                        wsContainer.y = bar.implicitHeight + 5 - 8
                        wsOverviewOpenAnim.restart()
                        wsEscScope.forceActiveFocus()
                    }
                }
                Item { id: wsEscScope; focus: true; Keys.onEscapePressed: screenDelegate.closeAllPanels() }
                ParallelAnimation {
                    id: wsOverviewOpenAnim
                    NumberAnimation { target: wsContainer; property: "opacity"; from: 0; to: 1; duration: 200; easing.type: Easing.OutCubic }
                    NumberAnimation { target: wsContainer; property: "y"; from: bar.implicitHeight + 5 - 8; to: bar.implicitHeight + 5; duration: 200; easing.type: Easing.OutCubic }
                }

                Component.onCompleted: {
                    if (this.WlrLayershell != null) {
                        this.WlrLayershell.layer = WlrLayer.Overlay
                        this.WlrLayershell.keyboardFocus = WlrKeyboardFocus.Exclusive
                        this.WlrLayershell.namespace = "quickshell-workspace-overview"
                    }
                }

                MouseArea { anchors.fill: parent; onClicked: screenDelegate.closeAllPanels() }

                Item {
                    id: wsContainer
                    x: 12
                    y: bar.implicitHeight + 5
                    width: 320
                    height: Math.min(overviewContent.implicitHeight + 24, 600)
                    MouseArea { anchors.fill: parent }
                    Rectangle {
                        id: wsOverviewShadow
                        anchors.fill: parent
                        anchors.leftMargin: 2
                        anchors.topMargin: 3
                        z: -1
                        radius: 14
                        color: shellRoot.shellColors.panelShadow
                    }
                    Rectangle {
                        id: wsOverviewBg
                        anchors.fill: parent
                        radius: 12
                        color: shellRoot.shellColors.surfaceContainer
                        border.width: 1
                        border.color: shellRoot.shellColors.borderSubtle
                        Flickable {
                            id: wsOverviewFlick
                            anchors.fill: parent
                            anchors.margins: 12
                            contentWidth: overviewContent.width
                            contentHeight: overviewContent.implicitHeight
                            clip: true
                            flickableDirection: Flickable.VerticalFlick
                            boundsBehavior: Flickable.StopAtBounds
                            WorkspaceOverviewContent {
                                id: overviewContent
                                width: 320 - 24
                                colors: shellRoot.shellColors
                                hyprMonitor: root.hyprMonitor
                                clientsByWorkspace: root.clientsByWorkspace
                                activeWindowAddress: root.activeWindowAddress
                                onClose: function() {
                                    screenDelegate.workspaceOverviewVisible = false
                                    shellRoot.workspaceOverviewTriggered = false
                                }
                            }
                        }
                        MouseArea {
                            anchors.fill: parent
                            anchors.margins: 12
                            acceptedButtons: Qt.MiddleButton
                            onWheel: function(wheel) {
                                var step = (wheel.angleDelta.y / 120) * 80
                                wsOverviewFlick.contentY = Math.max(0, Math.min(wsOverviewFlick.contentY - step, Math.max(0, wsOverviewFlick.contentHeight - wsOverviewFlick.height)))
                            }
                        }
                    }
                }
            }

            PanelWindow {
                id: clipboardPanel
                screen: screenDelegate.modelData
                visible: screenDelegate.clipboardPanelVisible && bar.panelsVisible
                color: "transparent"
                exclusiveZone: -1
                anchors { top: true; bottom: true; left: true; right: true }

                focusable: true
                onVisibleChanged: {
                    if (visible) {
                        clipContainer.opacity = 0
                        clipContainer.y = bar.implicitHeight + 5 - 8
                        clipOpenAnim.restart()
                        clipContent.refresh()
                        clipEscScope.forceActiveFocus()
                    }
                }
                Item { id: clipEscScope; focus: true; Keys.onEscapePressed: screenDelegate.closeAllPanels() }
                ParallelAnimation {
                    id: clipOpenAnim
                    NumberAnimation { target: clipContainer; property: "opacity"; from: 0; to: 1; duration: 200; easing.type: Easing.OutCubic }
                    NumberAnimation { target: clipContainer; property: "y"; from: bar.implicitHeight + 5 - 8; to: bar.implicitHeight + 5; duration: 200; easing.type: Easing.OutCubic }
                }

                Component.onCompleted: {
                    if (this.WlrLayershell != null) {
                        this.WlrLayershell.layer = WlrLayer.Overlay
                        this.WlrLayershell.keyboardFocus = WlrKeyboardFocus.Exclusive
                        this.WlrLayershell.namespace = "quickshell-clipboard"
                    }
                }

                MouseArea { anchors.fill: parent; onClicked: screenDelegate.closeAllPanels() }

                Item {
                    id: clipContainer
                    x: parent.width - 560 - 8
                    y: bar.implicitHeight + 5
                    width: 560
                    height: Math.min(Math.max(300, clipContent.desiredHeight + 24), 600)
                    MouseArea { anchors.fill: parent }
                    Rectangle {
                        id: clipShadow
                        anchors.fill: parent
                        anchors.leftMargin: 2
                        anchors.topMargin: 3
                        z: -1
                        radius: 14
                        color: shellRoot.shellColors.panelShadow
                    }
                    Rectangle {
                        id: clipBg
                        anchors.fill: parent
                        radius: 12
                        color: shellRoot.shellColors.surfaceContainer
                        border.width: 1
                        border.color: shellRoot.shellColors.borderSubtle
                        ClipboardContent {
                            id: clipContent
                            anchors.fill: parent
                            anchors.margins: 12
                            colors: shellRoot.shellColors
                            onClose: function() { screenDelegate.clipboardPanelVisible = false }
                        }
                    }
                }
            }

            PanelWindow {
                id: keybindsPanel
                screen: screenDelegate.modelData
                visible: screenDelegate.keybindsPanelVisible && bar.panelsVisible
                color: "transparent"
                exclusiveZone: -1
                anchors { top: true; bottom: true; left: true; right: true }

                focusable: true
                onVisibleChanged: {
                    if (visible) {
                        kbContainer.opacity = 0
                        kbContainer.y = bar.implicitHeight + 5 - 8
                        kbOpenAnim.restart()
                        kbContent.refresh()
                        kbEscScope.forceActiveFocus()
                    }
                }
                Item { id: kbEscScope; focus: true; Keys.onEscapePressed: screenDelegate.closeAllPanels() }
                ParallelAnimation {
                    id: kbOpenAnim
                    NumberAnimation { target: kbContainer; property: "opacity"; from: 0; to: 1; duration: 200; easing.type: Easing.OutCubic }
                    NumberAnimation { target: kbContainer; property: "y"; from: bar.implicitHeight + 5 - 8; to: bar.implicitHeight + 5; duration: 200; easing.type: Easing.OutCubic }
                }

                Component.onCompleted: {
                    if (this.WlrLayershell != null) {
                        this.WlrLayershell.layer = WlrLayer.Overlay
                        this.WlrLayershell.keyboardFocus = WlrKeyboardFocus.Exclusive
                        this.WlrLayershell.namespace = "quickshell-keybinds"
                    }
                }

                MouseArea { anchors.fill: parent; onClicked: screenDelegate.closeAllPanels() }

                Item {
                    id: kbContainer
                    x: parent.width - 420 - 8
                    y: bar.implicitHeight + 5
                    width: 420
                    height: Math.min(Math.max(300, kbContent.desiredHeight + 24), 600)
                    MouseArea { anchors.fill: parent }
                    Rectangle {
                        id: kbShadow
                        anchors.fill: parent
                        anchors.leftMargin: 2
                        anchors.topMargin: 3
                        z: -1
                        radius: 14
                        color: shellRoot.shellColors.panelShadow
                    }
                    Rectangle {
                        id: kbBg
                        anchors.fill: parent
                        radius: 12
                        color: shellRoot.shellColors.surfaceContainer
                        border.width: 1
                        border.color: shellRoot.shellColors.borderSubtle
                        KeybindsContent {
                            id: kbContent
                            anchors.fill: parent
                            anchors.margins: 12
                            colors: shellRoot.shellColors
                            onClose: function() { screenDelegate.keybindsPanelVisible = false }
                        }
                    }
                }
            }

            PanelWindow {
                id: calendarPanel
                screen: screenDelegate.modelData
                visible: screenDelegate.calendarVisible && bar.panelsVisible
                color: "transparent"
                exclusiveZone: -1
                anchors { top: true; bottom: true; left: true; right: true }

                focusable: true
                onVisibleChanged: {
                    if (visible) {
                        calContainer.opacity = 0
                        calContainer.y = bar.implicitHeight + 5 - 8
                        calOpenAnim.restart()
                        calEscScope.forceActiveFocus()
                    }
                }
                Item { id: calEscScope; focus: true; Keys.onEscapePressed: screenDelegate.closeAllPanels() }
                ParallelAnimation {
                    id: calOpenAnim
                    NumberAnimation { target: calContainer; property: "opacity"; from: 0; to: 1; duration: 200; easing.type: Easing.OutCubic }
                    NumberAnimation { target: calContainer; property: "y"; from: bar.implicitHeight + 5 - 8; to: bar.implicitHeight + 5; duration: 200; easing.type: Easing.OutCubic }
                }

                Component.onCompleted: {
                    if (this.WlrLayershell != null) {
                        this.WlrLayershell.layer = WlrLayer.Overlay
                        this.WlrLayershell.keyboardFocus = WlrKeyboardFocus.Exclusive
                        this.WlrLayershell.namespace = "quickshell-calendar"
                    }
                }

                MouseArea { anchors.fill: parent; onClicked: screenDelegate.closeAllPanels() }

                Item {
                    id: calContainer
                    x: screenDelegate.calendarMarginLeft
                    y: bar.implicitHeight + 5
                    width: 200
                    height: 200
                    MouseArea { anchors.fill: parent }
                    Rectangle {
                        id: calShadow
                        anchors.fill: parent
                        anchors.leftMargin: 2
                        anchors.topMargin: 3
                        z: -1
                        radius: 14
                        color: shellRoot.shellColors.panelShadow
                    }
                    Rectangle {
                        id: calBg
                        anchors.fill: parent
                        radius: 12
                        color: shellRoot.shellColors.surfaceContainer
                        border.width: 1
                        border.color: shellRoot.shellColors.borderSubtle
                        CalendarContent {
                            id: calContentItem
                            anchors.fill: parent
                            anchors.margins: 1
                            colors: shellRoot.shellColors
                            calendarState: screenDelegate
                        }
                    }
                }
            }

            PanelWindow {
                id: nowPlayingPanel
                screen: screenDelegate.modelData
                visible: screenDelegate.nowPlayingPopupVisible && nowPlayingWidget.hasPlayer && bar.panelsVisible
                color: "transparent"
                exclusiveZone: -1
                anchors { top: true; bottom: true; left: true; right: true }

                focusable: true
                onVisibleChanged: {
                    if (visible) {
                        npContainer.opacity = 0
                        npContainer.y = bar.implicitHeight + 5 - 8
                        npOpenAnim.restart()
                        npEscScope.forceActiveFocus()
                    }
                }
                Item { id: npEscScope; focus: true; Keys.onEscapePressed: screenDelegate.closeAllPanels() }
                ParallelAnimation {
                    id: npOpenAnim
                    NumberAnimation { target: npContainer; property: "opacity"; from: 0; to: 1; duration: 200; easing.type: Easing.OutCubic }
                    NumberAnimation { target: npContainer; property: "y"; from: bar.implicitHeight + 5 - 8; to: bar.implicitHeight + 5; duration: 200; easing.type: Easing.OutCubic }
                }

                Component.onCompleted: {
                    if (this.WlrLayershell != null) {
                        this.WlrLayershell.layer = WlrLayer.Overlay
                        this.WlrLayershell.keyboardFocus = WlrKeyboardFocus.Exclusive
                        this.WlrLayershell.namespace = "quickshell-now-playing"
                    }
                }

                MouseArea { anchors.fill: parent; onClicked: screenDelegate.closeAllPanels() }

                Item {
                    id: npContainer
                    x: 8
                    y: bar.implicitHeight + 5
                    width: nowPlayingPanelContent.implicitWidth
                    height: nowPlayingPanelContent.implicitHeight
                    MouseArea { anchors.fill: parent }
                    Rectangle {
                        id: npShadow
                        anchors.fill: parent
                        anchors.leftMargin: 2
                        anchors.topMargin: 3
                        z: -1
                        radius: 14
                        color: shellRoot.shellColors.panelShadow
                    }
                    MiniPlayerContent {
                        id: nowPlayingPanelContent
                        anchors.fill: parent
                        colors: shellRoot.shellColors
                        player: nowPlayingWidget
                        isOpen: screenDelegate.nowPlayingPopupVisible
                        onClose: function() { screenDelegate.nowPlayingPopupVisible = false }
                    }
                }
            }

        }
    }
}
