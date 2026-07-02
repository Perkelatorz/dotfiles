import QtQuick

// The one bar pill — uniform + accent style shared by every bar widget.
// Quiet surfaceContainer fill + hairline border for everything; the theme
// accent lives in the icon; `active: true` lights the whole pill with the
// accent container for states that deserve attention (muted, low battery,
// pending updates). Replaces ~40 lines of copy-pasted Rectangle/MouseArea
// per widget (and their tooltips, which were anchored above a top bar —
// clipped by the window bounds, so they never actually rendered).
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

    readonly property color bg: active ? activeColor : _baseBg
    readonly property color fg: active ? activeTextColor : _baseFg
    readonly property color iconFg: active ? activeTextColor : (_colored ? _baseFg : colors.primary)

    implicitWidth: present ? bgRect.width : 0
    implicitHeight: present ? 28 : 0
    visible: present

    Rectangle {
        id: bgRect
        visible: pill.present
        height: pill.implicitHeight - colors.widgetPillPaddingV * 2
        width: contentRow.implicitWidth + colors.widgetPillPaddingH * 2
        anchors.verticalCenter: parent.verticalCenter
        radius: colors.widgetPillRadius
        color: ma.pressed && pill.interactive ? Qt.darker(pill.bg, 1.12)
             : ma.containsMouse && pill.interactive ? Qt.lighter(pill.bg, 1.25)
             : pill.bg
        border.width: 1
        // Tone-on-tone border for colored pills; hairline for the quiet ones.
        border.color: ma.containsMouse && pill.interactive ? colors.border
                    : pill._colored ? Qt.lighter(pill.bg, 1.25)
                    : colors.borderSubtle
        scale: ma.pressed && pill.interactive ? 0.95 : 1.0
        Behavior on color { ColorAnimation { duration: 100 } }
        Behavior on border.color { ColorAnimation { duration: 100 } }
        Behavior on scale { NumberAnimation { duration: 80; easing.type: Easing.OutCubic } }

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
