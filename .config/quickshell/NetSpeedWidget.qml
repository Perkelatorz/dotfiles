import QtQuick
import Quickshell.Io

import "."

BarPill {
    id: netWidget
    pillIndex: 2

    // Rendered as a single label (single source for formatting lives in
    // SystemServices; the local duplicate formatter is gone).
    label: SystemServices.netSpeed

    Process {
        id: runConnectionEditor
        command: ["nm-connection-editor"]
        running: false
    }
    onClicked: runConnectionEditor.running = true
}
