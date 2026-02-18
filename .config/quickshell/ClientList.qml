import QtQuick
import Quickshell
import Quickshell.Hyprland

import "."

Row {
    id: clientRow
    required property var colors
    required property var clientList
    required property string activeWindowAddress

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
                color: {
                    if (clientMouse.pressed) return isFocusedWindow ? Qt.darker(colors.primary, 1.15) : Qt.darker(colors.surfaceBright, 1.15)
                    if (isFocusedWindow) return colors.primary
                    if (clientMouse.containsMouse) return colors.surfaceBright
                    return colors.surfaceContainer
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
                        color: isFocusedWindow ? colors.textOnPrimary : (clientMouse.containsMouse ? colors.textMain : colors.textDim)
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
                        if (modelData.toplevel) {
                            if (mouse.button === Qt.MiddleButton)
                                modelData.toplevel.close()
                            else
                                modelData.toplevel.activate()
                        } else {
                            if (mouse.button === Qt.MiddleButton)
                                Hyprland.dispatch("closewindow address:" + modelData.address)
                            else
                                Hyprland.dispatch("focuswindow address:" + modelData.address)
                        }
                    }
                }
            }
        }
    }
}
