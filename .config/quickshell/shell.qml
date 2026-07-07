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
    // Synchronous env read — no subprocess, no race where widgets briefly see
    // the wrong compositor before async detection lands.
    readonly property string compositorName: {
        var s = (Quickshell.env("XDG_CURRENT_DESKTOP") || "").toLowerCase()
        if (s.indexOf("hyprland") >= 0) return "hyprland"
        if (s.indexOf("niri") >= 0) return "niri"
        return "other"
    }

    function refreshFullscreenMonitors() {
        if (compositorName === "hyprland" && !fullscreenProcess.running)
            fullscreenProcess.running = true
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

    // Brightness OSD trigger: the brightness keys ping this over IPC because
    // brightnessctl changes brightness outside Quickshell (nothing to watch).
    property int osdBrightnessNonce: 0
    IpcHandler {
        target: "osd"
        function brightness(): void {
            SystemServices._refreshBrightness()
            shellRoot.osdBrightnessNonce++
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
            property bool toolsMenuVisible: false
            property int toolsMenuMarginRight: 0
            property bool weatherForecastVisible: false
            property int weatherForecastMarginRight: 0
            property bool performancePanelVisible: false
            property int performancePanelMarginRight: 0
            property bool tailscalePanelVisible: false
            property int tailscalePanelMarginRight: 0

            function closeAllPanels() {
                calendarVisible = false
                nowPlayingPopupVisible = false
                quickSettingsMenuVisible = false
                toolsMenuVisible = false
                weatherForecastVisible = false
                performancePanelVisible = false
                tailscalePanelVisible = false
            }
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
            property bool clockWidgetVisible: true
            property bool weatherWidgetVisible: false
            property bool updatesWidgetVisible: true
            property bool netSpeedWidgetVisible: true
            property bool notificationsWidgetVisible: true
            property bool powerProfileWidgetVisible: false
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

                    // Fallback only — Hyprland raw events (above) drive refreshes;
                    // this just catches anything an event miss could leave stale.
                    Timer {
                        interval: 10000
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
                                var wasOpen = screenDelegate.nowPlayingPopupVisible
                                screenDelegate.closeAllPanels()
                                var pt = nowPlayingWidget.mapToItem(root, 0, 0)
                                screenDelegate.nowPlayingMarginLeft = Math.max(8, Math.floor(pt.x))
                                screenDelegate.nowPlayingPopupVisible = !wasOpen
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
                                // Blocks style abuts widgets into one segmented
                                // strip; every other style keeps breathing room.
                                spacing: BarStyle.style === "blocks" ? 1 : 6
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
                                    id: tailscaleWidget
                                    colors: shellRoot.shellColors
                                    Layout.alignment: Qt.AlignVCenter
                                    visible: screenDelegate.tailscaleWidgetVisible
                                    onToggleRequested: {
                                        var wasOpen = screenDelegate.tailscalePanelVisible
                                        screenDelegate.closeAllPanels()
                                        if (!wasOpen) {
                                            var pt = tailscaleWidget.mapToItem(root, 0, 0)
                                            var screenW = root.width || 1920
                                            screenDelegate.tailscalePanelMarginRight = Math.max(0, Math.floor(screenW - pt.x - tailscaleWidget.width / 2 - 134))
                                            screenDelegate.tailscalePanelVisible = true
                                        }
                                    }
                                }

                                PerformanceWidget {
                                    id: performanceWidget
                                    colors: shellRoot.shellColors
                                    Layout.alignment: Qt.AlignVCenter
                                    visible: screenDelegate.performanceWidgetVisible
                                    onToggleRequested: {
                                        var wasOpen = screenDelegate.performancePanelVisible
                                        screenDelegate.closeAllPanels()
                                        if (!wasOpen) {
                                            var pt = performanceWidget.mapToItem(root, 0, 0)
                                            var screenW = root.width || 1920
                                            screenDelegate.performancePanelMarginRight = Math.max(0, Math.floor(screenW - pt.x - performanceWidget.width / 2 - 160))
                                            screenDelegate.performancePanelVisible = true
                                        }
                                    }
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

                                ToolsMenuWidget {
                                    id: toolsMenuWidget
                                    colors: shellRoot.shellColors
                                    Layout.alignment: Qt.AlignVCenter
                                    onToggleRequested: {
                                        var wasOpen = screenDelegate.toolsMenuVisible
                                        screenDelegate.closeAllPanels()
                                        if (!wasOpen) {
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
                                        var wasOpen = screenDelegate.calendarVisible
                                        screenDelegate.closeAllPanels()
                                        screenDelegate.calendarVisible = !wasOpen
                                        if (screenDelegate.calendarVisible) {
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

                                // Appears only while mic/screen is being captured
                                // (no toggle — presence IS the signal).
                                PrivacyIndicatorWidget {
                                    colors: shellRoot.shellColors
                                    Layout.alignment: Qt.AlignVCenter
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
                                        var wasOpen = screenDelegate.quickSettingsMenuVisible
                                        screenDelegate.closeAllPanels()
                                        screenDelegate.quickSettingsMenuVisible = !wasOpen
                                        if (screenDelegate.quickSettingsMenuVisible)
                                            screenDelegate.quickSettingsSubView = "main"
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
                    : screenDelegate.quickSettingsSubView === "power"
                        ? Math.min(qsPowerContent.implicitHeight + 60, 400)
                    : (screenDelegate.quickSettingsSubView === "wifi" || screenDelegate.quickSettingsSubView === "bluetooth")
                        ? 460
                    : Math.min(qsContent.implicitHeight + 40, 700)
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
                            text: screenDelegate.quickSettingsSubView === "power" ? "Power"
                                : screenDelegate.quickSettingsSubView === "wifi" ? "Wi-Fi"
                                : screenDelegate.quickSettingsSubView === "bluetooth" ? "Bluetooth"
                                : "Widgets & settings"
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
                                onOpenWifiRequested: screenDelegate.quickSettingsSubView = "wifi"
                                onOpenBluetoothRequested: screenDelegate.quickSettingsSubView = "bluetooth"
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
                        Item {
                            visible: screenDelegate.quickSettingsSubView === "wifi"
                            anchors.fill: parent
                            WifiContent {
                                anchors.fill: parent
                                anchors.margins: 8
                                colors: shellRoot.shellColors
                                panelOpen: screenDelegate.quickSettingsSubView === "wifi" && screenDelegate.quickSettingsMenuVisible
                            }
                        }
                        Item {
                            visible: screenDelegate.quickSettingsSubView === "bluetooth"
                            anchors.fill: parent
                            BluetoothContent {
                                anchors.fill: parent
                                anchors.margins: 8
                                colors: shellRoot.shellColors
                                panelOpen: screenDelegate.quickSettingsSubView === "bluetooth" && screenDelegate.quickSettingsMenuVisible
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
                id: performancePanel
                screen: screenDelegate.modelData
                visible: screenDelegate.performancePanelVisible && bar.panelsVisible
                colors: shellRoot.shellColors
                layershellNamespace: "quickshell-performance"
                barHeight: bar.implicitHeight
                containerX: performancePanel.width - 320 - screenDelegate.performancePanelMarginRight
                containerWidth: 320
                containerHeight: perfContentItem.implicitHeight + 8
                onCloseRequested: screenDelegate.closeAllPanels()

                PerformanceContent {
                    id: perfContentItem
                    anchors.fill: parent
                    anchors.margins: 4
                    colors: shellRoot.shellColors
                    panelOpen: performancePanel.visible
                    onClose: function() { screenDelegate.performancePanelVisible = false }
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
                containerHeight: toolsContentItem.implicitHeight + 8
                onCloseRequested: screenDelegate.closeAllPanels()

                ToolsMenuContent {
                    id: toolsContentItem
                    anchors.fill: parent
                    anchors.margins: 4
                    colors: shellRoot.shellColors
                    compositorName: shellRoot.compositorName
                    onClose: function() { screenDelegate.toolsMenuVisible = false }
                }
            }

            PopupPanel {
                id: tailscalePanel
                screen: screenDelegate.modelData
                visible: screenDelegate.tailscalePanelVisible && bar.panelsVisible
                colors: shellRoot.shellColors
                layershellNamespace: "quickshell-tailscale"
                barHeight: bar.implicitHeight
                containerX: tailscalePanel.width - 268 - screenDelegate.tailscalePanelMarginRight
                containerWidth: 268
                containerHeight: tsContentItem.implicitHeight + 8
                onCloseRequested: screenDelegate.closeAllPanels()

                TailscaleContent {
                    id: tsContentItem
                    anchors.fill: parent
                    anchors.margins: 4
                    colors: shellRoot.shellColors
                    panelOpen: tailscalePanel.visible
                    onClose: function() { screenDelegate.tailscalePanelVisible = false }
                }
            }

            OsdOverlay {
                colors: shellRoot.shellColors
                screenObj: screenDelegate.modelData
                brightnessNonce: shellRoot.osdBrightnessNonce
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
