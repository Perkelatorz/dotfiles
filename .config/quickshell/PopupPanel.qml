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
            anchors.leftMargin: 2
            anchors.topMargin: 4
            z: -1
            radius: 20
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
            // 20, not 12. The rounder, softer shape is most of what separates
            // the reference rices from "clean but plain"; caelestia's default is
            // 25, which is too much at this panel size.
            radius: 20
            color: Qt.rgba(root.colors.background.r, root.colors.background.g,
                           root.colors.background.b, 0.93)
            border.width: 1
            border.color: Qt.rgba(root.colors.textMain.r, root.colors.textMain.g,
                                  root.colors.textMain.b, 0.10)
        }

        Item {
            id: contentSlot
            anchors.fill: parent
        }
    }
}
