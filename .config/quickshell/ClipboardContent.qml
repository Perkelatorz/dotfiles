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

    spacing: 8

    readonly property string thumbDir: (Qt.resolvedUrl(".").toString().replace("file://", "").replace(/\/$/, "") + "/../../../.cache/cliphist-thumbs")

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
        listProc.running = true
    }

    function pasteEntry(entry) {
        pasteProc.command = ["sh", "-c", "echo " + JSON.stringify(entry) + " | cliphist decode | wl-copy"]
        pasteProc.running = true
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
                onClicked: clipRoot.activeTab = modelData.key
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

    Flickable {
        Layout.fillWidth: true
        Layout.fillHeight: true
        contentWidth: width
        contentHeight: contentCol.implicitHeight
        clip: true
        flickableDirection: Flickable.VerticalFlick
        boundsBehavior: Flickable.StopAtBounds

        Column {
            id: contentCol
            width: parent.width
            spacing: 2

            Repeater {
                model: {
                    var src = clipRoot.activeTab === "text" ? clipRoot.textEntries : clipRoot.imageEntries
                    if (!clipRoot.searchText) return src
                    var q = clipRoot.searchText.toLowerCase()
                    return src.filter(function(e) { return e.toLowerCase().indexOf(q) >= 0 })
                }

                delegate: MouseArea {
                    id: entryMa
                    width: contentCol.width
                    height: clipRoot.activeTab === "images" ? 72 : 32
                    hoverEnabled: true
                    onClicked: clipRoot.pasteEntry(modelData)

                    Rectangle {
                        anchors.fill: parent
                        radius: 6
                        color: entryMa.containsMouse ? colors.surfaceBright : "transparent"
                    }

                    Row {
                        anchors.fill: parent
                        anchors.leftMargin: 8
                        anchors.rightMargin: 8
                        spacing: 8
                        anchors.verticalCenter: parent.verticalCenter

                        Image {
                            visible: clipRoot.activeTab === "images"
                            width: 56; height: 56
                            anchors.verticalCenter: parent.verticalCenter
                            fillMode: Image.PreserveAspectFit
                            source: {
                                if (clipRoot.activeTab !== "images") return ""
                                var runtimeDir = StandardPaths ? StandardPaths.writableLocation(StandardPaths.RuntimeLocation) : "/tmp"
                                return "file://" + (runtimeDir || "/tmp") + "/cliphist-thumbs/qml_" + index + ".png"
                            }
                            sourceSize.width: 56
                            sourceSize.height: 56
                            smooth: true
                            cache: false
                            onStatusChanged: if (status === Image.Error) source = ""
                        }

                        Text {
                            width: parent.width - (clipRoot.activeTab === "images" ? 72 : 0)
                            anchors.verticalCenter: parent.verticalCenter
                            text: {
                                var raw = modelData || ""
                                var tab = raw.indexOf("\t")
                                var display = tab > 0 ? raw.substring(tab + 1) : raw
                                if (clipRoot.activeTab === "images") return "Image " + (index + 1)
                                return display.length > 80 ? display.substring(0, 80) + "..." : display
                            }
                            elide: Text.ElideRight
                            color: entryMa.containsMouse ? colors.textMain : colors.textDim
                            font.pixelSize: 11
                            font.family: colors.fontMain
                        }
                    }
                }
            }

            Text {
                visible: (clipRoot.activeTab === "text" ? clipRoot.textEntries.length : clipRoot.imageEntries.length) === 0
                text: clipRoot.activeTab === "text" ? "No text in clipboard" : "No images in clipboard"
                color: colors.textMuted
                font.pixelSize: 12
                anchors.horizontalCenter: parent.horizontalCenter
                topPadding: 20
            }
        }
    }
}
