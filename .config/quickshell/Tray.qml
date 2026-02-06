import QtQuick
import Quickshell
import Quickshell.Services.SystemTray

import "."

Row {
    id: trayRow
    required property var colors
    required property var barWindow
    required property var rootItem

    spacing: 2
    height: parent ? parent.height : 28

    Repeater {
        model: SystemTray.items
        delegate: Item {
            id: trayIconDelegate
            width: colors.trayIconSize + 4
            height: colors.trayIconSize + 4

            Image {
                anchors.centerIn: parent
                width: colors.trayIconSize
                height: colors.trayIconSize
                source: modelData.icon
                sourceSize.width: colors.trayIconSize
                sourceSize.height: colors.trayIconSize
                smooth: true
                mipmap: true
            }

            QsMenuAnchor {
                id: menuAnchor
                menu: modelData.menu
                anchor.window: barWindow
                anchor.edges: Edges.Bottom | Edges.Left
                anchor.gravity: Edges.Bottom | Edges.Right
            }

            Connections {
                target: menuAnchor.anchor
                function onAnchoring() {
                    var r = barWindow.mapFromItem(trayIconDelegate, 0, 0, trayIconDelegate.width, trayIconDelegate.height)
                    // Anchor at bottom edge of icon so menu opens below the bar
                    menuAnchor.anchor.rect = Qt.rect(r.x, r.y + r.height, r.width, 1)
                    menuAnchor.anchor.margins.top = 2
                }
            }

            MouseArea {
                anchors.fill: parent
                acceptedButtons: Qt.LeftButton | Qt.RightButton
                onClicked: function(mouse) {
                    var showMenu = modelData.hasMenu && (mouse.button === Qt.RightButton || modelData.onlyMenu)
                    if (showMenu) {
                        if (modelData.menu) {
                            menuAnchor.open()
                        } else {
                            var pt = barWindow.mapFromItem(trayIconDelegate, trayIconDelegate.width / 2, trayIconDelegate.height + 2)
                            modelData.display(barWindow, Math.round(pt.x), Math.round(pt.y))
                        }
                    } else {
                        modelData.activate()
                    }
                }
                onWheel: function(wheel) {
                    modelData.scroll(wheel.angleDelta.y, false)
                }
            }
        }
    }
}
