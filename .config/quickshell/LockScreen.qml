import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Services.Pam

import "."

// The shell's own lock screen.
//
// It was `hyprlock`, which is installed but has no config — hyprlock reads
// ~/.config/hypr/hyprlock.conf and that directory was retired with Hyprland, so
// lock silently did nothing. Recreating a hypr directory for one binary, on a
// machine with no Hyprland, was the wrong repair.
//
// mango implements wlr_session_lock_manager_v1, and Quickshell speaks both that
// and PAM, so the shell can lock itself: same palette, same shapes, nothing
// external to configure.
WlSessionLock {
    id: lock
    required property var colors

    // `secure` is read-only — it REPORTS whether the compositor has confirmed
    // the lock, it does not request it. Worth knowing: the compositor holds the
    // lock until unlock() is called, so a crash in here leaves the session
    // locked rather than exposed, which is the correct failure direction.

    WlSessionLockSurface {
        id: surface
        color: "transparent"

        readonly property var colors: lock.colors

        Rectangle {
            anchors.fill: parent
            color: surface.colors.background
        }

        // Wallpaper tint, so the lock is recognisably this desktop rather than
        // a black rectangle.
        Rectangle {
            anchors.fill: parent
            gradient: Gradient {
                GradientStop {
                    position: 0.0
                    color: Qt.rgba(surface.colors.primary.r, surface.colors.primary.g,
                                   surface.colors.primary.b, 0.10)
                }
                GradientStop { position: 0.7; color: "transparent" }
            }
        }

        Column {
            anchors.centerIn: parent
            spacing: 26
            width: 320

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: Qt.formatDateTime(clockTick.now, "HH:mm")
                color: surface.colors.textMain
                font.pixelSize: 68
                font.bold: true
            }
            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: Qt.formatDateTime(clockTick.now, "dddd d MMMM")
                color: surface.colors.textDim
                font.pixelSize: 14
            }

            Item { width: 1; height: 8 }

            // Password field. Not a TextInput with echoMode alone — PAM decides
            // whether a response should be visible, so responseVisible drives it.
            Rectangle {
                anchors.horizontalCenter: parent.horizontalCenter
                width: parent.width
                height: 44
                radius: 22
                color: surface.colors.surfaceContainer
                border.width: 1
                border.color: pam.messageIsError
                    ? surface.colors.urgent
                    : (input.activeFocus
                        ? Qt.rgba(surface.colors.primary.r, surface.colors.primary.g,
                                  surface.colors.primary.b, 0.55)
                        : Qt.rgba(surface.colors.textMain.r, surface.colors.textMain.g,
                                  surface.colors.textMain.b, 0.12))
                Behavior on border.color { ColorAnimation { duration: 130 } }

                TextInput {
                    id: input
                    anchors.fill: parent
                    anchors.leftMargin: 18
                    anchors.rightMargin: 18
                    verticalAlignment: TextInput.AlignVCenter
                    color: surface.colors.textMain
                    font.pixelSize: 14
                    echoMode: pam.responseVisible ? TextInput.Normal : TextInput.Password
                    passwordCharacter: "•"
                    enabled: pam.responseRequired
                    focus: true
                    Component.onCompleted: forceActiveFocus()

                    onAccepted: {
                        if (!pam.responseRequired) return
                        pam.respond(text)
                        text = ""
                    }
                }

                Text {
                    anchors.centerIn: parent
                    visible: input.text === "" && !input.activeFocus
                    text: "Password"
                    color: surface.colors.textMuted
                    font.pixelSize: 13
                }
            }

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                width: parent.width
                horizontalAlignment: Text.AlignHCenter
                text: pam.message || (pam.active ? "" : "Checking…")
                color: pam.messageIsError ? surface.colors.urgent : surface.colors.textDim
                font.pixelSize: 12
                wrapMode: Text.Wrap
            }
        }

        Timer {
            id: clockTick
            property var now: new Date()
            interval: 1000
            running: true
            repeat: true
            triggeredOnStart: true
            onTriggered: now = new Date()
        }

        PamContext {
            id: pam
            // hyprlock ships /etc/pam.d/hyprlock, which is just an include of
            // `login`. Using `login` directly keeps this working with hyprlock
            // uninstalled.
            config: "login"
            active: true

            onCompleted: result => {
                if (result === PamResult.Success) {
                    lock.unlock()
                } else {
                    // Restart the conversation so another attempt is possible;
                    // PAM ends the context on failure.
                    active = false
                    active = true
                    input.forceActiveFocus()
                }
            }
            onError: {
                active = false
                active = true
            }
        }
    }
}
