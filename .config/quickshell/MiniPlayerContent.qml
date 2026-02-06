import QtQuick

import "."

Item {
    id: miniPlayerContent
    required property var colors
    required property var player
    required property var onClose
    property bool isOpen: false

    onIsOpenChanged: {
        if (isOpen) {
            sourceDropdownOpen = false
            if (player && typeof player.refreshList === "function") player.refreshList()
        }
    }

    implicitWidth: 280
    implicitHeight: 140

    function friendlyName(pid) {
        if (!pid) return "—"
        var first = String(pid).split(".")[0]
        return first.charAt(0).toUpperCase() + first.slice(1).toLowerCase()
    }

    property bool sourceDropdownOpen: false

    Rectangle {
        anchors.fill: parent
        radius: 8
        color: colors.surfaceContainer
        border.width: 1
        border.color: colors.border

        Row {
            id: mainRow
            anchors.fill: parent
            anchors.margins: 8
            anchors.topMargin: 8
            anchors.bottomMargin: 8
            spacing: 10

            // Album art
            Rectangle {
                width: 96
                height: 96
                radius: 6
                color: colors.surface
                border.width: 1
                border.color: colors.borderSubtle
                anchors.verticalCenter: parent.verticalCenter

                Image {
                    anchors.fill: parent
                    anchors.margins: 2
                    source: miniPlayerContent.player && miniPlayerContent.player.artUrl ? miniPlayerContent.player.artUrl : ""
                    sourceSize.width: 92
                    sourceSize.height: 92
                    fillMode: Image.PreserveAspectCrop
                    smooth: true
                    visible: !!source
                }
                Text {
                    anchors.centerIn: parent
                    text: "\uF001"
                    color: colors.textMuted
                    font.pixelSize: 32
                    font.family: colors.widgetIconFont
                    visible: !(miniPlayerContent.player && miniPlayerContent.player.artUrl)
                }
            }

            Item {
                id: rightColumn
                width: parent.width - 96 - mainRow.spacing
                height: parent.height - 16

                Column {
                    id: contentColumn
                    width: parent.width
                    spacing: 4
                    anchors.verticalCenter: parent.verticalCenter

                    // Source dropdown trigger
                    Item {
                        id: sourceTriggerItem
                        width: parent.width - 4
                        height: 22
                        MouseArea {
                            id: sourceTrigger
                            anchors.fill: parent
                            hoverEnabled: true
                            onClicked: miniPlayerContent.sourceDropdownOpen = !miniPlayerContent.sourceDropdownOpen
                            Rectangle {
                                anchors.fill: parent
                                radius: 4
                                color: sourceTrigger.containsMouse ? colors.surfaceBright : "transparent"
                                border.width: 1
                                border.color: miniPlayerContent.sourceDropdownOpen ? colors.primary : "transparent"
                                Row {
                                    anchors.left: parent.left
                                    anchors.verticalCenter: parent.verticalCenter
                                    spacing: 4
                                    leftPadding: 4
                                    Text {
                                        text: miniPlayerContent.player ? miniPlayerContent.friendlyName(miniPlayerContent.player.selectedPlayer) : "—"
                                        color: colors.textDim
                                        font.pixelSize: colors.clockFontSize - 1
                                    }
                                    Text {
                                        text: miniPlayerContent.sourceDropdownOpen ? "\uF0D8" : "\uF0D7"
                                        color: colors.textDim
                                        font.pixelSize: 10
                                        font.family: colors.widgetIconFont
                                    }
                                }
                            }
                        }
                    }

                    Text {
                        width: parent.width - 4
                        elide: Text.ElideRight
                        text: miniPlayerContent.player ? miniPlayerContent.player.title || "—" : "—"
                        color: colors.textMain
                        font.pixelSize: colors.clockFontSize + 1
                        font.bold: true
                    }
                    Text {
                        width: parent.width - 4
                        elide: Text.ElideRight
                        text: miniPlayerContent.player ? (miniPlayerContent.player.artist || "—") : "—"
                        color: colors.textDim
                        font.pixelSize: colors.clockFontSize - 1
                    }

                    Row {
                    spacing: 8
                    layoutDirection: Qt.LeftToRight

                    MouseArea {
                        id: prevBtn
                        width: 32
                        height: 28
                        hoverEnabled: true
                        onClicked: if (miniPlayerContent.player) miniPlayerContent.player.previous()
                        Rectangle {
                            anchors.fill: parent
                            radius: 4
                            color: prevBtn.containsMouse ? colors.surfaceBright : "transparent"
                            Text {
                                anchors.centerIn: parent
                                text: "\uF049"
                                color: colors.textMain
                                font.pixelSize: 14
                                font.family: colors.widgetIconFont
                            }
                        }
                    }
                    Item { width: 1; height: 1 }
                    MouseArea {
                        id: playBtn
                        width: 32
                        height: 28
                        hoverEnabled: true
                        onClicked: if (miniPlayerContent.player) miniPlayerContent.player.playPause()
                        Rectangle {
                            anchors.fill: parent
                            radius: 4
                            color: playBtn.containsMouse ? colors.surfaceBright : "transparent"
                            Text {
                                anchors.centerIn: parent
                                text: (miniPlayerContent.player && miniPlayerContent.player.status === "Playing") ? "\uF04C" : "\uF04B"
                                color: colors.textMain
                                font.pixelSize: 14
                                font.family: colors.widgetIconFont
                            }
                        }
                    }
                    Item { width: 1; height: 1 }
                    MouseArea {
                        id: nextBtn
                        width: 32
                        height: 28
                        hoverEnabled: true
                        onClicked: if (miniPlayerContent.player) miniPlayerContent.player.next()
                        Rectangle {
                            anchors.fill: parent
                            radius: 4
                            color: nextBtn.containsMouse ? colors.surfaceBright : "transparent"
                            Text {
                                anchors.centerIn: parent
                                text: "\uF050"
                                color: colors.textMain
                                font.pixelSize: 14
                                font.family: colors.widgetIconFont
                            }
                        }
                    }
                    }
                }
            }
        }

        // Dropdown overlay (sibling of Row so it can sit on top with fixed position)
        Rectangle {
            id: dropdownOverlay
            x: 8 + 96 + mainRow.spacing + 4
            y: 8 + (rightColumn.height - contentColumn.height) / 2 + 22 + 4
            width: rightColumn.width - 8
            height: Math.min((miniPlayerContent.player ? miniPlayerContent.player.playerList.length : 0), 4) * 22
            radius: 4
            color: colors.surface
            border.width: 1
            border.color: colors.borderSubtle
            visible: miniPlayerContent.sourceDropdownOpen && miniPlayerContent.player && miniPlayerContent.player.playerList && miniPlayerContent.player.playerList.length > 0
            z: 100
                Column {
                    width: parent.width
                    Repeater {
                        model: miniPlayerContent.player && miniPlayerContent.player.playerList ? miniPlayerContent.player.playerList : []
                        delegate: MouseArea {
                            id: playerItem
                            width: dropdownOverlay.width - 4
                            height: 22
                            hoverEnabled: true
                            onClicked: {
                                if (miniPlayerContent.player)
                                    miniPlayerContent.player.setSelectedPlayer(modelData)
                                miniPlayerContent.sourceDropdownOpen = false
                            }
                            Rectangle {
                                anchors.fill: parent
                                anchors.margins: 2
                                radius: 3
                                color: playerItem.containsMouse ? colors.surfaceBright : "transparent"
                                Text {
                                    anchors.left: parent.left
                                    anchors.verticalCenter: parent.verticalCenter
                                    leftPadding: 6
                                    text: miniPlayerContent.friendlyName(modelData)
                                    color: (miniPlayerContent.player && miniPlayerContent.player.selectedPlayer === modelData) ? colors.primary : colors.textMain
                                    font.pixelSize: colors.clockFontSize - 1
                                }
                            }
                        }
                    }
                }
            }

        // Close button
        MouseArea {
            id: closeMouse
            width: 24
            height: 24
            anchors.top: parent.top
            anchors.right: parent.right
            anchors.margins: 4
            hoverEnabled: true
            onClicked: miniPlayerContent.onClose()
            Rectangle {
                anchors.fill: parent
                radius: 4
                color: closeMouse.containsMouse ? colors.surfaceBright : "transparent"
                Text {
                    anchors.centerIn: parent
                    text: "\uF00D"
                    color: colors.textDim
                    font.pixelSize: 12
                    font.family: colors.widgetIconFont
                }
            }
        }
    }
}