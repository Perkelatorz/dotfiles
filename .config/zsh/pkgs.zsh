# ------------------------------------------------------------------
# Completion for `pkgs` (~/.config/scripts/pkgs).
#
# The script has eight subcommands and two list layouts (class/, host/), none
# of which are guessable at a prompt -- `pkgs <TAB>` was falling through to
# plain filename completion, which is why the answer to "what was that
# subcommand" kept being `pkgs --help`. Every subcommand and every list here
# carries its one-line description, so tab IS the help.
#
# List descriptions come from each file's first comment line -- the same blurb
# `pkgs add` shows in its picker, so the two never drift apart.
#
# Sourced from .zshrc after compinit (this file ends in a compdef).
# ------------------------------------------------------------------

_PKGS_DIR="$HOME/.config/yadm/packages"

# yadm shells out to git for this, so it is far too slow to run on every
# keystroke. The class of a machine does not change between prompts; cache it
# for the life of the shell.
_pkgs_class() {
    [[ -n "${_PKGS_CLASS-}" ]] || _PKGS_CLASS=$(yadm config local.class 2>/dev/null)
    print -r -- "$_PKGS_CLASS"
}
_pkgs_host() {
    [[ -n "${_PKGS_HOST-}" ]] || _PKGS_HOST=${$(hostname -s 2>/dev/null):-${(%):-%m}}
    print -r -- "$_PKGS_HOST"
}

# Every list, as a path relative to the packages dir (class/work.aur, not just
# work.aur -- class/laptop.pkgs and host/laptop.pkgs can coexist).
_pkgs_list_names() {
    local -a files
    files=( "$_PKGS_DIR"/**/*.(pkgs|aur)(N.) )
    print -l -- ${files#$_PKGS_DIR/}
}

# Does this list get installed on THIS box? Mirrors applies_here() in the
# script: top-level lists always do, class/ and host/ only when they match.
_pkgs_applies_here() {
    case "$1" in
        class/*) [[ "$1" == "class/$(_pkgs_class)."* ]] ;;
        host/*)  [[ "$1" == "host/$(_pkgs_host)."*   ]] ;;
        *)       true ;;
    esac
}

_pkgs_lists() {
    local -a lists
    local f blurb host="$(_pkgs_host)"

    for f in $(_pkgs_list_names); do
        blurb=$(grep -m1 '^# .' "$_PKGS_DIR/$f" 2>/dev/null | sed 's/^# *//' | cut -c1-52)
        _pkgs_applies_here "$f" && blurb="[this machine] $blurb"
        lists+=( "${f}:${blurb:-package list}" )
    done

    # Offer host/<this machine> before the file exists -- filing a
    # machine-specific package should not require creating the list by hand
    # first, which is exactly the friction that lands such packages in a class
    # list instead. `pkgs add -l` creates it (with a header) on demand.
    local ext
    for ext in pkgs aur; do
        [[ -f "$_PKGS_DIR/host/$host.$ext" ]] \
            || lists+=( "host/$host.$ext:[this machine] new list, created on add" )
    done

    _describe -t lists 'list' lists
}

# Drift first: `pkgs add` almost always means "record the thing I just pacman
# -S'd by hand", and drift is precisely that set. Everything else installed is
# the fallback group, for deliberately recording something older.
_pkgs_packages() {
    local -a drifted installed
    drifted=( ${(f)"$(pkgs drift 2>/dev/null)"} )
    installed=( ${(f)"$(pacman -Qqe 2>/dev/null)"} )
    _alternative \
        'drift:unrecorded (drift):compadd -a drifted' \
        'installed:installed:compadd -a installed'
}

_pkgs() {
    local -a subs=(
        'pick:interactive picker over drift (the bare `pkgs` default)'
        'status:counts for drift and missing, then both in full'
        'drift:installed by hand, in no list, not ISO baseline'
        'missing:declared in a list but not installed (+ which list)'
        'lists:every list, its size, and whether it applies here'
        'add:append package(s) to a list'
        'baseline:(re)generate the ISO baseline from pacman.log'
        'help:the header comment, as usage'
    )

    if (( CURRENT == 2 )); then
        _describe -t commands 'pkgs command' subs
        return
    fi

    case "$words[2]" in
        add)
            _arguments -S \
                '(-l --list)'{-l,--list}'[list to add to, skipping the picker]:list:_pkgs_lists' \
                '*:package:_pkgs_packages'
            ;;
    esac
}

compdef _pkgs pkgs
