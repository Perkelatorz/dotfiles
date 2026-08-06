# ------------------------------------------------------------------
# `st` — day-to-day Syncthing control without opening the web UI.
#
# The GUI at http://127.0.0.1:8384 is still the place for anything fiddly; this
# covers the handful of things worth having in the shell, plus three that the GUI
# makes genuinely tedious:
#
#   st add       pairing. Discovery is off (tailnet-only), so a device is useless
#                without an explicit tcp://100.x.x.x:22000 address AND a folder
#                share. That is three screens in the GUI and easy to half-finish.
#   st conflicts sync conflicts are just files with an awkward name; nothing in
#                the GUI lists them.
#   st restore   .stversions is a plain folder. The GUI's restore dialog is
#                per-folder and clumsy; fzf over the versions is faster.
#
# Sourced from .zshrc after compinit (this file ends in a compdef).
# ------------------------------------------------------------------

_ST_URL=http://127.0.0.1:8384
_ST_FOLDER=notes

# The API key lives in syncthing's own config. v2 keeps it under XDG_STATE_HOME;
# v1 used ~/.config/syncthing. Read lazily so sourcing this file costs nothing.
_st_key() {
    local d
    for d in "${XDG_STATE_HOME:-$HOME/.local/state}/syncthing" "$HOME/.config/syncthing"; do
        if [[ -f "$d/config.xml" ]]; then
            sed -n 's:.*<apikey>\(.*\)</apikey>.*:\1:p' "$d/config.xml" | head -1
            return
        fi
    done
}

# GET a REST path. Returns non-zero (quietly) when the daemon is down, so callers
# can print something friendlier than a curl error.
_st_get() { curl -sf -H "X-API-Key: $(_st_key)" "$_ST_URL$1" }
_st_post() { curl -sf -X POST -H "X-API-Key: $(_st_key)" "$_ST_URL$1" }

_st_up() { _st_get /rest/noauth/health &>/dev/null }

_st_status() {
    print -r -- "service : $(systemctl --user is-active syncthing.service) ($(systemctl --user is-enabled syncthing.service)), linger=$(loginctl show-user "$USER" -p Linger --value)"
    if ! _st_up; then
        print -ru2 -- "daemon  : not responding on $_ST_URL"
        return 1
    fi

    local ver
    ver=$(_st_get /rest/system/version | jq -r '.version')
    print -r -- "daemon  : $ver"
    print -r -- "device  : $(_st_get /rest/system/status | jq -r .myID)"

    # Listener addresses double as the tailnet-only check: anything bound to
    # "default" or 0.0.0.0 means the lockdown is not in effect.
    print -r -- "listen  : $(_st_get /rest/config/options | jq -r '.listenAddresses | join(", ")')"
    print -r -- "discovery: global=$(_st_get /rest/config/options | jq -r '.globalAnnounceEnabled') local=$(_st_get /rest/config/options | jq -r '.localAnnounceEnabled') relays=$(_st_get /rest/config/options | jq -r '.relaysEnabled')"

    print -r -- ""
    print -r -- "folders:"
    local f
    for f in $(_st_get /rest/config/folders | jq -r '.[].id'); do
        _st_get "/rest/db/status?folder=$f" | jq -r --arg f "$f" \
            '"  \($f): \(.state)  \(.localFiles) files, \(.localBytes/1024|floor)K" +
             (if .needFiles > 0 then "  — \(.needFiles) to pull" else "" end) +
             (if .errors > 0 then "  ⚠️  \(.errors) errors" else "" end)'
    done

    print -r -- ""
    _st_peers

    local errs pend
    errs=$(_st_get /rest/system/error | jq -r '.errors // [] | length')
    (( errs > 0 )) && print -r -- "" && print -r -- "⚠️  $errs daemon error(s) — 'st errors'"
    pend=$(_st_get /rest/cluster/pending/devices | jq -r 'length')
    (( pend > 0 )) && print -r -- "" && print -r -- "📨 $pend device(s) asking to connect — 'st pending'"
    return 0
}

_st_peers() {
    local devices conns me
    me=$(_st_get /rest/system/status | jq -r .myID)
    devices=$(_st_get /rest/config/devices)
    conns=$(_st_get /rest/system/connections)
    # The local device appears in both lists; drop it, it is not a peer.
    local n
    n=$(jq -r --arg me "$me" '[.[] | select(.deviceID != $me)] | length' <<<"$devices")
    if (( n == 0 )); then
        print -r -- "peers   : none paired yet — 'st id' then 'st add <id> <tailscale-ip>'"
        return
    fi
    print -r -- "peers:"
    jq -r --arg me "$me" --argjson c "$conns" '
        .[] | select(.deviceID != $me) |
        . as $d |
        ($c.connections[$d.deviceID] // {}) as $k |
        "  \($d.name // "?")  \($d.deviceID[0:7])  " +
        (if $k.connected then "connected via \($k.address) (\($k.type))"
         else "DISCONNECTED  addrs=\($d.addresses | join(","))" end)
    ' <<<"$devices"
}

# Pair a peer in one step: device entry with an explicit tailnet address, plus a
# share of the vault folder. Both halves are required and the GUI splits them.
_st_add() {
    local id="$1" ip="$2" name="${3:-}"
    if [[ -z $id || -z $ip ]]; then
        print -ru2 -- "usage: st add <DEVICE-ID> <tailscale-ip> [name]"
        print -ru2 -- "  the ip is required: discovery is off, so 'dynamic' never connects"
        return 1
    fi
    # Accept a bare tailnet IP or a full tcp:// address.
    [[ $ip == tcp://* || $ip == quic://* ]] || ip="tcp://${ip}:22000"

    syncthing cli config devices add --device-id "$id" ${name:+--name "$name"} --addresses "$ip" \
        || { print -ru2 -- "st: could not add the device (already present?)"; }
    syncthing cli config folders "$_ST_FOLDER" devices add --device-id "$id" \
        || { print -ru2 -- "st: could not share '$_ST_FOLDER' with it"; return 1; }
    print -r -- "added $id at $ip and shared '$_ST_FOLDER'"
    print -r -- "now do the mirror image on that machine, using this one's id:"
    print -r -- "  $(_st_get /rest/system/status | jq -r .myID)  at  tcp://$(tailscale ip -4 2>/dev/null | head -1):22000"
}

_st_pending() {
    local p
    p=$(_st_get /rest/cluster/pending/devices)
    if [[ $(jq -r 'length' <<<"$p") == 0 ]]; then
        print -r -- "no pending device requests"
        return
    fi
    jq -r 'to_entries[] | "  \(.value.name // "?")  \(.key)\n    seen \(.value.time)  from \(.value.address)"' <<<"$p"
    print -r --
    print -r -- "accept with: st add <id> <tailscale-ip>"
}

# Conflict files are ordinary files with an awkward name; nothing surfaces them.
_st_conflicts() {
    local vault="${NOTES:-$HOME/notes}"
    local -a hits
    hits=( ${vault}/**/*sync-conflict*(.N) )
    if (( ! $#hits )); then
        print -r -- "no sync conflicts in $vault"
        return
    fi
    print -r -- "${#hits} conflict file(s):"
    printf '  %s\n' ${hits#$vault/}
    print -r --
    print -r -- "diff one against its original with: st diff <conflict-file>"
}

# Show a conflict beside the file it forked from. Syncthing's naming is
# <base>.sync-conflict-<date>-<time>-<device>.<ext>, so the original is
# recoverable by stripping that middle chunk.
_st_diff() {
    local c="$1"
    [[ -n $c ]] || { print -ru2 -- "usage: st diff <conflict-file>"; return 1 }
    [[ -f $c ]] || c="${NOTES:-$HOME/notes}/$c"
    [[ -f $c ]] || { print -ru2 -- "st: no such file: $1"; return 1 }
    local orig="${c/.sync-conflict-*./.}"
    [[ -f $orig ]] || { print -ru2 -- "st: cannot find the original for $c"; return 1 }
    if (( $+commands[delta] )); then
        delta "$orig" "$c"
    else
        diff -u --color=always "$orig" "$c" | ${PAGER:-less} -R
    fi
}

# .stversions is a plain folder of timestamped copies. fzf over it beats the
# GUI's per-folder restore dialog.
_st_restore() {
    local vault="${NOTES:-$HOME/notes}" vdir
    vdir="$vault/.stversions"
    [[ -d $vdir ]] || { print -r -- "no versions yet ($vdir)"; return }
    local pick
    pick=$( cd -- "$vdir" && print -rl -- **/*(.omN) |
        fzf --prompt='version> ' --height=70% --reverse --select-1 --exit-0 \
            --preview="bat --style=plain --color=always $vdir/{} 2>/dev/null || cat $vdir/{}" ) || return
    [[ -n $pick ]] || return
    print -r -- "$vdir/$pick"
    print -r -- "restore with:  cp '$vdir/$pick' '$vault/<target>.md'"
}

_st_help() {
    print -r -- "st — syncthing ($_ST_URL, folder '$_ST_FOLDER')

  st                    overview: service, listeners, folders, peers
  st peers              per-device connection state
  st id                 this device's ID and tailnet address (hand to a peer)
  st add <id> <ip>      pair a peer: explicit address + share the vault
  st pending            devices asking to connect
  st conflicts          list sync-conflict files in the vault
  st diff <file>        conflict vs original
  st restore            fzf over .stversions
  st rescan             force a scan now
  st errors [clear]     daemon errors
  st gui                open the web UI
  st log                follow the journal
  st start|stop|restart control the user service"
}

st() {
    emulate -L zsh
    local cmd=${1-}
    (( $# )) && shift

    case $cmd in
        ''|status)     _st_status ;;
        peers|devices) _st_up && _st_peers || print -ru2 -- "daemon not running" ;;
        id)
            _st_up || { print -ru2 -- "daemon not running"; return 1 }
            print -r -- "device id : $(_st_get /rest/system/status | jq -r .myID)"
            print -r -- "address   : tcp://$(tailscale ip -4 2>/dev/null | head -1):22000" ;;
        add)           _st_add "$@" ;;
        pending)       _st_pending ;;
        conflicts)     _st_conflicts ;;
        diff)          _st_diff "$@" ;;
        restore)       _st_restore ;;
        rescan)        _st_post "/rest/db/scan?folder=$_ST_FOLDER" && print -r -- "rescan queued" ;;
        errors)
            if [[ ${1-} == clear ]]; then
                _st_post /rest/system/error/clear && print -r -- "cleared"
            else
                _st_get /rest/system/error | jq -r '.errors // [] | if length == 0 then "no errors" else .[] | "  \(.when)  \(.message)" end'
            fi ;;
        gui)           ${BROWSER:-xdg-open} "$_ST_URL" &>/dev/null & disown ;;
        log)           journalctl --user -u syncthing.service -f -o cat ;;
        start|stop|restart) systemctl --user "$cmd" syncthing.service && print -r -- "syncthing $cmd" ;;
        help|-h|--help) _st_help ;;
        *)             print -ru2 -- "st: unknown command '$cmd'"; _st_help; return 1 ;;
    esac
}

_st() {
    (( CURRENT == 2 )) || return 0
    local -a subs=(
        'status:service, listeners, folders, peers'
        'peers:per-device connection state'
        'id:this device ID + tailnet address'
        'add:pair a peer (id + tailscale ip)'
        'pending:devices asking to connect'
        'conflicts:list sync-conflict files'
        'diff:conflict vs original'
        'restore:browse .stversions'
        'rescan:force a scan'
        'errors:daemon errors'
        'gui:open the web UI'
        'log:follow the journal'
        'start:start the user service'
        'stop:stop the user service'
        'restart:restart the user service'
        'help:usage'
    )
    _describe -t commands 'st command' subs
}
compdef _st st
