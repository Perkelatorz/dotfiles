import QtQuick
import Quickshell.Services.Notifications

import "."

// The history behind the bar's bell. Everything that arrived, whether or not
// you caught the toast.
Item {
    id: center
    required property var colors
    property var onClose: null
    property bool panelOpen: false

    implicitWidth: 380
    implicitHeight: 420

    readonly property var items: NotificationService.history
        ? NotificationService.history.values : []

    Column {
        anchors.fill: parent
        anchors.margins: 14
        spacing: 10

        Item {
            width: parent.width
            height: 22
            Text {
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                text: "NOTIFICATIONS"
                color: center.colors.textDim
                font.pixelSize: 11
                font.bold: true
            }
            Row {
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                spacing: 8
                Text {
                    text: NotificationService.dnd ? "DND on" : "DND off"
                    color: NotificationService.dnd ? center.colors.primary : center.colors.textDim
                    font.pixelSize: 11
                    MouseArea {
                        anchors.fill: parent
                        anchors.margins: -5
                        cursorShape: Qt.PointingHandCursor
                        onClicked: NotificationService.toggleDnd()
                    }
                }
                Text {
                    visible: center.items.length > 0
                    text: "Clear"
                    color: clearMa.containsMouse ? center.colors.primary : center.colors.textDim
                    font.pixelSize: 11
                    MouseArea {
                        id: clearMa
                        anchors.fill: parent
                        anchors.margins: -5
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: NotificationService.clearHistory()
                    }
                }
            }
        }

        Text {
            visible: center.items.length === 0
            width: parent.width
            text: "Nothing here"
            color: center.colors.textMuted
            font.pixelSize: 12
            horizontalAlignment: Text.AlignHCenter
            topPadding: 40
        }

        ListView {
            width: parent.width
            height: parent.height - 32
            clip: true
            spacing: 6
            // Newest first: a history you read top-down should start with what
            // just happened.
            model: center.items.slice().reverse()

            delegate: Rectangle {
                required property var modelData
                readonly property bool critical:
                    modelData && modelData.urgency === NotificationUrgency.Critical
                width: ListView.view.width
                implicitHeight: Math.max(48, col.implicitHeight + 20)
                radius: 12
                color: rowMa.containsMouse
                    ? center.colors.surfaceBright
                    : center.colors.surfaceContainer
                border.width: 1
                border.color: critical
                    ? Qt.rgba(center.colors.urgent.r, center.colors.urgent.g,
                              center.colors.urgent.b, 0.45)
                    : Qt.rgba(center.colors.textMain.r, center.colors.textMain.g,
                              center.colors.textMain.b, 0.08)
                Behavior on color { ColorAnimation { duration: 110 } }

                Column {
                    id: col
                    x: 12
                    y: 10
                    width: parent.width - 42
                    spacing: 3
                    Text {
                        width: parent.width
                        text: modelData ? modelData.appName : ""
                        color: parent.parent.critical ? center.colors.urgent : center.colors.primary
                        font.pixelSize: 10
                        font.bold: true
                        elide: Text.ElideRight
                    }
                    Text {
                        width: parent.width
                        text: modelData ? modelData.summary : ""
                        color: center.colors.textMain
                        font.pixelSize: 12
                        elide: Text.ElideRight
                    }
                    Text {
                        width: parent.width
                        visible: modelData && modelData.body !== ""
                        text: modelData ? modelData.body : ""
                        color: center.colors.textDim
                        font.pixelSize: 11
                        wrapMode: Text.Wrap
                        maximumLineCount: 2
                        elide: Text.ElideRight
                        textFormat: Text.StyledText
                    }
                }

                Text {
                    text: "×"
                    anchors.right: parent.right
                    anchors.rightMargin: 11
                    anchors.top: parent.top
                    anchors.topMargin: 7
                    color: center.colors.textDim
                    font.pixelSize: 14
                    MouseArea {
                        anchors.fill: parent
                        anchors.margins: -6
                        cursorShape: Qt.PointingHandCursor
                        onClicked: if (modelData) modelData.dismiss()
                    }
                }

                MouseArea {
                    id: rowMa
                    anchors.fill: parent
                    anchors.rightMargin: 30
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        if (modelData && modelData.actions && modelData.actions.length > 0)
                            modelData.actions[0].invoke()
                    }
                }
            }
        }
    }
}
