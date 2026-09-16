import QtQuick
import Quickshell

import "."

// Right-click menu for one window, opened off its icon in the workspace strip.
//
// Takes only the client id, never a snapshot of the window: the workspace model
// upstream is deduped on class/address and deliberately carries no window state
// (see root._wsSignature in shell.qml), so every flag shown here is read live
// off MangoIpc instead. A window retagged, floated or closed from elsewhere
// while the menu is open therefore updates under the cursor rather than going
// stale — and a closed one takes the menu down with it.
Column {
    id: menu

    required property var colors
    // String, to match the `address` the workspace model carries.
    required property string clientId
    // The tag whose icon was clicked. Not the same as the window's tag when a
    // window is pinned to several (toggleglobal), which is why it is passed in
    // rather than read off the client.
    property int tagIndex: 0
    property int tagCount: 5
    property bool multiMonitor: false

    signal close()

    readonly property var client: MangoIpc.clientById(menu.clientId)
    readonly property bool alive: !!menu.client

    // The window went away (closed elsewhere, or by the Close row below).
    // Leaving the menu up would leave every row pointing at a dead id.
    onAliveChanged: if (menu.clientId !== "" && !menu.alive) menu.close()

    spacing: 0
    padding: 0

    readonly property string appId: menu.alive ? String(menu.client.appid || "") : ""
    readonly property string iconPath: menu.appId ? Quickshell.iconPath(menu.appId.toLowerCase(), true) : ""

    // dispatch("togglefloating") / dispatch("tagsilent", 3), always targeted at
    // this window rather than whatever happens to be focused.
    function act(func, arg) {
        if (!menu.alive) return
        var cmd = (arg === undefined || arg === null) ? func : (func + "," + arg)
        MangoIpc.dispatch(cmd, "client," + menu.clientId)
    }

    function focusWindow() {
        if (!menu.alive) return
        var c = menu.client
        var tags = Array.isArray(c.tags) ? c.tags : []
        // Prefer the tag the icon was clicked on; a pinned window lives on
        // several and the clicked one is the one the user meant.
        var tag = tags.indexOf(menu.tagIndex) >= 0 ? menu.tagIndex : (tags.length ? tags[0] : 0)
        if (c.monitor) MangoIpc.dispatch("focusmon," + c.monitor)
        if (tag > 0) MangoIpc.dispatch("view," + tag + ",0")
        MangoIpc.dispatch("focusid", "client," + menu.clientId)
    }

    // --- building blocks --------------------------------------------------
    component Divider: Item {
        width: menu.width
        height: 9
        Rectangle {
            anchors.centerIn: parent
            width: menu.width - 20
            height: 1
            color: Qt.rgba(menu.colors.textMain.r, menu.colors.textMain.g,
                           menu.colors.textMain.b, 0.09)
        }
    }

    component MenuRow: MouseArea {
        id: row
        required property string glyph
        required property string label
        // Toggle rows carry their current state in the accent, so the menu
        // doubles as a readout of the window — no separate status line.
        property bool on: false
        property bool danger: false
        signal triggered()

        width: menu.width
        height: 30
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: row.triggered()

        readonly property color accent: row.danger ? menu.colors.urgent : menu.colors.primary

        Rectangle {
            anchors.fill: parent
            anchors.leftMargin: 4
            anchors.rightMargin: 4
            radius: 6
            color: {
                if (row.containsMouse)
                    return Qt.rgba(row.accent.r, row.accent.g, row.accent.b, 0.12)
                if (row.on) return Qt.rgba(row.accent.r, row.accent.g, row.accent.b, 0.08)
                return "transparent"
            }
            Behavior on color { ColorAnimation { duration: 100 } }
        }
        Row {
            anchors.verticalCenter: parent.verticalCenter
            leftPadding: 10
            spacing: 10
            Text {
                text: row.glyph
                color: (row.on || row.containsMouse) ? row.accent : menu.colors.textMain
                font.pixelSize: 13
                font.family: menu.colors.widgetIconFont
                anchors.verticalCenter: parent.verticalCenter
            }
            Text {
                text: row.label
                color: row.on ? row.accent
                     : (row.containsMouse ? (row.danger ? row.accent : menu.colors.textMain)
                                          : menu.colors.textDim)
                font.pixelSize: menu.colors.clockFontSize
                anchors.verticalCenter: parent.verticalCenter
            }
        }
        // A tick on the right for the rows that are states rather than verbs.
        Text {
            anchors.right: parent.right
            anchors.rightMargin: 14
            anchors.verticalCenter: parent.verticalCenter
            visible: row.on
            text: ""
            color: row.accent
            font.pixelSize: 11
            font.family: menu.colors.widgetIconFont
        }
    }

    // ===== HEADER =====
    Item {
        width: menu.width
        height: 38

        Image {
            id: headerIcon
            x: 10
            anchors.verticalCenter: parent.verticalCenter
            width: 18
            height: 18
            source: menu.iconPath
            sourceSize.width: 18
            sourceSize.height: 18
            visible: menu.iconPath !== "" && status !== Image.Error
            smooth: true
            mipmap: true
        }
        Text {
            x: 10
            anchors.verticalCenter: parent.verticalCenter
            visible: !headerIcon.visible
            text: (menu.appId.charAt(0) || "?").toUpperCase()
            color: menu.colors.textDim
            font.pixelSize: 13
            font.bold: true
        }

        Column {
            x: 38
            width: menu.width - 48
            anchors.verticalCenter: parent.verticalCenter
            spacing: 1
            Text {
                width: parent.width
                elide: Text.ElideRight
                text: menu.alive ? (menu.client.title || menu.appId || "?") : ""
                color: menu.colors.textMain
                font.pixelSize: menu.colors.fontSm
            }
            Text {
                width: parent.width
                elide: Text.ElideRight
                text: menu.appId
                color: menu.colors.textDim
                font.pixelSize: menu.colors.fontXs
            }
        }
    }

    Divider {}

    // ===== ACTIONS =====
    MenuRow {
        glyph: ""
        label: "Focus"
        onTriggered: { menu.focusWindow(); menu.close() }
    }
    MenuRow {
        glyph: ""
        label: "Floating"
        on: menu.alive && !!menu.client.is_floating
        onTriggered: menu.act("togglefloating")
    }
    MenuRow {
        glyph: ""
        label: "Fullscreen"
        on: menu.alive && !!menu.client.is_fullscreen
        onTriggered: menu.act("togglefullscreen")
    }
    MenuRow {
        glyph: ""
        label: "Maximize"
        on: menu.alive && !!menu.client.is_maximized
        onTriggered: menu.act("togglemaximizescreen")
    }
    MenuRow {
        glyph: ""
        label: "Center"
        // centerwin only has anything to centre when the window is out of the
        // layout; on a tiled window it is a no-op, so it isn't offered.
        visible: menu.alive && !!menu.client.is_floating
        onTriggered: menu.act("centerwin")
    }
    MenuRow {
        glyph: ""
        label: "Pin to every tag"
        on: menu.alive && !!menu.client.is_global
        onTriggered: menu.act("toggleglobal")
    }

    Divider {}

    // ===== MOVE TO TAG =====
    Item {
        width: menu.width
        height: 18
        Text {
            x: 10
            anchors.verticalCenter: parent.verticalCenter
            text: "Move to tag"
            color: menu.colors.textDim
            font.pixelSize: menu.colors.fontXs
            font.bold: true
        }
    }
    Item {
        width: menu.width
        height: 32
        Row {
            x: 10
            anchors.verticalCenter: parent.verticalCenter
            spacing: 4
            Repeater {
                model: menu.tagCount
                delegate: Rectangle {
                    id: chip
                    required property int index
                    readonly property int tag: chip.index + 1
                    // A pinned window is on every tag; "current" then means the
                    // icon that was clicked, not all of them.
                    readonly property bool current: menu.alive
                        && Array.isArray(menu.client.tags)
                        && menu.client.tags.indexOf(chip.tag) >= 0
                    width: 26
                    height: 24
                    radius: 6
                    color: {
                        var a = menu.colors.primary
                        if (chip.current) return Qt.rgba(a.r, a.g, a.b, 0.22)
                        if (chipMa.containsMouse)
                            return Qt.rgba(menu.colors.textMain.r, menu.colors.textMain.g,
                                           menu.colors.textMain.b, 0.10)
                        return Qt.rgba(menu.colors.textMain.r, menu.colors.textMain.g,
                                       menu.colors.textMain.b, 0.04)
                    }
                    Behavior on color { ColorAnimation { duration: 100 } }
                    Text {
                        anchors.centerIn: parent
                        text: chip.tag
                        color: chip.current ? menu.colors.primary
                             : (chipMa.containsMouse ? menu.colors.textMain : menu.colors.textDim)
                        font.pixelSize: menu.colors.fontSm
                    }
                    MouseArea {
                        id: chipMa
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        // tagsilent, not tag: the window moves, the view stays
                        // put. Sending something away and being yanked after it
                        // is the behaviour you never want from a bar.
                        onClicked: { menu.act("tagsilent", chip.tag); menu.close() }
                    }
                }
            }
        }
    }

    // ===== MONITORS =====
    Divider { visible: menu.multiMonitor }
    MenuRow {
        glyph: ""
        label: "Send to next screen"
        visible: menu.multiMonitor
        onTriggered: { menu.act("tagmon", "right"); menu.close() }
    }
    MenuRow {
        glyph: ""
        label: "Send to previous screen"
        visible: menu.multiMonitor
        onTriggered: { menu.act("tagmon", "left"); menu.close() }
    }

    Divider {}

    MenuRow {
        glyph: ""
        label: "Close window"
        danger: true
        onTriggered: { menu.act("killclient"); menu.close() }
    }

    Item { width: 1; height: 4 }
}
