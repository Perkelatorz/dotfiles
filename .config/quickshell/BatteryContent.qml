import QtQuick

import "."

// Power popout. Same shape as the System and Performance panels: the bar shows
// one reading, this holds the rest and the actions.
//
// The actionable part is the profile picker — everything else here is a
// readout, and switching profile is the one thing you actually come here to do.
Column {
    id: pwr
    required property var colors
    property var onClose: null
    property bool panelOpen: false

    width: 300
    padding: 12
    spacing: 10

    readonly property bool charging: SystemServices.batteryStatus === "Charging"
    readonly property int pct: SystemServices.batteryCapacity
    // Under 20% and not on the charger is the only state here worth alarm.
    readonly property bool low: pct <= 20 && !charging

    component Heading: Text {
        color: pwr.colors.textDim
        font.pixelSize: 11
        font.bold: true
    }
    component Rule: Rectangle {
        width: pwr.width - 24
        height: 1
        color: Qt.rgba(pwr.colors.textMain.r, pwr.colors.textMain.g, pwr.colors.textMain.b, 0.09)
    }
    component Row_: Item {
        required property string k
        required property string v
        width: pwr.width - 24
        height: 18
        Text {
            anchors.left: parent.left; anchors.verticalCenter: parent.verticalCenter
            text: parent.k; color: pwr.colors.textDim; font.pixelSize: 11
        }
        Text {
            anchors.right: parent.right; anchors.verticalCenter: parent.verticalCenter
            text: parent.v; color: pwr.colors.textMain; font.pixelSize: 11
        }
    }

    // ===== CHARGE =====
    Item {
        width: pwr.width - 24
        height: 30
        Text {
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            text: pwr.pct + "%"
            color: pwr.low ? pwr.colors.urgent : pwr.colors.textMain
            font.pixelSize: 22
            font.bold: true
        }
        Text {
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            text: SystemServices.batteryTimeText || SystemServices.batteryStatus
            color: pwr.colors.textDim
            font.pixelSize: 11
        }
    }
    Rectangle {
        width: pwr.width - 24
        height: 6
        radius: 3
        color: Qt.rgba(pwr.colors.textMain.r, pwr.colors.textMain.g, pwr.colors.textMain.b, 0.12)
        Rectangle {
            width: parent.width * Math.max(0, Math.min(1, pwr.pct / 100))
            height: parent.height
            radius: parent.radius
            color: pwr.low ? pwr.colors.urgent
                 : pwr.charging ? pwr.colors.tertiary
                 : pwr.colors.primary
            Behavior on width { NumberAnimation { duration: 300 } }
        }
    }

    Row_ {
        k: pwr.charging ? "Charging at" : "Drawing"
        v: SystemServices.batteryRateW > 0
            ? SystemServices.batteryRateW.toFixed(1) + " W" : "—"
    }
    Row_ {
        k: "Health"
        v: SystemServices.batteryHealthKnown ? SystemServices.batteryHealth + "%" : "not reported"
    }

    Rule {}

    // ===== PROFILE =====
    Heading { text: "POWER PROFILE" }
    Row {
        spacing: 6
        Repeater {
            model: [
                { id: "power-saver", label: "Save" },
                { id: "balanced",    label: "Balanced" },
                { id: "performance", label: "Performance" }
            ]
            delegate: Rectangle {
                required property var modelData
                readonly property bool selected:
                    SystemServices.powerProfile.toLowerCase() === modelData.id
                width: (pwr.width - 24 - 12) / 3
                height: 28
                radius: 8
                color: selected
                    ? Qt.rgba(pwr.colors.primary.r, pwr.colors.primary.g, pwr.colors.primary.b, 0.18)
                    : (ma.containsMouse
                        ? Qt.rgba(pwr.colors.textMain.r, pwr.colors.textMain.g, pwr.colors.textMain.b, 0.07)
                        : "transparent")
                border.width: 1
                border.color: selected
                    ? Qt.rgba(pwr.colors.primary.r, pwr.colors.primary.g, pwr.colors.primary.b, 0.45)
                    : Qt.rgba(pwr.colors.textMain.r, pwr.colors.textMain.g, pwr.colors.textMain.b, 0.10)
                Behavior on color { ColorAnimation { duration: 110 } }
                Text {
                    anchors.centerIn: parent
                    text: modelData.label
                    color: parent.selected ? pwr.colors.primary : pwr.colors.textDim
                    font.pixelSize: 11
                    font.bold: parent.selected
                }
                MouseArea {
                    id: ma
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: SystemServices.setPowerProfile(modelData.id)
                }
            }
        }
    }
}
