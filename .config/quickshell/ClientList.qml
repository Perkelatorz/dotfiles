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
    anchors.verticalCenter: parent ? parent.verticalCenter : undefined
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
                    if (isFocusedWindow) return colors.primary
                    if (clientMouse.containsMouse) return colors.surfaceBright
                    return colors.surfaceContainer
                }
                Behavior on color { ColorAnimation { duration: 100 } }

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
                    acceptedButtons: Qt.LeftButton | Qt.MiddleButton
                    onClicked: function(mouse) {
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
