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

    function refreshFullscreenMonitors() {
        fullscreenProcess.running = true
    }

    Process {
        id: fullscreenProcess
        command: ["hyprctl", "clients", "-j"]
        stdout: StdioCollector {
            onStreamFinished: {
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
        function onRawEvent(event) {
            var n = event.name || ""
            if (n === "fullscreen") {
                shellRoot.refreshFullscreenMonitors()
            }
        }
    }

    // Refresh fullscreen list on startup and periodically so bar hides after restart (e.g. wallpaper refresh)
    Component.onCompleted: Qt.callLater(shellRoot.refreshFullscreenMonitors)
    Timer {
        interval: 400
        repeat: false
        running: true
        onTriggered: shellRoot.refreshFullscreenMonitors()
    }
    Timer {
        interval: 1500
        repeat: false
        running: true
        onTriggered: shellRoot.refreshFullscreenMonitors()
    }

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
            onIsVerticalScreenChanged: {
                if (screenDelegate.isVerticalScreen) {
                    volumeWidgetVisible = false
                    nowPlayingWidgetVisible = false
                    cpuWidgetVisible = false
                    ramWidgetVisible = false
                    batteryWidgetVisible = false
                    brightnessWidgetVisible = false
                    microphoneWidgetVisible = false
                    ipAddressWidgetVisible = false
                    screenshotWidgetVisible = false
                }
            }
            property bool calendarVisible: false
            property bool nowPlayingPopupVisible: false
            property bool quickSettingsMenuVisible: false
            property string quickSettingsSubView: "main"
            property bool screenshotMenuVisible: false
            property var screenshotWidgetRef: null
            property int screenshotMenuMarginLeft: 0
            property int calendarMarginLeft: 0
            // Widget visibility (toggle from settings menu)
            property bool volumeWidgetVisible: true
            property bool nowPlayingWidgetVisible: true
            property bool cpuWidgetVisible: true
            property bool ramWidgetVisible: true
            property bool batteryWidgetVisible: true
            property bool brightnessWidgetVisible: true
            property bool microphoneWidgetVisible: true
            property bool ipAddressWidgetVisible: true
            property bool screenshotWidgetVisible: true
            property bool clockWidgetVisible: true

            function loadBarWidgets() {
                loadBarWidgetsProc.running = true
            }
            function saveWidgetVisibility() {
                var dir = "$HOME/.config/quickshell"
                var args = [
                    "volume=" + (volumeWidgetVisible ? "true" : "false"),
                    "nowPlaying=" + (nowPlayingWidgetVisible ? "true" : "false"),
                    "cpu=" + (cpuWidgetVisible ? "true" : "false"),
                    "ram=" + (ramWidgetVisible ? "true" : "false"),
                    "battery=" + (batteryWidgetVisible ? "true" : "false"),
                    "brightness=" + (brightnessWidgetVisible ? "true" : "false"),
                    "microphone=" + (microphoneWidgetVisible ? "true" : "false"),
                    "ipAddress=" + (ipAddressWidgetVisible ? "true" : "false"),
                    "screenshot=" + (screenshotWidgetVisible ? "true" : "false"),
                    "clock=" + (clockWidgetVisible ? "true" : "false")
                ]
                saveBarWidgetsProc.command = ["sh", "-c", "SCRIPT=\"${XDG_CONFIG_HOME:-$HOME/.config}/quickshell/write-bar-widgets.sh\"; exec \"$SCRIPT\" " + args.join(" ")]
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
                            if (typeof o.cpu === "boolean") screenDelegate.cpuWidgetVisible = o.cpu
                            if (typeof o.ram === "boolean") screenDelegate.ramWidgetVisible = o.ram
                            if (typeof o.battery === "boolean") screenDelegate.batteryWidgetVisible = o.battery
                            if (typeof o.brightness === "boolean") screenDelegate.brightnessWidgetVisible = o.brightness
                            if (typeof o.microphone === "boolean") screenDelegate.microphoneWidgetVisible = o.microphone
                            if (typeof o.ipAddress === "boolean") screenDelegate.ipAddressWidgetVisible = o.ipAddress
                            if (typeof o.screenshot === "boolean") screenDelegate.screenshotWidgetVisible = o.screenshot
                            if (typeof o.clock === "boolean") screenDelegate.clockWidgetVisible = o.clock
                            if (screenDelegate.isVerticalScreen) {
                                screenDelegate.volumeWidgetVisible = false
                                screenDelegate.nowPlayingWidgetVisible = false
                                screenDelegate.cpuWidgetVisible = false
                                screenDelegate.ramWidgetVisible = false
                                screenDelegate.batteryWidgetVisible = false
                                screenDelegate.brightnessWidgetVisible = false
                                screenDelegate.microphoneWidgetVisible = false
                                screenDelegate.ipAddressWidgetVisible = false
                                screenDelegate.screenshotWidgetVisible = false
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
                property var hyprMonitor: Hyprland.monitorFor(modelData)

                screen: screenDelegate.modelData
                visible: !bar.hyprMonitor || shellRoot.fullscreenMonitorNames.indexOf(bar.hyprMonitor.name) < 0

                anchors {
                    left: true
                    right: true
                    top: true
                }
                implicitHeight: 28
                color: shellRoot.shellColors.background

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
                    property string activeWindowAddress: ""

                    function refreshClients() {
                        if (root.hyprMonitor) {
                            clientsProcess.running = true
                            activeWindowProcess.running = true
                        }
                    }

                    Connections {
                        target: Hyprland
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
                                var list = []
                                var occ = {}
                                try {
                                    var clients = JSON.parse(this.text)
                                    if (Array.isArray(clients)) {
                                        var ws = root.hyprMonitor && root.hyprMonitor.activeWorkspace
                                        for (var i = 0; i < clients.length; i++) {
                                            var c = clients[i]
                                            var cws = c.workspace
                                            if (cws) {
                                                occ[cws.id] = true
                                                occ[String(cws.name)] = true
                                                if (ws && (cws.id === ws.id || String(cws.name) === String(ws.name)))
                                                    list.push({ address: c.address, title: c.title || "", class: c.class || "" })
                                            }
                                        }
                                    }
                                } catch (_) { }
                                root.clientList = list
                                root.occupiedWorkspaceIds = occ
                                clientsProcess.running = false
                            }
                        }
                    }

                    Component.onCompleted: {
                        if (root.hyprMonitor) {
                            clientsProcess.running = true
                            activeWindowProcess.running = true
                        }
                    }

                    RowLayout {
                        id: barLayout
                        anchors.fill: parent
                        spacing: 0

                        Workspaces {
                            id: workspaceRow
                            colors: shellRoot.shellColors
                            hyprMonitor: root.hyprMonitor
                            occupiedWorkspaceIds: root.occupiedWorkspaceIds
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
                                        screenDelegate.nowPlayingPopupVisible = !screenDelegate.nowPlayingPopupVisible
                                    }
                        }

                        Item {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            Layout.leftMargin: 4
                            Layout.rightMargin: 4
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

                                CpuUsage {
                                    colors: shellRoot.shellColors
                                    Layout.alignment: Qt.AlignVCenter
                                    visible: screenDelegate.cpuWidgetVisible
                                }

                                RamUsage {
                                    colors: shellRoot.shellColors
                                    Layout.alignment: Qt.AlignVCenter
                                    visible: screenDelegate.ramWidgetVisible
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
                                    screenIndex: (function() {
                                        var s = Quickshell.screens
                                        if (!s || !screenDelegate.modelData) return 0
                                        for (var i = 0; i < s.length; i++)
                                            if (s[i] === screenDelegate.modelData) return i
                                        return 0
                                    })()
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
                                    Layout.alignment: Qt.AlignVCenter
                                    visible: screenDelegate.screenshotWidgetVisible
                                    fullscreenOutput: screenDelegate.modelData && screenDelegate.modelData.name ? String(screenDelegate.modelData.name) : ""
                                    Component.onCompleted: screenDelegate.screenshotWidgetRef = screenshotWidget
                                    onMenuToggleRequested: {
                                        screenDelegate.calendarVisible = false
                                        screenDelegate.quickSettingsMenuVisible = false
                                        if (!screenDelegate.screenshotMenuVisible) {
                                            var pt = screenshotWidget.mapToItem(root, 0, 0)
                                            screenDelegate.screenshotMenuMarginLeft = Math.max(0, Math.floor(pt.x + (screenshotWidget.width - 168) / 2))
                                        }
                                        screenDelegate.screenshotMenuVisible = !screenDelegate.screenshotMenuVisible
                                    }
                                }

                                ClockWidget {
                                    id: clockWidget
                                    colors: shellRoot.shellColors
                                    Layout.alignment: Qt.AlignVCenter
                                    Layout.leftMargin: 2
                                    Layout.rightMargin: 2
                                    onCalendarToggleRequested: function() {
                                        screenDelegate.calendarVisible = !screenDelegate.calendarVisible
                                        if (screenDelegate.calendarVisible) {
                                            screenDelegate.nowPlayingPopupVisible = false
                                            screenDelegate.quickSettingsMenuVisible = false
                                            screenDelegate.screenshotMenuVisible = false
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
                                    rootItem: root
                                    Layout.alignment: Qt.AlignVCenter
                                    visible: !screenDelegate.isVerticalScreen
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
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }

            // Quick Settings panel (right-aligned, below bar) — includes Power and Settings as sub-views
            PanelWindow {
                id: quickSettingsPanel
                screen: screenDelegate.modelData
                visible: screenDelegate.quickSettingsMenuVisible && (!bar.hyprMonitor || shellRoot.fullscreenMonitorNames.indexOf(bar.hyprMonitor.name) < 0)
                implicitWidth: 360
                implicitHeight: screenDelegate.quickSettingsSubView === "settings" ? 320 : (screenDelegate.quickSettingsSubView === "power" ? 260 : 560)
                color: "transparent"
                exclusiveZone: 0

                anchors.top: true
                anchors.right: true
                margins.top: 5
                margins.right: 8

                Component.onCompleted: {
                    if (this.WlrLayershell != null) {
                        this.WlrLayershell.layer = WlrLayer.Top
                        this.WlrLayershell.namespace = "quickshell-quick-settings"
                    }
                }

                Rectangle {
                    anchors.fill: parent
                    radius: 12
                    color: shellRoot.shellColors.surfaceContainer
                    border.width: 1
                    border.color: shellRoot.shellColors.border
                    Column {
                        anchors.fill: parent
                        spacing: 0
                        Row {
                            visible: screenDelegate.quickSettingsSubView !== "main"
                            width: parent.width - 32
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
                        Item {
                            width: parent.width - 32
                            height: parent.height - (screenDelegate.quickSettingsSubView !== "main" ? 40 : 0)
                            anchors.horizontalCenter: parent.horizontalCenter
                            QuickSettingsContent {
                                visible: screenDelegate.quickSettingsSubView === "main"
                                anchors.fill: parent
                                anchors.margins: 16
                                colors: shellRoot.shellColors
                                screenIndex: (function() {
                                    var s = Quickshell.screens
                                    if (!s || !screenDelegate.modelData) return 0
                                    for (var i = 0; i < s.length; i++)
                                        if (s[i] === screenDelegate.modelData) return i
                                    return 0
                                })()
                                onClose: function() { screenDelegate.quickSettingsMenuVisible = false }
                                onOpenPowerRequested: screenDelegate.quickSettingsSubView = "power"
                                onOpenSettingsRequested: screenDelegate.quickSettingsSubView = "settings"
                            }
                            Item {
                                visible: screenDelegate.quickSettingsSubView === "power"
                                anchors.fill: parent
                                PowerMenuContent {
                                    anchors.centerIn: parent
                                    width: Math.min(180, parent.width - 24)
                                    colors: shellRoot.shellColors
                                    onClose: function() {
                                        screenDelegate.quickSettingsMenuVisible = false
                                    }
                                }
                            }
                            Item {
                                visible: screenDelegate.quickSettingsSubView === "settings"
                                anchors.fill: parent
                                SettingsMenuContent {
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

            // Screenshot menu panel (below Shot icon, left margin set when opening)
            PanelWindow {
                id: screenshotMenuPanel
                screen: screenDelegate.modelData
                visible: screenDelegate.screenshotMenuVisible && (!bar.hyprMonitor || shellRoot.fullscreenMonitorNames.indexOf(bar.hyprMonitor.name) < 0)
                implicitWidth: 168
                implicitHeight: 100
                color: "transparent"
                exclusiveZone: 0

                anchors.top: true
                anchors.left: true
                margins.top: 5
                margins.left: screenDelegate.screenshotMenuMarginLeft

                Component.onCompleted: {
                    if (this.WlrLayershell != null) {
                        this.WlrLayershell.layer = WlrLayer.Top
                        this.WlrLayershell.namespace = "quickshell-screenshot-menu"
                    }
                }

                Rectangle {
                    anchors.fill: parent
                    radius: 8
                    color: shellRoot.shellColors.surfaceContainer
                    border.width: 1
                    border.color: shellRoot.shellColors.border
                    ScreenshotMenuContent {
                        anchors.fill: parent
                        anchors.margins: 4
                        colors: shellRoot.shellColors
                        screenshotWidget: screenDelegate.screenshotWidgetRef
                        onClose: function() { screenDelegate.screenshotMenuVisible = false }
                    }
                }
            }

            // Calendar as a separate panel (same screen as bar). Position via layer-shell margins:
            // margins.top = bar height + gap; margins.left = clock x (centered under clock).
            // calendarMarginLeft is set when opening from clockWidget.mapToItem(root, 0, 0).
            PanelWindow {
                id: calendarPanel
                screen: screenDelegate.modelData
                visible: screenDelegate.calendarVisible && (!bar.hyprMonitor || shellRoot.fullscreenMonitorNames.indexOf(bar.hyprMonitor.name) < 0)
                implicitWidth: 200
                implicitHeight: 200
                color: shellRoot.shellColors.background
                exclusiveZone: 0

                anchors.top: true
                anchors.left: true
                margins.top: 5
                margins.left: screenDelegate.calendarMarginLeft

                Component.onCompleted: {
                    if (this.WlrLayershell != null) {
                        this.WlrLayershell.layer = WlrLayer.Top
                        this.WlrLayershell.namespace = "quickshell-calendar"
                    }
                }

                Rectangle {
                    anchors.fill: parent
                    color: shellRoot.shellColors.background
                    border.width: 1
                    border.color: shellRoot.shellColors.border
                    radius: 8
                    CalendarContent {
                        anchors.fill: parent
                        anchors.margins: 1
                        colors: shellRoot.shellColors
                        calendarState: screenDelegate
                    }
                }
            }

            // Mini player panel (left-aligned, below bar)
            PanelWindow {
                id: nowPlayingPanel
                screen: screenDelegate.modelData
                visible: screenDelegate.nowPlayingPopupVisible && nowPlayingWidget.hasPlayer && (!bar.hyprMonitor || shellRoot.fullscreenMonitorNames.indexOf(bar.hyprMonitor.name) < 0)
                implicitWidth: 280
                implicitHeight: 140
                color: "transparent"
                exclusiveZone: 0

                anchors.top: true
                anchors.left: true
                margins.top: 5
                margins.left: 8

                Component.onCompleted: {
                    if (this.WlrLayershell != null) {
                        this.WlrLayershell.layer = WlrLayer.Top
                        this.WlrLayershell.namespace = "quickshell-now-playing"
                    }
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
