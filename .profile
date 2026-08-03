# POSIX-sh login fallback (zsh logins use ~/.config/zsh/.zprofile instead).
# NOTE: never set TERM here — terminals set their own (kitty uses xterm-kitty);
# forcing it breaks TTY logins and ssh.
export BROWSER=firefox
export QT_QPA_PLATFORMTHEME="qt5ct"

# ~/.local/bin for sh/POSIX login shells. zsh never reads this file — it gets
# the same entry from .config/zsh/.zprofile — so this is the only thing putting
# it on PATH for non-zsh logins.
#
# Replaces the installer-written `. "$HOME/.local/share/../bin/env"`, which
# prepended the identical directory spelled as .local/share/../bin and so left
# PATH carrying both forms. Delete that line again if an installer re-adds it.
case ":$PATH:" in
    *":$HOME/.local/bin:"*) ;;
    *) export PATH="$HOME/.local/bin:$PATH" ;;
esac
