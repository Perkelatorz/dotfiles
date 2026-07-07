import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Services.Pipewire

import "."

// Transient on-screen display: a small card near the bottom of the screen that
// appears when you change volume, toggle mic mute, or change brightness, then
// fades out. One instance per screen; click-through so it never blocks input.
// Volume/mic are watched live via Pipewire (no keybind changes needed);
// brightness is pulsed from the brightness keys via the `osd` IpcHandler in
// shell.qml (brightnessctl bypasses Quickshell, so it can't be watched).
PanelWindow {
    id: osd
    required property var colors
    required property var screenObj
    // Bumped by the IpcHandler when a brightness key is pressed.
    property int brightnessNonce: 0

    screen: screenObj
    color: "transparent"
    exclusiveZone: 0
    anchors { top: true; bottom: true; left: true; right: true }
    mask: Region {}          // empty input region → fully click-through
    visible: false

    Component.onCompleted: {
        if (this.WlrLayershell != null) {
            this.WlrLayershell.layer = WlrLayer.Overlay
            this.WlrLayershell.keyboardFocus = WlrKeyboardFocus.None
            this.WlrLayershell.namespace = "quickshell-osd"
        }
    }

    // ===== VALUE SOURCES =====
    property var sink: Pipewire.defaultAudioSink
    PwObjectTracker { objects: osd.sink ? [osd.sink] : [] }
    readonly property real sinkVol: sink && sink.audio ? sink.audio.volume : 0
    readonly property bool sinkMuted: sink && sink.audio ? sink.audio.muted : false

    property var source: Pipewire.defaultAudioSource
    PwObjectTracker { objects: osd.source ? [osd.source] : [] }
    readonly property bool srcMuted: source && source.audio ? source.audio.muted : false

    readonly property int brightLevel: SystemServices.brightnessLevel

    // What's on display. The displayed value/icon are computed from this so
    // they stay live while shown (brightness in particular updates when the
    // async refresh lands, instead of showing a stale snapshot).
    property string metricKind: ""
    readonly property int metricValue: metricKind === "brightness" ? brightLevel
        : metricKind === "volume" ? Math.round(Math.min(sinkVol, 1.5) * 100)
        : 0
    readonly property bool metricMuted: metricKind === "volume" ? sinkMuted
        : metricKind === "mic" ? srcMuted
        : false
    readonly property string metricIcon: metricKind === "brightness" ? "\uF185"
        : metricKind === "mic" ? (srcMuted ? "\uF131" : "\uF130")
        : (sinkMuted ? "\uF6A9" : "\uF028")

    // Skip the initial property settle so the OSD doesn't flash on startup.
    property bool ready: false
    Timer { interval: 800; running: true; onTriggered: osd.ready = true }

    function present(kind) {
        osd.metricKind = kind
        osd.visible = true
        card.opacity = 1
        hideTimer.restart()
        unmapTimer.stop()
    }

    onSinkVolChanged: if (ready) present("volume")
    onSinkMutedChanged: if (ready) present("volume")
    onSrcMutedChanged: if (ready) present("mic")
    onBrightnessNonceChanged: if (ready) present("brightness")

    Timer { id: hideTimer; interval: 1600; onTriggered: card.opacity = 0 }
    Timer { id: unmapTimer; interval: 250; onTriggered: osd.visible = false }

    Item {
        id: card
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 120
        width: 260
        height: 60
        opacity: 0
        Behavior on opacity { NumberAnimation { duration: 160; easing.type: Easing.OutCubic } }
        onOpacityChanged: if (opacity === 0) unmapTimer.restart()

        Rectangle {
            anchors.fill: parent
            anchors.topMargin: 3
            anchors.leftMargin: 2
            radius: 16
            color: osd.colors.panelShadow
            z: -1
        }
        Rectangle {
            anchors.fill: parent
            radius: 16
            color: osd.colors.surfaceContainer
            border.width: 1
            border.color: osd.colors.borderSubtle

            Text {
                id: osdIcon
                anchors.left: parent.left
                anchors.leftMargin: 16
                anchors.verticalCenter: parent.verticalCenter
                text: osd.metricIcon
                font.family: osd.colors.widgetIconFont
                font.pixelSize: 22
                color: osd.metricMuted ? osd.colors.error : osd.colors.primary
            }
            Text {
                id: osdVal
                anchors.right: parent.right
                anchors.rightMargin: 16
                anchors.verticalCenter: parent.verticalCenter
                text: osd.metricMuted ? "off" : (osd.metricValue + "%")
                color: osd.colors.textMain
                font.pixelSize: osd.colors.clockFontSize
            }
            Rectangle {
                anchors.left: osdIcon.right
                anchors.leftMargin: 14
                anchors.right: osdVal.left
                anchors.rightMargin: 14
                anchors.verticalCenter: parent.verticalCenter
                height: 8
                radius: 4
                color: osd.colors.surfaceBright
                Rectangle {
                    width: parent.width * Math.max(0, Math.min(1, osd.metricValue / 100))
                    height: parent.height
                    radius: 4
                    color: osd.metricMuted ? osd.colors.error : osd.colors.primary
                    Behavior on width { NumberAnimation { duration: 120 } }
                }
            }
        }
    }
}
