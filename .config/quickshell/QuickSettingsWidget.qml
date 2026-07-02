import QtQuick

import "."

BarPill {
    id: quickSettingsWidget
    pillIndex: 5

    signal menuToggleRequested()

    // Kebab menu — universal "more options", icon-only for a clean bar.
    icon: "\uF142"
    onClicked: quickSettingsWidget.menuToggleRequested()
}
