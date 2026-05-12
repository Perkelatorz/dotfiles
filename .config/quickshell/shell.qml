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

    // Workspace overview trigger via Quickshell IPC.
    // Invoked by ~/.config/scripts/open-workspace-overview.sh (`qs ipc call shell openOverview`).
    // Replaces a previous 400ms file-poll on $XDG_RUNTIME_DIR/quickshell-open-overview.
    IpcHandler {
        target: "shell"
        function openOverview(): void {
            shellRoot.workspaceOverviewTriggered = true
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
                idleInhibitorWidgetVisible = false
                tailscaleWidgetVisible = false
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
            property bool claudeUsageVisible: false
            property int claudeUsageMarginRight: 0
            property bool weatherForecastVisible: false
            property int weatherForecastMarginRight: 0

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
                claudeUsageVisible = false
                weatherForecastVisible = false
            }
            property var screenshotWidgetRef: null
            property int screenshotMenuMarginLeft: 0
            property int calendarMarginLeft: 0
            property int nowPlayingMarginLeft: 0
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
            property bool workspaceOverviewWidgetVisible: true
            property bool idleInhibitorWidgetVisible: true
            property bool tailscaleWidgetVisible: true

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
                    "powerProfile=" + (powerProfileWidgetVisible ? "true" : "false"),
                    "idleInhibitor=" + (idleInhibitorWidgetVisible ? "true" : "false"),
                    "tailscale=" + (tailscaleWidgetVisible ? "true" : "false")
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
                            if (typeof o.idleInhibitor === "boolean") screenDelegate.idleInhibitorWidgetVisible = o.idleInhibitor
                            if (typeof o.tailscale === "boolean") screenDelegate.tailscaleWidgetVisible = o.tailscale
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
                                        var pt = nowPlayingWidget.mapToItem(root, 0, 0)
                                        screenDelegate.nowPlayingMarginLeft = Math.max(8, Math.floor(pt.x))
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
                                    id: weatherWidget
                                    colors: shellRoot.shellColors
                                    Layout.alignment: Qt.AlignVCenter
                                    visible: screenDelegate.weatherWidgetVisible
                                    onOpenForecastRequested: {
                                        var screenW = (screenDelegate.modelData && screenDelegate.modelData.geometry) ? screenDelegate.modelData.geometry.width : root.width
                                        var pt = weatherWidget.mapToItem(root, 0, 0)
                                        screenDelegate.weatherForecastMarginRight = Math.max(8, Math.floor(screenW - pt.x - weatherWidget.width / 2 - 160))
                                        var wasOpen = screenDelegate.weatherForecastVisible
                                        screenDelegate.closeAllPanels()
                                        screenDelegate.weatherForecastVisible = !wasOpen
                                    }
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

                                IdleInhibitorWidget {
                                    colors: shellRoot.shellColors
                                    Layout.alignment: Qt.AlignVCenter
                                    visible: screenDelegate.idleInhibitorWidgetVisible
                                }

                                TailscaleWidget {
                                    colors: shellRoot.shellColors
                                    Layout.alignment: Qt.AlignVCenter
                                    visible: screenDelegate.tailscaleWidgetVisible
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

                                ClaudeUsageWidget {
                                    id: claudeUsageWidget
                                    colors: shellRoot.shellColors
                                    Layout.alignment: Qt.AlignVCenter
                                    onToggleRequested: {
                                        var wasOpen = screenDelegate.claudeUsageVisible
                                        screenDelegate.closeAllPanels()
                                        if (!wasOpen) {
                                            var pt = claudeUsageWidget.mapToItem(root, 0, 0)
                                            var screenW = root.width || 1920
                                            screenDelegate.claudeUsageMarginRight = Math.max(0, Math.floor(screenW - pt.x - claudeUsageWidget.width / 2 - 140))
                                            screenDelegate.claudeUsageVisible = true
                                        }
                                    }
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

            PopupPanel {
                id: quickSettingsPanel
                screen: screenDelegate.modelData
                visible: screenDelegate.quickSettingsMenuVisible && bar.panelsVisible
                colors: shellRoot.shellColors
                layershellNamespace: "quickshell-quick-settings"
                barHeight: bar.implicitHeight
                containerWidth: 440
                containerHeight: screenDelegate.quickSettingsSubView === "settings"
                    ? Math.min(qsSettingsContent.implicitHeight + 60, 500)
                    : (screenDelegate.quickSettingsSubView === "power"
                        ? Math.min(qsPowerContent.implicitHeight + 60, 400)
                        : Math.min(qsContent.implicitHeight + 40, 700))
                onCloseRequested: screenDelegate.closeAllPanels()

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

            PopupPanel {
                id: weatherForecastPanel
                screen: screenDelegate.modelData
                visible: screenDelegate.weatherForecastVisible && bar.panelsVisible
                colors: shellRoot.shellColors
                layershellNamespace: "quickshell-weather-forecast"
                barHeight: bar.implicitHeight
                containerX: weatherForecastPanel.width - 320 - screenDelegate.weatherForecastMarginRight
                containerWidth: 320
                containerHeight: weatherForecastContent.implicitHeight
                showBackground: false
                onCloseRequested: screenDelegate.closeAllPanels()

                WeatherForecastContent {
                    id: weatherForecastContent
                    anchors.fill: parent
                    colors: shellRoot.shellColors
                    onClose: function() { screenDelegate.weatherForecastVisible = false }
                }
            }

            PopupPanel {
                id: claudeUsagePanel
                screen: screenDelegate.modelData
                visible: screenDelegate.claudeUsageVisible && bar.panelsVisible
                colors: shellRoot.shellColors
                layershellNamespace: "quickshell-claude-usage"
                barHeight: bar.implicitHeight
                containerX: claudeUsagePanel.width - 300 - screenDelegate.claudeUsageMarginRight
                containerWidth: 300
                containerHeight: cuContentItem.implicitHeight + 8
                onCloseRequested: screenDelegate.closeAllPanels()

                ClaudeUsageContent {
                    id: cuContentItem
                    anchors.fill: parent
                    anchors.margins: 4
                    colors: shellRoot.shellColors
                    onClose: function() { screenDelegate.claudeUsageVisible = false }
                }
            }

            PopupPanel {
                id: toolsMenuPanel
                screen: screenDelegate.modelData
                visible: screenDelegate.toolsMenuVisible && bar.panelsVisible
                colors: shellRoot.shellColors
                layershellNamespace: "quickshell-tools-menu"
                barHeight: bar.implicitHeight
                containerX: toolsMenuPanel.width - 188 - screenDelegate.toolsMenuMarginRight
                containerWidth: 188
                containerHeight: 168
                onCloseRequested: screenDelegate.closeAllPanels()

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

            PopupPanel {
                id: screenshotMenuPanel
                screen: screenDelegate.modelData
                visible: screenDelegate.screenshotMenuVisible && bar.panelsVisible
                colors: shellRoot.shellColors
                layershellNamespace: "quickshell-screenshot-menu"
                barHeight: bar.implicitHeight
                containerX: screenDelegate.screenshotMenuMarginLeft
                containerWidth: 168
                containerHeight: 128
                onCloseRequested: screenDelegate.closeAllPanels()

                ScreenshotMenuContent {
                    anchors.fill: parent
                    anchors.margins: 4
                    colors: shellRoot.shellColors
                    screenshotWidget: screenDelegate.screenshotWidgetRef
                    onClose: function() { screenDelegate.screenshotMenuVisible = false }
                }
            }

            PopupPanel {
                id: workspaceOverviewPanel
                screen: screenDelegate.modelData
                visible: (screenDelegate.workspaceOverviewVisible || shellRoot.workspaceOverviewTriggered) && bar.panelsVisible && bar.compositorName === "hyprland"
                colors: shellRoot.shellColors
                layershellNamespace: "quickshell-workspace-overview"
                barHeight: bar.implicitHeight
                containerX: 12
                containerWidth: 320
                containerHeight: Math.min(overviewContent.implicitHeight + 24, 600)
                onCloseRequested: screenDelegate.closeAllPanels()

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

            PopupPanel {
                id: clipboardPanel
                screen: screenDelegate.modelData
                visible: screenDelegate.clipboardPanelVisible && bar.panelsVisible
                colors: shellRoot.shellColors
                layershellNamespace: "quickshell-clipboard"
                barHeight: bar.implicitHeight
                containerWidth: 560
                containerHeight: Math.min(Math.max(300, clipContent.desiredHeight + 24), 600)
                onCloseRequested: screenDelegate.closeAllPanels()
                onOpened: clipContent.refresh()

                ClipboardContent {
                    id: clipContent
                    anchors.fill: parent
                    anchors.margins: 12
                    colors: shellRoot.shellColors
                    onClose: function() { screenDelegate.clipboardPanelVisible = false }
                }
            }

            PopupPanel {
                id: keybindsPanel
                screen: screenDelegate.modelData
                visible: screenDelegate.keybindsPanelVisible && bar.panelsVisible
                colors: shellRoot.shellColors
                layershellNamespace: "quickshell-keybinds"
                barHeight: bar.implicitHeight
                containerWidth: 420
                containerHeight: Math.min(Math.max(300, kbContent.desiredHeight + 24), 600)
                onCloseRequested: screenDelegate.closeAllPanels()
                onOpened: kbContent.refresh()

                KeybindsContent {
                    id: kbContent
                    anchors.fill: parent
                    anchors.margins: 12
                    colors: shellRoot.shellColors
                    onClose: function() { screenDelegate.keybindsPanelVisible = false }
                }
            }

            PopupPanel {
                id: calendarPanel
                screen: screenDelegate.modelData
                visible: screenDelegate.calendarVisible && bar.panelsVisible
                colors: shellRoot.shellColors
                layershellNamespace: "quickshell-calendar"
                barHeight: bar.implicitHeight
                containerX: screenDelegate.calendarMarginLeft
                containerWidth: 200
                containerHeight: 200
                onCloseRequested: screenDelegate.closeAllPanels()

                CalendarContent {
                    anchors.fill: parent
                    anchors.margins: 1
                    colors: shellRoot.shellColors
                    calendarState: screenDelegate
                }
            }

            PopupPanel {
                id: nowPlayingPanel
                screen: screenDelegate.modelData
                visible: screenDelegate.nowPlayingPopupVisible && nowPlayingWidget.hasPlayer && bar.panelsVisible
                colors: shellRoot.shellColors
                layershellNamespace: "quickshell-now-playing"
                barHeight: bar.implicitHeight
                containerX: screenDelegate.nowPlayingMarginLeft
                containerWidth: nowPlayingPanelContent.implicitWidth
                containerHeight: nowPlayingPanelContent.implicitHeight
                showBackground: false
                onCloseRequested: screenDelegate.closeAllPanels()

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
