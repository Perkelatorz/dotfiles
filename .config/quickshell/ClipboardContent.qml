import QtQuick
import QtQuick.Layouts
import Quickshell.Io

import "."

ColumnLayout {
    id: clipRoot
    required property var colors
    required property var onClose

    property string activeTab: "text"
    property var textEntries: []
    property var imageEntries: []
    property string searchText: ""
    property int previewIndex: -1

    readonly property int _headerHeight: 117
    readonly property int _textListHeight: Math.max(3, Math.min(textEntries.length, 15)) * 34
    readonly property int _imageListHeight: Math.max(200, Math.min(imageEntries.length, 8) * 50)
    property int desiredHeight: _headerHeight + (activeTab === "text" ? _textListHeight : _imageListHeight)

    spacing: 8

    Process {
        id: listProc
        command: ["cliphist", "list"]
        running: false
        stdout: StdioCollector {
            onStreamFinished: {
                var raw = (listProc.stdout.text || "")
                var lines = raw.split("\n")
                var texts = []
                var images = []
                for (var i = 0; i < lines.length; i++) {
                    var line = lines[i].trim()
                    if (!line) continue
                    var isBinary = line.indexOf("binary") >= 0 || (line.indexOf("[[") >= 0 && line.indexOf("]]") >= 0)
                    if (isBinary) {
                        images.push(line)
                    } else {
                        texts.push(line)
                    }
                }
                clipRoot.textEntries = texts
                clipRoot.imageEntries = images
                clipRoot.previewIndex = images.length > 0 ? 0 : -1
                listProc.running = false
                if (images.length > 0) thumbProc.running = true
            }
        }
    }

    Process {
        id: thumbProc
        command: ["sh", "-c", "mkdir -p \"${XDG_RUNTIME_DIR:-/tmp}/cliphist-thumbs\" && i=0; echo \"" + clipRoot.imageEntries.join("\n") + "\" | while IFS= read -r line; do [ -z \"$line\" ] && continue; echo \"$line\" | cliphist decode > \"${XDG_RUNTIME_DIR:-/tmp}/cliphist-thumbs/qml_$i.png\" 2>/dev/null; i=$((i+1)); done; echo done"]
        running: false
        stdout: StdioCollector {
            onStreamFinished: {
                thumbProc.running = false
                clipRoot.imageEntriesChanged()
            }
        }
    }

    Process {
        id: pasteProc
        command: ["sh", "-c", "echo '' | cliphist decode | wl-copy"]
        running: false
        stdout: StdioCollector { onStreamFinished: pasteProc.running = false }
    }

    function refresh() {
        clipRoot.previewIndex = -1
        listProc.running = true
    }

    function pasteEntry(entry) {
        pasteProc.command = ["sh", "-c", "echo " + JSON.stringify(entry) + " | cliphist decode | wl-copy"]
        pasteProc.running = true
    }

    function thumbPath(idx) {
        return "file:///run/user/" + Qt.application.pid.toString().replace(/.*/, "") + "/../cliphist-thumbs/qml_" + idx + ".png"
    }

    function runtimeThumbPath(idx) {
        return "file://" + "/tmp/cliphist-thumbs/qml_" + idx + ".png"
    }

    Process {
        id: runtimeDirProc
        command: ["sh", "-c", "echo \"${XDG_RUNTIME_DIR:-/tmp}\""]
        running: true
        property string dir: "/tmp"
        stdout: StdioCollector {
            onStreamFinished: {
                runtimeDirProc.dir = (runtimeDirProc.stdout.text || "/tmp").trim()
                runtimeDirProc.running = false
            }
        }
    }

    Process {
        id: clearProc
        command: ["cliphist", "wipe"]
        running: false
        stdout: StdioCollector {
            onStreamFinished: {
                clearProc.running = false
                clipRoot.textEntries = []
                clipRoot.imageEntries = []
                clipRoot.previewIndex = -1
            }
        }
    }

    Component.onCompleted: refresh()

    RowLayout {
        Layout.fillWidth: true
        spacing: 8

        Text {
            text: "Clipboard"
            color: colors.textMain
            font.pixelSize: 14
            font.bold: true
        }
        Item { Layout.fillWidth: true }

        MouseArea {
            id: clearMa
            width: clearLabel.implicitWidth + 16
            height: 26
            hoverEnabled: true
            onClicked: clearProc.running = true
            Rectangle {
                anchors.fill: parent
                radius: 4
                color: clearMa.containsMouse ? colors.errorContainer : "transparent"
            }
            Text {
                id: clearLabel
                anchors.centerIn: parent
                text: "Clear all"
                color: clearMa.containsMouse ? colors.textOnErrorContainer : colors.textDim
                font.pixelSize: 11
            }
        }
        MouseArea {
            id: closeMa
            width: 28; height: 28
            hoverEnabled: true
            onClicked: clipRoot.onClose()
            Rectangle {
                anchors.fill: parent
                radius: 4
                color: closeMa.containsMouse ? colors.surfaceBright : "transparent"
            }
            Text {
                anchors.centerIn: parent
                text: "\uF00D"
                color: colors.textMain
                font.pixelSize: 12
                font.family: colors.widgetIconFont
            }
        }
    }

    Rectangle { Layout.fillWidth: true; height: 1; color: colors.borderSubtle }

    Rectangle {
        Layout.fillWidth: true
        height: 28
        radius: 6
        color: colors.surface
        border.width: 1
        border.color: colors.borderSubtle
        TextInput {
            id: searchInput
            anchors.fill: parent
            anchors.leftMargin: 8
            anchors.rightMargin: 8
            verticalAlignment: Text.AlignVCenter
            color: colors.textMain
            font.pixelSize: 12
            font.family: colors.fontMain
            clip: true
            onTextChanged: clipRoot.searchText = text
        }
        Text {
            anchors.left: parent.left
            anchors.leftMargin: 8
            anchors.verticalCenter: parent.verticalCenter
            text: "\uF002  Search..."
            color: colors.textMuted
            font.pixelSize: 12
            font.family: colors.fontMain
            visible: searchInput.text === "" && !searchInput.activeFocus
        }
    }

    RowLayout {
        Layout.fillWidth: true
        spacing: 4

        Repeater {
            model: [
                { key: "text", label: "Text (" + clipRoot.textEntries.length + ")" },
                { key: "images", label: "Images (" + clipRoot.imageEntries.length + ")" }
            ]
            delegate: MouseArea {
                id: tabMa
                Layout.fillWidth: true
                height: 28
                hoverEnabled: true
                onClicked: {
                    clipRoot.activeTab = modelData.key
                    if (modelData.key === "images" && clipRoot.imageEntries.length > 0)
                        clipRoot.previewIndex = 0
                }
                Rectangle {
                    anchors.fill: parent
                    radius: 6
                    color: clipRoot.activeTab === modelData.key ? colors.primary : (tabMa.containsMouse ? colors.surfaceBright : colors.surface)
                }
                Text {
                    anchors.centerIn: parent
                    text: modelData.label
                    color: clipRoot.activeTab === modelData.key ? colors.textOnPrimary : colors.textMain
                    font.pixelSize: 11
                    font.bold: clipRoot.activeTab === modelData.key
                }
            }
        }
    }

    // --- TEXT TAB: full-width list ---
    Item {
        Layout.fillWidth: true
        Layout.fillHeight: true
        visible: clipRoot.activeTab === "text"
        clip: true
        Flickable {
            id: textFlick
            anchors.fill: parent
            contentWidth: width
            contentHeight: textCol.implicitHeight
            flickableDirection: Flickable.VerticalFlick
            boundsBehavior: Flickable.StopAtBounds

            Column {
                id: textCol
            width: parent.width
            spacing: 2

            Repeater {
                model: {
                    if (!clipRoot.searchText) return clipRoot.textEntries
                    var q = clipRoot.searchText.toLowerCase()
                    return clipRoot.textEntries.filter(function(e) { return e.toLowerCase().indexOf(q) >= 0 })
                }
                delegate: MouseArea {
                    id: textEntryMa
                    width: textCol.width
                    height: 32
                    hoverEnabled: true
                    onClicked: clipRoot.pasteEntry(modelData)
                    Rectangle {
                        anchors.fill: parent
                        radius: 6
                        color: textEntryMa.containsMouse ? colors.surfaceBright : "transparent"
                    }
                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.leftMargin: 8
                        anchors.rightMargin: 8
                        text: {
                            var raw = modelData || ""
                            var tab = raw.indexOf("\t")
                            var display = tab > 0 ? raw.substring(tab + 1) : raw
                            return display.length > 100 ? display.substring(0, 100) + "..." : display
                        }
                        elide: Text.ElideRight
                        color: textEntryMa.containsMouse ? colors.textMain : colors.textDim
                        font.pixelSize: 11
                        font.family: colors.fontMain
                    }
                }
            }

            Text {
                visible: clipRoot.textEntries.length === 0
                text: "No text in clipboard"
                color: colors.textMuted
                font.pixelSize: 12
                anchors.horizontalCenter: parent.horizontalCenter
                topPadding: 20
            }
        }
        }
        MouseArea {
            anchors.fill: parent
            acceptedButtons: Qt.MiddleButton
            onWheel: function(wheel) {
                var step = (wheel.angleDelta.y / 120) * 80
                textFlick.contentY = Math.max(0, Math.min(textFlick.contentY - step, Math.max(0, textFlick.contentHeight - textFlick.height)))
            }
        }
    }

    // --- IMAGES TAB: split layout (list left, preview right) ---
    RowLayout {
        Layout.fillWidth: true
        Layout.fillHeight: true
        visible: clipRoot.activeTab === "images"
        spacing: 8

        Item {
            Layout.preferredWidth: parent.width * 0.4
            Layout.fillHeight: true
            clip: true
            Flickable {
                id: imgFlick
                anchors.fill: parent
                contentWidth: width
                contentHeight: imgListCol.implicitHeight
                flickableDirection: Flickable.VerticalFlick
                boundsBehavior: Flickable.StopAtBounds

                Column {
                    id: imgListCol
                width: parent.width
                spacing: 2

                Repeater {
                    model: clipRoot.imageEntries
                    delegate: MouseArea {
                        id: imgEntryMa
                        width: imgListCol.width
                        height: 48
                        hoverEnabled: true
                        readonly property bool isSelected: index === clipRoot.previewIndex
                        onClicked: {
                            clipRoot.previewIndex = index
                        }

                        Rectangle {
                            anchors.fill: parent
                            radius: 6
                            color: imgEntryMa.isSelected ? colors.primary : (imgEntryMa.containsMouse ? colors.surfaceBright : "transparent")
                        }

                        Row {
                            anchors.fill: parent
                            anchors.leftMargin: 6
                            anchors.rightMargin: 6
                            spacing: 8

                            Image {
                                width: 36; height: 36
                                anchors.verticalCenter: parent.verticalCenter
                                fillMode: Image.PreserveAspectFit
                                source: "file://" + runtimeDirProc.dir + "/cliphist-thumbs/qml_" + index + ".png"
                                sourceSize.width: 36
                                sourceSize.height: 36
                                smooth: true
                                cache: false
                                onStatusChanged: if (status === Image.Error) source = ""
                            }

                            Text {
                                anchors.verticalCenter: parent.verticalCenter
                                text: "Image " + (index + 1)
                                color: imgEntryMa.isSelected ? colors.textOnPrimary : (imgEntryMa.containsMouse ? colors.textMain : colors.textDim)
                                font.pixelSize: 11
                                font.family: colors.fontMain
                            }
                        }
                    }
                }

                Text {
                    visible: clipRoot.imageEntries.length === 0
                    text: "No images"
                    color: colors.textMuted
                    font.pixelSize: 12
                    anchors.horizontalCenter: parent.horizontalCenter
                    topPadding: 20
                }
            }
            }
            MouseArea {
                anchors.fill: parent
                acceptedButtons: Qt.MiddleButton
                onWheel: function(wheel) {
                    var step = (wheel.angleDelta.y / 120) * 80
                    imgFlick.contentY = Math.max(0, Math.min(imgFlick.contentY - step, Math.max(0, imgFlick.contentHeight - imgFlick.height)))
                }
            }
        }

        // Large preview pane
        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            radius: 8
            color: colors.surface
            border.width: 1
            border.color: colors.borderSubtle

            Image {
                id: previewImage
                anchors.fill: parent
                anchors.margins: 8
                fillMode: Image.PreserveAspectFit
                source: clipRoot.previewIndex >= 0 ? ("file://" + runtimeDirProc.dir + "/cliphist-thumbs/qml_" + clipRoot.previewIndex + ".png") : ""
                smooth: true
                cache: false
                onStatusChanged: if (status === Image.Error) source = ""
            }

            Text {
                anchors.centerIn: parent
                visible: clipRoot.previewIndex < 0 || previewImage.status !== Image.Ready
                text: clipRoot.imageEntries.length === 0 ? "No images" : "Select an image"
                color: colors.textMuted
                font.pixelSize: 12
            }

            MouseArea {
                anchors.fill: parent
                cursorShape: clipRoot.previewIndex >= 0 ? Qt.PointingHandCursor : Qt.ArrowCursor
                onClicked: {
                    if (clipRoot.previewIndex >= 0 && clipRoot.previewIndex < clipRoot.imageEntries.length)
                        clipRoot.pasteEntry(clipRoot.imageEntries[clipRoot.previewIndex])
                }
            }

            Text {
                anchors.bottom: parent.bottom
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.bottomMargin: 4
                visible: clipRoot.previewIndex >= 0
                text: "Click to copy"
                color: colors.textMuted
                font.pixelSize: 10
            }
        }
    }
}
