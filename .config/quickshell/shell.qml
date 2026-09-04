//@ pragma UseQApplication
import QtQuick
import QtQuick.Layouts
import Quickshell
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
        // mango setenv()s XDG_CURRENT_DESKTOP=mango itself during startup.
        if (s.indexOf("mango") >= 0) return "mango"
        return "other"
    }

    // The only compositor this shell speaks to. Everything workspace- and
    // window-related hides on anything else rather than guessing.
    readonly property bool hasWindowIpc: compositorName === "mango"

    // fullscreenMonitorNames is derived straight off MangoIpc's all-clients
    // subscription, so it updates on its own — nothing to poll or poke.
    Connections {
        target: MangoIpc
        enabled: shellRoot.compositorName === "mango"
        function onFullscreenMonitorNamesChanged() {
            shellRoot.fullscreenMonitorNames = MangoIpc.fullscreenMonitorNames
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
            property bool volumePanelVisible: false
            property int volumePanelMarginRight: 0
            property bool systemPanelVisible: false
            property int systemPanelMarginRight: 0
            property bool batteryPanelVisible: false
            property int batteryPanelMarginRight: 0
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
                volumePanelVisible = false
                systemPanelVisible = false
                batteryPanelVisible = false
                tailscalePanelVisible = false
            }
            property int calendarMarginLeft: 0
            property int nowPlayingMarginLeft: 0
            // Widget visibility (toggle from settings menu).
            //
            // Three tiers. ALWAYS: workspaces, focused window, volume, battery,
            // clock, notifications, quick settings, tray — things you act on at
            // a glance. CONDITIONAL: updates, mic, idle inhibitor, battery-low —
            // default true here, but each widget's own `present` keeps it out of
            // the bar until it has something to say. PANEL: performance, net
            // speed, brightness — default false; you go and look at those, and
            // PerformanceContent / QuickSettings already hold them.
            property bool volumeWidgetVisible: true
            property bool nowPlayingWidgetVisible: true
            property bool performanceWidgetVisible: true
            property bool batteryWidgetVisible: true
            property bool brightnessWidgetVisible: false
            property bool microphoneWidgetVisible: true
            property bool ipAddressWidgetVisible: false
            property bool clockWidgetVisible: true
            property bool systemClusterVisible: true
            property bool weatherWidgetVisible: false
            property bool updatesWidgetVisible: true
            property bool netSpeedWidgetVisible: false
            property bool notificationsWidgetVisible: true
            property bool powerProfileWidgetVisible: false
            property bool idleInhibitorWidgetVisible: true
            property bool tailscaleWidgetVisible: true
            // Self-hides on compositors that don't report a layout.
            property bool layoutWidgetVisible: false

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
                    "tailscale=" + (tailscaleWidgetVisible ? "true" : "false"),
                    "layout=" + (layoutWidgetVisible ? "true" : "false")
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
                            if (typeof o.layout === "boolean") screenDelegate.layoutWidgetVisible = o.layout
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
                // mango's own view of this output, from the all-monitors stream.
                property var mangoMonitor: bar.compositorName === "mango" ? MangoIpc.monitorFor(bar.monitorName) : null
                // Output name, however the running compositor names it.
                readonly property string monitorName:
                    bar.modelData && bar.modelData.name ? String(bar.modelData.name) : ""
                readonly property bool panelsVisible: {
                    if (!shellRoot.hasWindowIpc || !bar.monitorName) return true
                    return shellRoot.fullscreenMonitorNames.indexOf(bar.monitorName) < 0
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
                // --- Geometry (BarStyle.geometry) ---
                // edge     flush, square, full width
                // capsule  one inset rounded bar
                // islands  three detached rounded groups
                readonly property string geo: BarStyle.geometry
                // 32 for the full-width bar. The floating geometries need more
                // because their ground is inset from the window on every side;
                // edge spends the whole window on the bar itself.
                readonly property int barThickness: geo === "edge" ? 32 : 40
                // A floating shape needs air above it or its top corners get
                // sliced off by the screen edge. So the gap and the rounding go
                // together: `edge` is the flush, square, no-gap option, and the
                // two floating geometries pay 6px at the top to be fully round.
                readonly property int barTopGap: geo === "edge" ? 0 : 6
                readonly property int barBottomGap: geo === "edge" ? 1 : 6
                readonly property int barSideInset: geo === "edge" ? 0 : 10
                // Padding from the screen edge to the first/last widget.
                readonly property int contentInset: geo === "edge" ? 12 : 4
                readonly property int groundRadius: geo === "edge" ? 0
                    : geo === "capsule" ? 14 : 19

                implicitHeight: barTopGap + barThickness + barBottomGap
                // Reserve the full height explicitly rather than leaving it to
                // the automatic anchor-derived zone — that is what keeps tiled
                // windows below the bar instead of sliding under it.
                exclusiveZone: implicitHeight
                color: "transparent"

                Component.onCompleted: {
                    if (this.WlrLayershell != null) {
                        this.WlrLayershell.layer = WlrLayer.Top
                        this.WlrLayershell.namespace = "quickshell-workspace-bar"
                    }
                }

                // Ground for the two single-piece geometries. Islands paints
                // its own three instead (below), so this is hidden there.
                Rectangle {
                    visible: bar.geo !== "islands"
                    anchors.fill: parent
                    anchors.topMargin: bar.barTopGap
                    anchors.bottomMargin: bar.barBottomGap
                    anchors.leftMargin: bar.barSideInset
                    anchors.rightMargin: bar.barSideInset
                    radius: bar.groundRadius
                    // Wallpaper-derived near-black, held just off opaque so the
                    // background still reads through it.
                    color: Qt.rgba(shellRoot.shellColors.background.r,
                                   shellRoot.shellColors.background.g,
                                   shellRoot.shellColors.background.b, 0.93)
                    border.width: bar.geo === "edge" ? 0 : 1
                    border.color: Qt.rgba(shellRoot.shellColors.textMain.r,
                                          shellRoot.shellColors.textMain.g,
                                          shellRoot.shellColors.textMain.b, 0.07)

                    // Full width has no outline; it gets a hairline along the
                    // one edge that touches the desktop instead.
                    Rectangle {
                        visible: bar.geo === "edge"
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.bottom: parent.bottom
                        height: 1
                        color: Qt.rgba(shellRoot.shellColors.primary.r,
                                       shellRoot.shellColors.primary.g,
                                       shellRoot.shellColors.primary.b, 0.16)
                    }
                }

                Item {
                    id: root
                    anchors.fill: parent
                    property var clientList: []
                    property var occupiedWorkspaceIds: ({})
                    property var clientsByWorkspace: ({})
                    property string activeWindowAddress: ""

                    // The four properties the bar renders from, filled off the
                    // pushed MangoIpc subscriptions rather than a polled process.
                    // Signature of the last workspace-strip model, so an
                    // unchanged rebuild is not reassigned. mango re-pushes the
                    // whole client list on every title change, and an animated
                    // terminal title (a spinner) alone drives ~1.4 pushes/sec:
                    // measured 11 pushes carrying only 2 distinct payloads over
                    // 8s. Reassigning `var` properties on each of those makes
                    // every binding downstream re-evaluate for nothing.
                    property string _wsSig: ""

                    // Title deliberately excluded: the strip keys off `class`,
                    // and including it would defeat the dedupe entirely. The
                    // only consumer of title here is WorkspacePill's letter
                    // fallback for a window with no class, which may therefore
                    // lag one structural change behind. Nothing else reads it.
                    function _wsSignature(occ, by) {
                        var keys = Object.keys(by).sort()
                        var parts = []
                        for (var i = 0; i < keys.length; i++) {
                            var list = by[keys[i]] || []
                            var ids = []
                            for (var j = 0; j < list.length; j++)
                                ids.push(list[j].address + ":" + list[j].class)
                            parts.push(keys[i] + "=" + ids.join(","))
                        }
                        return Object.keys(occ).sort().join(",") + "|" + parts.join(";")
                    }

                    function refreshMangoModel() {
                        if (bar.compositorName !== "mango") return
                        var m = bar.monitorName
                        // ClientList shows titles, so this one always updates.
                        root.clientList = MangoIpc.visibleClientsOn(m)
                        root.activeWindowAddress = MangoIpc.activeClientId(m)

                        var occ = MangoIpc.occupiedTags(m)
                        var by = MangoIpc.clientsByTag(m)
                        var sig = root._wsSignature(occ, by)
                        if (sig === root._wsSig) return
                        root._wsSig = sig
                        root.occupiedWorkspaceIds = occ
                        root.clientsByWorkspace = by
                    }

                    Connections {
                        target: MangoIpc
                        enabled: bar.compositorName === "mango"
                        function onClientsChanged() { root.refreshMangoModel() }
                        function onMonitorsChanged() { root.refreshMangoModel() }
                    }

                    // Safety net. MangoIpc's two SplitParser handlers count and
                    // log a failed JSON.parse, but the update itself is still
                    // lost — one malformed line (a window title containing a
                    // newline splits an object across two) would otherwise leave
                    // the strip stale until the next push happened to arrive.
                    Timer {
                        interval: 10000
                        repeat: true
                        running: bar.compositorName === "mango"
                        onTriggered: root.refreshMangoModel()
                    }

                    Component.onCompleted: root.refreshMangoModel()

                    RowLayout {
                        id: barLayout
                        anchors.fill: parent
                        anchors.topMargin: bar.barTopGap
                        anchors.bottomMargin: bar.barBottomGap
                        anchors.leftMargin: bar.barSideInset + bar.contentInset
                        anchors.rightMargin: bar.barSideInset + bar.contentInset
                        spacing: 0

                        Item {
                            id: leftSection
                            implicitWidth: leftRow.implicitWidth
                            Layout.fillHeight: true
                            Layout.alignment: Qt.AlignVCenter
                            Layout.rightMargin: bar.geo === "islands" ? 14 : 0

                            // Not a layout child: anchoring inside a RowLayout is
                            // undefined behaviour, so the ground and the widget run
                            // both live in this plain Item instead.
                            Island {
                                colors: shellRoot.shellColors
                                enabled: bar.geo === "islands"
                                groundRadius: bar.groundRadius
                                anchors.fill: leftRow
                                anchors.topMargin: -9
                                anchors.bottomMargin: -8
                                anchors.leftMargin: -13
                                anchors.rightMargin: -13
                            }

                            RowLayout {
                                id: leftRow
                                anchors.verticalCenter: parent.verticalCenter
                                anchors.left: parent.left
                                spacing: 0

                                Workspaces {
                                    id: workspaceRow
                                    visible: shellRoot.hasWindowIpc
                                    colors: shellRoot.shellColors
                                    compositorName: bar.compositorName
                                    mangoMonitor: bar.mangoMonitor
                                    occupiedWorkspaceIds: root.occupiedWorkspaceIds
                                    clientsByWorkspace: root.clientsByWorkspace
                                    Layout.leftMargin: 0
                                }
                                LayoutWidget {
                                    colors: shellRoot.shellColors
                                    compositorName: bar.compositorName
                                    mangoMonitor: bar.mangoMonitor
                                    visible: screenDelegate.layoutWidgetVisible
                                    Layout.alignment: Qt.AlignVCenter
                                }
                                NowPlayingWidget {
                                    id: nowPlayingWidget
                                    colors: shellRoot.shellColors
                                    Layout.alignment: Qt.AlignVCenter
                                    visible: screenDelegate.nowPlayingWidgetVisible
                                    onOpenMiniPlayerRequested: {
                                        var wasOpen = screenDelegate.nowPlayingPopupVisible
                                        screenDelegate.closeAllPanels()
                                        var pt = nowPlayingWidget.mapToItem(root, 0, 0)
                                        screenDelegate.nowPlayingMarginLeft = Math.max(8, Math.floor(pt.x))
                                        screenDelegate.nowPlayingPopupVisible = !wasOpen
                                    }
                                }
                            }
                        }

                        Item {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            visible: shellRoot.hasWindowIpc
                            Island {
                                colors: shellRoot.shellColors
                                enabled: bar.geo === "islands" && clientList.width > 0
                                groundRadius: bar.groundRadius
                                anchors.fill: clientList
                                anchors.topMargin: -9
                                anchors.bottomMargin: -8
                                anchors.leftMargin: -16
                                anchors.rightMargin: -16
                            }
                            ClientList {
                                id: clientList
                                anchors.centerIn: parent
                                colors: shellRoot.shellColors
                                compositorName: bar.compositorName
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

                            Island {
                                colors: shellRoot.shellColors
                                enabled: bar.geo === "islands"
                                groundRadius: bar.groundRadius
                                anchors.fill: rightSectionLayout
                                anchors.topMargin: -9
                                anchors.bottomMargin: -8
                                anchors.leftMargin: -10
                                anchors.rightMargin: -10
                            }
                            RowLayout {
                                id: rightSectionLayout
                                anchors.right: parent.right
                                anchors.verticalCenter: parent.verticalCenter
                                // Blocks style abuts widgets into one segmented
                                // strip; every other style keeps breathing room.
                                spacing: 0
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
                                                                    onPanelToggleRequested: function() {
                                        var wasOpen = screenDelegate.batteryPanelVisible
                                        screenDelegate.closeAllPanels()
                                        screenDelegate.batteryPanelVisible = !wasOpen
                                        if (screenDelegate.batteryPanelVisible) {
                                            var pt = batteryWidget.mapToItem(root, 0, 0)
                                            screenDelegate.batteryPanelMarginRight = Math.max(0,
                                                Math.floor(bar.width - pt.x - batteryWidget.width / 2 - 150))
                                        }
                                    }
                                }

                                BrightnessWidget {
                                    colors: shellRoot.shellColors
                                    Layout.alignment: Qt.AlignVCenter
                                    visible: screenDelegate.brightnessWidgetVisible
                                    outputName: bar.monitorName
                                    screenIndex: bar.screenIndex
                                }

                                VolumeWidget {
                                    id: volumeWidget
                                    colors: shellRoot.shellColors
                                    Layout.alignment: Qt.AlignVCenter
                                    visible: screenDelegate.volumeWidgetVisible
                                                                    onVolumePanelToggleRequested: function() {
                                        var wasOpen = screenDelegate.volumePanelVisible
                                        screenDelegate.closeAllPanels()
                                        screenDelegate.volumePanelVisible = !wasOpen
                                        if (screenDelegate.volumePanelVisible) {
                                            var pt = volumeWidget.mapToItem(root, 0, 0)
                                            var screenW = bar.width
                                            screenDelegate.volumePanelMarginRight = Math.max(0,
                                                Math.floor(screenW - pt.x - volumeWidget.width / 2 - 160))
                                        }
                                    }
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

                                SystemClusterWidget {
                                    id: systemCluster
                                    colors: shellRoot.shellColors
                                    visible: screenDelegate.systemClusterVisible
                                    Layout.alignment: Qt.AlignVCenter
                                    onPanelToggleRequested: function() {
                                        var wasOpen = screenDelegate.systemPanelVisible
                                        screenDelegate.closeAllPanels()
                                        screenDelegate.systemPanelVisible = !wasOpen
                                        if (screenDelegate.systemPanelVisible) {
                                            var pt = systemCluster.mapToItem(root, 0, 0)
                                            screenDelegate.systemPanelMarginRight = Math.max(0,
                                                Math.floor(bar.width - pt.x - systemCluster.width / 2 - 160))
                                        }
                                    }
                                }
                                BarSeparator { colors: shellRoot.shellColors }
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

                                BarSeparator { colors: shellRoot.shellColors }
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
                id: batteryPanel
                screen: screenDelegate.modelData
                visible: screenDelegate.batteryPanelVisible && bar.panelsVisible
                colors: shellRoot.shellColors
                layershellNamespace: "quickshell-battery"
                barHeight: bar.implicitHeight
                containerX: batteryPanel.width - 300 - screenDelegate.batteryPanelMarginRight
                containerWidth: 300
                containerHeight: batteryContentItem.implicitHeight
                onCloseRequested: screenDelegate.closeAllPanels()

                BatteryContent {
                    id: batteryContentItem
                    colors: shellRoot.shellColors
                    panelOpen: batteryPanel.visible
                    onClose: function() { screenDelegate.batteryPanelVisible = false }
                }
            }

            PopupPanel {
                id: systemPanel
                screen: screenDelegate.modelData
                visible: screenDelegate.systemPanelVisible && bar.panelsVisible
                colors: shellRoot.shellColors
                layershellNamespace: "quickshell-system"
                barHeight: bar.implicitHeight
                containerX: systemPanel.width - 320 - screenDelegate.systemPanelMarginRight
                containerWidth: 320
                containerHeight: systemContentItem.implicitHeight
                onCloseRequested: screenDelegate.closeAllPanels()

                SystemContent {
                    id: systemContentItem
                    colors: shellRoot.shellColors
                    panelOpen: systemPanel.visible
                    onClose: function() { screenDelegate.systemPanelVisible = false }
                }
            }

            PopupPanel {
                id: volumePanel
                screen: screenDelegate.modelData
                visible: screenDelegate.volumePanelVisible && bar.panelsVisible
                colors: shellRoot.shellColors
                layershellNamespace: "quickshell-volume"
                barHeight: bar.implicitHeight
                containerX: volumePanel.width - 320 - screenDelegate.volumePanelMarginRight
                containerWidth: 320
                containerHeight: volumeContentItem.implicitHeight
                onCloseRequested: screenDelegate.closeAllPanels()

                VolumeContent {
                    id: volumeContentItem
                    colors: shellRoot.shellColors
                    panelOpen: volumePanel.visible
                    onClose: function() { screenDelegate.volumePanelVisible = false }
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
