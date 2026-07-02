import QtQuick

import "."

BarPill {
    id: quickSettingsWidget

    signal menuToggleRequested()

    // Kebab menu — universal "more options", icon-only for a clean bar.
    icon: "\uF142"
    onClicked: quickSettingsWidget.menuToggleRequested()
}
