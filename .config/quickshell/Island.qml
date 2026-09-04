import QtQuick

import "."

// The ground one bar section sits on in the `islands` geometry: a rounded
// wallpaper-tinted near-black plate behind the widgets, held just off opaque so
// the background still reads through. Inert in the other two geometries, where
// the bar paints one continuous ground instead.
Rectangle {
    required property var colors
    required property bool enabled
    property int groundRadius: 19

    visible: enabled
    radius: groundRadius
    color: Qt.rgba(colors.background.r, colors.background.g, colors.background.b, 0.93)
    // borderSubtle (#52434a) reads as a lit mauve outline at 1px on this
    // ground. The plate should be defined by its fill, not by a rule around it.
    border.width: 1
    border.color: Qt.rgba(colors.textMain.r, colors.textMain.g, colors.textMain.b, 0.07)
    z: -1
}
