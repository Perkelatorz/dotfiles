import QtQuick

import "."

// The one bar pill — shared by every bar widget. Its look is driven by the
// global BarStyle singleton, so a single toggle restyles the whole bar:
//   pill      — filled, rounded, per-widget hue (the original)
//   neon      — transparent, glowing accent outline + icon
//   glass      — translucent frosted fill, big radius, soft drop shadow
//   underline — no box, just icon + text over an accent underline
//   blocks    — solid saturated fill, square corners (pair with tight spacing)
// The theme accent lives in the icon; `active: true` lights the whole pill with
// the accent container for states that deserve attention (muted, low battery,
// pending updates) — that filled treatment overrides the style so urgent
// states always read clearly.
Item {
    id: pill
    required property var colors

    property string icon: ""
    property string label: ""
    // Widget-side existence gate (e.g. battery present, updates pending).
    // Separate from `visible` because shell.qml overrides visible with the
    // user's widget toggles — present collapses width and hides the pill
    // regardless of that override.
    property bool present: true
    property bool active: false
    property color activeColor: colors.primaryContainer
    property color activeTextColor: colors.textOnPrimaryContainer
    property bool interactive: true
    property alias acceptedButtons: ma.acceptedButtons
    property alias hovered: ma.containsMouse
    // Extra visuals (badges, custom rows) drop into the content row.
    default property alias extraContent: contentRow.data

    signal clicked(var mouse)
    signal wheelMoved(var wheel)

    // Wallpaper-derived pill color (matugen's widgetPillColors array) — each
    // widget picks a slot so the bar carries the background's palette.
    // pillIndex -1 = quiet surface tone. Active states always override with
    // the accent/urgent container so meaningful states still stand out.
    property int pillIndex: -1
    readonly property bool _colored: pillIndex >= 0 && colors.widgetPillColors !== undefined && pillIndex < colors.widgetPillColors.length
    readonly property color _baseBg: _colored ? colors.widgetPillColors[pillIndex] : colors.surfaceContainer
    readonly property color _baseFg: _colored ? colors.widgetTextOnPillColors[pillIndex] : colors.textMain

    // The vivid per-widget hue the accent styles paint with (outline, glass
    // tint, underline). Falls back to the theme primary for quiet widgets.
    readonly property color _hue: _colored ? _baseBg : colors.primary

    // ===== STYLE-DERIVED VISUALS =====
    readonly property string _style: BarStyle.style

    readonly property color _fill: active ? activeColor
        : _style === "pill"   ? _baseBg
        : _style === "blocks" ? _hue
        : _style === "glass"  ? Qt.rgba(_hue.r, _hue.g, _hue.b, 0.20)
        : "transparent"          // neon, underline

    readonly property int _radius: _style === "glass" ? 13
        : (_style === "underline" || _style === "blocks") ? 0
        : colors.widgetPillRadius

    readonly property int _borderW: active ? 0
        : _style === "neon"  ? 2
        : _style === "pill"  ? 1
        : _style === "glass" ? 1
        : 0                      // underline, blocks

    readonly property color _borderCol: _style === "neon" ? _hue
        : _style === "glass" ? Qt.rgba(1, 1, 1, 0.18)
        : _colored ? Qt.lighter(_baseBg, 1.25) : colors.borderSubtle

    readonly property color iconFg: active ? activeTextColor
        : _style === "pill"   ? (_colored ? _baseFg : colors.primary)
        : _style === "blocks" ? _baseFg
        : _hue                   // neon, glass, underline

    readonly property color fg: active ? activeTextColor
        : (_style === "pill" || _style === "blocks") ? _baseFg
        : (_style === "glass" || _style === "underline") ? colors.textMain
        : _hue                   // neon

    implicitWidth: present ? bgRect.width : 0
    implicitHeight: present ? 28 : 0
    visible: present

    // Soft drop shadow — glass only, so widgets float above the bar.
    Rectangle {
        visible: pill.present && pill._style === "glass"
        anchors.fill: bgRect
        anchors.topMargin: 2
        anchors.leftMargin: 1
        radius: pill._radius
        color: pill.colors.panelShadow
        z: -2
    }

    // Outer glow — neon only. Faked with a soft accent-bordered halo that
    // brightens on hover (no shader dependency).
    Rectangle {
        id: glowRect
        visible: pill.present && pill._style === "neon"
        anchors.fill: bgRect
        anchors.margins: -2
        radius: pill._radius + 2
        color: "transparent"
        border.width: 2
        border.color: pill._hue
        opacity: ma.containsMouse && pill.interactive ? 0.55 : 0.25
        z: -1
        Behavior on opacity { NumberAnimation { duration: 120 } }
    }

    Rectangle {
        id: bgRect
        visible: pill.present
        height: pill.implicitHeight - colors.widgetPillPaddingV * 2
        width: contentRow.implicitWidth + colors.widgetPillPaddingH * 2
        anchors.verticalCenter: parent.verticalCenter
        radius: pill._radius
        // Hover/press modulation. Transparent styles have no fill to lighten,
        // so they gain a faint hue tint instead.
        color: {
            var base = pill._fill
            if (!pill.interactive) return base
            var transparent = base.a === 0
            if (ma.pressed)
                return transparent ? Qt.rgba(pill._hue.r, pill._hue.g, pill._hue.b, 0.18) : Qt.darker(base, 1.12)
            if (ma.containsMouse)
                return transparent ? Qt.rgba(pill._hue.r, pill._hue.g, pill._hue.b, 0.10) : Qt.lighter(base, 1.25)
            return base
        }
        border.width: pill._borderW
        border.color: ma.containsMouse && pill.interactive && pill._style === "pill" ? colors.border : pill._borderCol
        scale: ma.pressed && pill.interactive ? 0.95 : 1.0
        Behavior on color { ColorAnimation { duration: 100 } }
        Behavior on border.color { ColorAnimation { duration: 100 } }
        Behavior on scale { NumberAnimation { duration: 80; easing.type: Easing.OutCubic } }

        // Accent underline — underline style only.
        Rectangle {
            visible: pill._style === "underline"
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            anchors.leftMargin: 4
            anchors.rightMargin: 4
            height: ma.containsMouse && pill.interactive ? 3 : 2
            radius: 1
            color: pill._hue
            Behavior on height { NumberAnimation { duration: 100 } }
        }

        MouseArea {
            id: ma
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: pill.interactive ? Qt.PointingHandCursor : Qt.ArrowCursor
            acceptedButtons: Qt.LeftButton | Qt.MiddleButton | Qt.RightButton
            onClicked: mouse => pill.clicked(mouse)
            onWheel: w => pill.wheelMoved(w)
        }

        Row {
            id: contentRow
            anchors.centerIn: parent
            spacing: 5
            Text {
                visible: pill.icon !== ""
                text: pill.icon
                color: pill.iconFg
                font.pixelSize: colors.cpuFontSize
                font.family: colors.widgetIconFont
                anchors.verticalCenter: parent.verticalCenter
            }
            Text {
                visible: pill.label !== ""
                text: pill.label
                color: pill.fg
                font.pixelSize: colors.cpuFontSize
                anchors.verticalCenter: parent.verticalCenter
            }
        }
    }
}
