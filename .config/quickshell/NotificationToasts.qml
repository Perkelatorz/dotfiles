import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Services.Notifications

import "."

// Toast stack, top-right under the bar. Its own layer-shell window so it can
// float over everything without the bar reserving space for it.
PanelWindow {
    id: toastWin
    required property var colors
    required property int barHeight

    readonly property var items: NotificationService.toasts

    visible: items.length > 0
    color: "transparent"
    // Never steal the pointer: exclusiveZone -1 and a window sized to the stack
    // means clicks land on whatever is underneath everywhere else.
    exclusiveZone: -1
    anchors { top: true; right: true }
    implicitWidth: 380
    implicitHeight: Math.max(1, stack.implicitHeight + 16)

    Component.onCompleted: {
        if (this.WlrLayershell != null) {
            this.WlrLayershell.layer = WlrLayer.Overlay
            this.WlrLayershell.namespace = "quickshell-notifications"
        }
    }

    Column {
        id: stack
        x: 8
        y: toastWin.barHeight + 6
        width: parent.width - 16
        spacing: 8

        Repeater {
            model: toastWin.items
            delegate: Rectangle {
                id: toast
                required property var modelData
                readonly property var n: modelData.n
                readonly property bool critical:
                    n && n.urgency === NotificationUrgency.Critical

                width: stack.width
                implicitHeight: Math.max(56, body.implicitHeight + 26)
                radius: 16
                // surfaceContainer, the same card tone the panels use — a toast
                // is a card, so it reads as part of the shell rather than as
                // something a separate daemon threw on screen.
                color: toastWin.colors.surfaceContainer
                border.width: 1
                border.color: critical
                    ? Qt.rgba(toastWin.colors.urgent.r, toastWin.colors.urgent.g,
                              toastWin.colors.urgent.b, 0.55)
                    : Qt.rgba(toastWin.colors.textMain.r, toastWin.colors.textMain.g,
                              toastWin.colors.textMain.b, 0.10)

                opacity: 0
                Component.onCompleted: opacity = 1
                Behavior on opacity { NumberAnimation { duration: 160; easing.type: Easing.OutCubic } }

                // Urgency rail — a critical notification should be identifiable
                // before you have read a word of it.
                Rectangle {
                    visible: toast.critical
                    x: 0
                    width: 3
                    height: parent.height - 20
                    y: 10
                    radius: 2
                    color: toastWin.colors.urgent
                }

                Image {
                    id: img
                    visible: toast.n && toast.n.image !== ""
                    source: toast.n ? toast.n.image : ""
                    x: 14
                    y: 14
                    width: visible ? 28 : 0
                    height: 28
                    sourceSize.width: 28
                    sourceSize.height: 28
                    smooth: true
                }

                Column {
                    id: body
                    x: img.visible ? 52 : 14
                    y: 13
                    width: parent.width - x - 40
                    spacing: 3

                    Text {
                        width: parent.width
                        text: toast.n ? toast.n.appName : ""
                        color: toast.critical ? toastWin.colors.urgent : toastWin.colors.primary
                        font.pixelSize: 10
                        font.bold: true
                        elide: Text.ElideRight
                    }
                    Text {
                        width: parent.width
                        text: toast.n ? toast.n.summary : ""
                        color: toastWin.colors.textMain
                        font.pixelSize: 12
                        font.bold: true
                        elide: Text.ElideRight
                    }
                    Text {
                        width: parent.width
                        visible: toast.n && toast.n.body !== ""
                        text: toast.n ? toast.n.body : ""
                        color: toastWin.colors.textDim
                        font.pixelSize: 11
                        wrapMode: Text.Wrap
                        maximumLineCount: 3
                        elide: Text.ElideRight
                        textFormat: Text.StyledText
                    }
                }

                Text {
                    text: "×"
                    anchors.right: parent.right
                    anchors.rightMargin: 13
                    anchors.top: parent.top
                    anchors.topMargin: 9
                    color: closeMa.containsMouse ? toastWin.colors.textMain : toastWin.colors.textDim
                    font.pixelSize: 15
                    MouseArea {
                        id: closeMa
                        anchors.fill: parent
                        anchors.margins: -7
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: NotificationService.close(toast.n)
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    anchors.rightMargin: 34
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        // Default action if the sender offered one, else just
                        // put it away — it stays in the history either way.
                        if (toast.n && toast.n.actions && toast.n.actions.length > 0)
                            toast.n.actions[0].invoke()
                        NotificationService.dismissToast(toast.n)
                    }
                }
            }
        }
    }
}
