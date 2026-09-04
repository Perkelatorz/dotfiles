import QtQuick
import Quickshell

import "."

// Window strip. `clientList` entries are already compositor-neutral
// ({address, title, class}); only focus/close routing differs, so that switches
// on compositorName rather than duplicating the delegate.
Row {
    id: clientRow
    required property var colors
    required property var clientList
    required property string activeWindowAddress
    property string compositorName: "mango"

    spacing: 4
    anchors.verticalCenter: parent.verticalCenter
    height: 20

    Repeater {
        model: clientList
        delegate: Item {
            readonly property string iconName: modelData.class ? String(modelData.class).toLowerCase() : ""
            readonly property string iconSource: iconName ? Quickshell.iconPath(iconName, true) : ""
            readonly property bool isFocusedWindow: modelData.address && String(modelData.address) === clientRow.activeWindowAddress

            width: Math.max(72, Math.min(clientContentRow.implicitWidth + 16, 200))
            height: 20

            Rectangle {
                anchors.fill: parent
                radius: 6
                // Accent rule: the focused window gets a faint wash of the
                // accent, never a solid slab of it. A solid primary fill behind
                // a title is the single loudest thing the bar used to draw.
                color: {
                    var a = colors.primary
                    if (clientMouse.pressed)
                        return Qt.rgba(a.r, a.g, a.b, isFocusedWindow ? 0.26 : 0.12)
                    if (isFocusedWindow) return Qt.rgba(a.r, a.g, a.b, 0.16)
                    if (clientMouse.containsMouse)
                        return Qt.rgba(colors.textMain.r, colors.textMain.g, colors.textMain.b, 0.07)
                    return "transparent"
                }
                scale: clientMouse.pressed ? 0.94 : 1.0
                Behavior on color { ColorAnimation { duration: 100 } }
                Behavior on scale { NumberAnimation { duration: 80; easing.type: Easing.OutCubic } }

                Row {
                    id: clientContentRow
                    anchors.centerIn: parent
                    spacing: 6
                    leftPadding: 6
                    rightPadding: 6

                    Image {
                        width: 14
                        height: 14
                        anchors.verticalCenter: parent.verticalCenter
                        source: iconSource
                        sourceSize.width: 14
                        sourceSize.height: 14
                        visible: iconSource !== ""
                        smooth: true
                        mipmap: true
                    }

                    Text {
                        width: Math.min(implicitWidth, 160)
                        anchors.verticalCenter: parent.verticalCenter
                        elide: Text.ElideMiddle
                        text: modelData.title || modelData.class || "?"
                        color: isFocusedWindow ? colors.primary : (clientMouse.containsMouse ? colors.textMain : colors.textDim)
                        font.pixelSize: 11
                    }
                }

                MouseArea {
                    id: clientMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    acceptedButtons: Qt.LeftButton | Qt.MiddleButton
                    onClicked: function(mouse) {
                        var close = mouse.button === Qt.MiddleButton
                        if (modelData.toplevel) {
                            if (close) modelData.toplevel.close()
                            else modelData.toplevel.activate()
                        } else if (clientRow.compositorName === "mango") {
                            // `address` carries the mango client id here; both
                            // dispatchers take it as a `client,<id>` target.
                            MangoIpc.dispatch(close ? "killclient" : "focusid",
                                              "client," + modelData.address)
                        }
                    }
                }
            }
        }
    }
}
