import QtQuick
import QtQuick.Layouts
import Quickshell.Io

import "."

ColumnLayout {
    id: kbRoot
    required property var colors
    required property var onClose

    property var categories: []
    property string searchText: ""

    spacing: 8

    Process {
        id: parseProc
        command: ["sh", "-c", "cat \"$HOME/.config/hypr/binds.conf\""]
        running: false
        stdout: StdioCollector {
            onStreamFinished: {
                var raw = (parseProc.stdout.text || "")
                var lines = raw.split("\n")
                var cats = []
                var currentCat = { name: "General", binds: [] }

                for (var i = 0; i < lines.length; i++) {
                    var line = lines[i].trim()
                    if (!line) continue

                    var catMatch = line.match(/^#\s*---\s*(.+?)\s*---/)
                    if (catMatch) {
                        if (currentCat.binds.length > 0) cats.push(currentCat)
                        currentCat = { name: catMatch[1], binds: [] }
                        continue
                    }

                    if (line.charAt(0) === '#' || line.charAt(0) === '$') continue

                    var bindMatch = line.match(/^bind[elmnrs]*\s*=\s*(.*)/)
                    if (!bindMatch) continue

                    var comment = ""
                    var commentIdx = line.lastIndexOf("#")
                    if (commentIdx > 0) comment = line.substring(commentIdx + 1).trim()

                    var content = bindMatch[1]
                    if (commentIdx > 0) {
                        var beforeComment = line.substring(0, commentIdx)
                        var eqIdx = beforeComment.indexOf("=")
                        if (eqIdx >= 0) content = beforeComment.substring(eqIdx + 1).trim()
                    }

                    var parts = content.split(",")
                    if (parts.length < 3) continue

                    var mods = parts[0].trim()
                    var key = parts[1].trim()
                    var action = parts.slice(2).join(",").trim()

                    var modList = mods.replace(/\$mainMod/g, "Super")
                        .replace(/SUPER/g, "Super")
                        .replace(/CTRL/g, "Ctrl")
                        .replace(/ALT/g, "Alt")
                        .replace(/SHIFT/g, "Shift")
                        .split(/\s+/)
                        .filter(function(m) { return m.length > 0 })

                    var keyDisplay = key
                        .replace("RETURN", "Enter")
                        .replace("bracketright", "]")
                        .replace("bracketleft", "[")
                        .replace("semicolon", ";")
                        .replace("grave", "`")
                        .replace("mouse:272", "LMB")
                        .replace("mouse:273", "RMB")
                        .replace("mouse_down", "ScrollDown")
                        .replace("mouse_up", "ScrollUp")
                        .replace("XF86AudioRaiseVolume", "Vol+")
                        .replace("XF86AudioLowerVolume", "Vol-")
                        .replace("XF86AudioMute", "Mute")
                        .replace("XF86MonBrightnessUp", "Bright+")
                        .replace("XF86MonBrightnessDown", "Bright-")
                        .replace("XF86AudioNext", "MediaNext")
                        .replace("XF86AudioPrev", "MediaPrev")
                        .replace("XF86AudioPlay", "MediaPlay")
                        .replace("XF86AudioPause", "MediaPause")
                        .replace("Tab", "Tab")

                    var desc = comment || action
                    currentCat.binds.push({ mods: modList, key: keyDisplay, description: desc })
                }
                if (currentCat.binds.length > 0) cats.push(currentCat)
                kbRoot.categories = cats
                parseProc.running = false
            }
        }
    }

    function refresh() {
        parseProc.running = true
    }

    Component.onCompleted: refresh()

    RowLayout {
        Layout.fillWidth: true
        spacing: 8
        Text {
            text: "Keybindings"
            color: colors.textMain
            font.pixelSize: 14
            font.bold: true
        }
        Item { Layout.fillWidth: true }
        MouseArea {
            id: closeMa
            width: 28; height: 28
            hoverEnabled: true
            onClicked: kbRoot.onClose()
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
            onTextChanged: kbRoot.searchText = text
        }
        Text {
            anchors.left: parent.left
            anchors.leftMargin: 8
            anchors.verticalCenter: parent.verticalCenter
            text: "\uF002  Filter keybinds..."
            color: colors.textMuted
            font.pixelSize: 12
            font.family: colors.fontMain
            visible: searchInput.text === "" && !searchInput.activeFocus
        }
    }

    Flickable {
        Layout.fillWidth: true
        Layout.fillHeight: true
        contentWidth: width
        contentHeight: catColumn.implicitHeight
        clip: true
        flickableDirection: Flickable.VerticalFlick
        boundsBehavior: Flickable.StopAtBounds

        Column {
            id: catColumn
            width: parent.width
            spacing: 12

            Repeater {
                model: kbRoot.categories
                delegate: Column {
                    id: catDelegate
                    width: catColumn.width
                    spacing: 4
                    readonly property var cat: modelData
                    readonly property var filteredBinds: {
                        if (!kbRoot.searchText) return cat.binds
                        var q = kbRoot.searchText.toLowerCase()
                        return cat.binds.filter(function(b) {
                            return b.description.toLowerCase().indexOf(q) >= 0 ||
                                   b.key.toLowerCase().indexOf(q) >= 0 ||
                                   b.mods.join(" ").toLowerCase().indexOf(q) >= 0
                        })
                    }

                    visible: filteredBinds.length > 0

                    Text {
                        text: cat.name
                        color: colors.primary
                        font.pixelSize: 12
                        font.bold: true
                        topPadding: 4
                    }

                    Rectangle {
                        width: parent.width
                        height: 1
                        color: colors.borderSubtle
                        opacity: 0.5
                    }

                    Repeater {
                        model: catDelegate.filteredBinds
                        delegate: Item {
                            width: catDelegate.width
                            height: 28

                            Row {
                                anchors.verticalCenter: parent.verticalCenter
                                spacing: 3

                                Repeater {
                                    model: modelData.mods.concat([modelData.key])
                                    delegate: Rectangle {
                                        width: kbdText.implicitWidth + 10
                                        height: 20
                                        radius: 4
                                        color: colors.surface
                                        border.width: 1
                                        border.color: colors.borderSubtle
                                        anchors.verticalCenter: parent.verticalCenter
                                        Text {
                                            id: kbdText
                                            anchors.centerIn: parent
                                            text: modelData
                                            color: colors.textMain
                                            font.pixelSize: 10
                                            font.bold: true
                                            font.family: colors.fontMain
                                        }
                                    }
                                }
                            }

                            Text {
                                anchors.right: parent.right
                                anchors.verticalCenter: parent.verticalCenter
                                text: modelData.description
                                color: colors.textDim
                                font.pixelSize: 11
                                font.family: colors.fontMain
                            }
                        }
                    }
                }
            }
        }
    }
}
