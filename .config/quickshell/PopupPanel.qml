import QtQuick
import Quickshell
import Quickshell.Wayland

// Standard dropdown panel for the bar. Replaces 9 near-identical PanelWindow
// blocks in shell.qml that all share: transparent overlay, esc-to-close,
// click-outside-to-close, slide+fade open animation, WlrLayershell overlay,
// shadow + bordered background. Caller provides positioning, layershell
// namespace, and the inner content.
PanelWindow {
    id: root

    required property var colors
    required property string layershellNamespace
    required property int barHeight

    // Default to right-aligned with 8px margin. PanelWindow's own `width` is set
    // by Wayland once anchored fill — `parent` is not the screen here.
    property int containerX: root.width - root.containerWidth - 8
    property int containerY: root.barHeight + 5
    property int containerWidth: 300
    property int containerHeight: 200
    property bool showBackground: true

    default property alias slot: contentSlot.data

    signal closeRequested()
    signal opened()

    // Material 3 surface tint. A raised surface is not a lighter grey — it is
    // the ground with a percentage of the accent mixed in, which is why M3
    // surfaces read as tinted rather than neutral. This is the single biggest
    // visual difference between this shell and the Material rices it is
    // modelled on; everything else was already close.
    function tint(base, accent, amount) {
        return Qt.rgba(base.r + (accent.r - base.r) * amount,
                       base.g + (accent.g - base.g) * amount,
                       base.b + (accent.b - base.b) * amount,
                       1.0)
    }
    readonly property color surfaceTinted: tint(colors.background, colors.primary, 0.07)

    color: "transparent"
    exclusiveZone: -1
    anchors { top: true; bottom: true; left: true; right: true }
    focusable: true

    onVisibleChanged: {
        if (visible) {
            container.opacity = 0
            container.y = root.containerY - 8
            openAnim.restart()
            escScope.forceActiveFocus()
            root.opened()
        }
    }

    Item { id: escScope; focus: true; Keys.onEscapePressed: root.closeRequested() }

    ParallelAnimation {
        id: openAnim
        NumberAnimation { target: container; property: "opacity"; from: 0; to: 1; duration: 200; easing.type: Easing.OutCubic }
        NumberAnimation { target: container; property: "y"; from: root.containerY - 8; to: root.containerY; duration: 200; easing.type: Easing.OutCubic }
    }

    Component.onCompleted: {
        if (this.WlrLayershell != null) {
            this.WlrLayershell.layer = WlrLayer.Overlay
            this.WlrLayershell.keyboardFocus = WlrKeyboardFocus.Exclusive
            this.WlrLayershell.namespace = root.layershellNamespace
        }
    }

    MouseArea { anchors.fill: parent; onClicked: root.closeRequested() }

    Item {
        id: container
        x: root.containerX
        y: root.containerY
        width: root.containerWidth
        height: root.containerHeight

        // Swallow clicks inside container so they don't reach the close-on-outside MouseArea.
        MouseArea { anchors.fill: parent }

        Rectangle {
            anchors.fill: parent
            anchors.leftMargin: 3
            anchors.topMargin: 6
            z: -1
            radius: 18
            color: root.colors.panelShadow
            // No floating shadow behind transparent-content popups.
            visible: root.showBackground
        }

        // Same ground as the bar: the wallpaper-derived near-black, not
        // surfaceContainer. A panel that drops out of a bar should read as the
        // same surface arriving, and surfaceContainer (#291c22) is two steps
        // lighter than the bar — which is what made the menus look bolted on.
        Rectangle {
            visible: root.showBackground
            anchors.fill: parent
            // 16 — M3's "large" step. 24 (extra-large) read as too bubbly at
            // this panel size; 12 was the flat value this started from.
            radius: 16
            color: Qt.rgba(root.surfaceTinted.r, root.surfaceTinted.g,
                           root.surfaceTinted.b, 0.94)
            border.width: 1
            border.color: Qt.rgba(root.colors.textMain.r, root.colors.textMain.g,
                                  root.colors.textMain.b, 0.10)

            // Lit from above: a one-pixel highlight along the top edge. Cheap,
            // and it is what stops a flat fill from reading as a sticker.
            Rectangle {
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.topMargin: 1
                anchors.leftMargin: 16
                anchors.rightMargin: 16
                height: 1
                color: Qt.rgba(root.colors.textMain.r, root.colors.textMain.g,
                               root.colors.textMain.b, 0.10)
            }
        }

        Item {
            id: contentSlot
            anchors.fill: parent
        }
    }
}
