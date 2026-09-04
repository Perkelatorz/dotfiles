import QtQuick

import "."

// The one bar pill — shared by every bar widget. The bar's geometry paints a
// wallpaper-tinted near-black ground (BarStyle.geometry); a pill draws ON that
// ground rather than carrying a fill of its own, so the default state is just
// dim ink and the eye has nothing to sort through.
//
// Colour is reserved for meaning. `active: true` is the only thing that spends
// it, and BarStyle.style picks how:
//   flat      — accent ink on a faint accent wash
//   underline — accent ink over an accent rule
//   filled    — accent container behind accent-on-container ink
// Widgets set activeColor/activeTextColor to override the accent (a muted mic
// passes `urgent`), so an urgent state still outranks an ordinary active one.
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

    // Selects which of the palette's accents this widget's ICON wears. It no
    // longer picks a background — widgetPillColors as 13 competing fills is what
    // made the bar read as noise — but the icon carrying colour is what keeps
    // the bar from going flat monochrome, since `active` states almost never
    // fire and would otherwise be the only colour on screen.
    //
    // The index is fixed per widget, so a given widget always wears the same
    // hue; the rotation is over the palette's three accents, all wallpaper-
    // derived, so it stays a family rather than a scatter.
    property int pillIndex: -1

    // ===== STYLE-DERIVED VISUALS =====
    readonly property string _style: BarStyle.style

    // The hue an active pill spends. activeColor is the widget's override.
    readonly property color _accent: active ? activeColor : _iconAccent

    readonly property var _accents: [colors.primary, colors.secondary, colors.tertiary]
    readonly property color _iconAccent: pillIndex >= 0
        ? (_accents[pillIndex % _accents.length] || colors.primary)
        : colors.primary

    readonly property int _radius: colors.widgetPillRadius + 1

    // Deliberately not colors.widgetPillPaddingH/spacing (8 and 5). Those were
    // sized for pills that carried a visible fill and needed to stay compact;
    // with no fill, the padding IS the separation between widgets, so it does
    // the work the old borders used to.
    readonly property int _padH: 10
    readonly property int _gap: 7

    readonly property color _fill: {
        if (active)
            return _style === "filled"    ? activeColor
                 : _style === "underline" ? "transparent"
                 : Qt.rgba(_accent.r, _accent.g, _accent.b, 0.14)   // flat
        if (ma.containsMouse && interactive)
            return Qt.rgba(colors.textMain.r, colors.textMain.g, colors.textMain.b, 0.13)
        return "transparent"
    }

    // Ink. Inactive widgets are deliberately uniform — no per-widget hue.
    // Label: neutral ink. The value is what you read, so it wants contrast,
    // not hue — and a coloured icon beside it already carries the identity.
    readonly property color fg: active
        ? (_style === "filled" ? activeTextColor : _accent)
        : (ma.containsMouse && interactive ? colors.textMain : colors.textDim)

    // Icon: always its accent, not only when active. This is the colour in the
    // bar. Hover lifts it toward white so the widget still answers the pointer.
    readonly property color iconFg: active
        ? (_style === "filled" ? activeTextColor : _accent)
        : (ma.containsMouse && interactive
            ? Qt.lighter(_iconAccent, 1.35)
            : _iconAccent)

    implicitWidth: present ? bgRect.width : 0
    implicitHeight: present ? 26 : 0
    visible: present

    Rectangle {
        id: bgRect
        visible: pill.present
        height: pill.implicitHeight - colors.widgetPillPaddingV * 2
        width: contentRow.implicitWidth + pill._padH * 2
        anchors.verticalCenter: parent.verticalCenter
        radius: pill._radius
        color: ma.pressed && pill.interactive
            ? Qt.darker(pill._fill.a > 0 ? pill._fill : pill.colors.surfaceContainer, 1.15)
            : pill._fill
        border.width: 0
        scale: ma.pressed && pill.interactive ? 0.96 : 1.0
        Behavior on color { ColorAnimation { duration: 110 } }
        Behavior on scale { NumberAnimation { duration: 80; easing.type: Easing.OutCubic } }

        // Accent underline — underline style only.
        Rectangle {
            visible: pill._style === "underline" && (pill.active || (ma.containsMouse && pill.interactive))
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            anchors.leftMargin: 4
            anchors.rightMargin: 4
            height: ma.containsMouse && pill.interactive ? 3 : 2
            radius: 1
            color: pill._accent
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
            spacing: pill._gap
            Text {
                visible: pill.icon !== ""
                text: pill.icon
                color: pill.iconFg
                Behavior on color { ColorAnimation { duration: 110 } }
                font.pixelSize: colors.cpuFontSize
                font.family: colors.widgetIconFont
                anchors.verticalCenter: parent.verticalCenter
            }
            Text {
                visible: pill.label !== ""
                text: pill.label
                color: pill.fg
                Behavior on color { ColorAnimation { duration: 110 } }
                font.pixelSize: colors.cpuFontSize
                anchors.verticalCenter: parent.verticalCenter
            }
        }
    }
}
