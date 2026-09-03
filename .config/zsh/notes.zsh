# ------------------------------------------------------------------
# Notes vault ($NOTES, default ~/notes) — CLI half of the Neovim <leader>o maps.
#
# The vault is a plain folder of Markdown, so most of this is "nvim, but with
# the cwd set correctly". Two things earn a wrapper rather than an alias:
#
#   * cwd. obsidian.nvim locates its workspace by path, so it works from
#     anywhere — but Telescope's find_files/live_grep follow the cwd. Launching
#     nvim from ~/src and then hitting <leader>ff silently searches the wrong
#     tree. Every entry point below runs nvim from inside the vault.
#
#   * Naming. New notes go through `:Obsidian new` instead of touching a file,
#     so the filename comes from the plugin's note_id_func and matches notes
#     created inside the editor. Two spellings of the same title would break
#     [[wiki]] links.
#
# Sourced from .zshrc after compinit (compdef at the bottom needs it).
# ------------------------------------------------------------------

# Preview commands for the pickers. fzf runs these through `sh`, so they have to
# be complete command lines, not shell functions. bat is in base.pkgs; degrade to
# cat rather than showing an error pane on a machine that is not bootstrapped yet.
# {} / {1} is the file, {2} the line number.
if (( $+commands[bat] )); then
    _notes_preview='bat --style=plain --color=always {}'
    _notes_preview_line='bat --style=plain --color=always --highlight-line {2} {1}'
else
    _notes_preview='cat {}'
    _notes_preview_line='cat {1}'
fi

# Run nvim with the vault as cwd. Subshell, so the caller's directory is intact.
# (The bare `notes` entry point deliberately does NOT use this -- see below.)
_notes_nvim() {
    ( cd -- "${NOTES:-$HOME/notes}" && nvim "$@" )
}

# Bare `notes` / `nn`: the "I'm going to work in my notes now" entry point.
# Unlike the targeted forms it cd's the *caller's* shell into the vault, so
# quitting nvim leaves you there rather than back wherever you started, and it
# opens the file tree since browsing is the point when you have not named a note.
#
# Lands on todo.md, not index.md: the running list is what you actually want in
# front of you on arrival. `notes index` still opens the map.
_notes_enter() {
    cd -- "${NOTES:-$HOME/notes}" || return
    local landing=todo.md
    [[ -f $landing ]] || landing=index.md
    nvim "$landing" -c 'Neotree show position=left'
}

# Fuzzy-pick a note by filename. Listed newest-first: the `(.omN)` glob
# qualifiers mean plain files, ordered by mtime, and no error if none match.
_notes_pick() {
    local file
    file=$(
        cd -- "${NOTES:-$HOME/notes}" &&
        print -rl -- **/*.md(.omN) |
            fzf --query="${1-}" --select-1 --exit-0 \
                --height=70% --reverse --prompt='note> ' \
                --preview="$_notes_preview"
    ) || return
    [[ -n $file ]] && _notes_nvim -- "$file"
}

# Full-text search, then open the chosen hit on its line.
# --color=never on purpose: the output is parsed back apart below, and ANSI
# escapes would end up inside the filename.
_notes_grep() {
    local hit file line
    hit=$(
        cd -- "${NOTES:-$HOME/notes}" &&
        rg --line-number --no-heading --smart-case --color=never -- "$*" |
            fzf --delimiter=: --nth=1,3.. --select-1 --exit-0 \
                --height=70% --reverse --prompt='match> ' \
                --preview="$_notes_preview_line" \
                --preview-window='+{2}/2'
    ) || return
    [[ -n $hit ]] || return
    file=${hit%%:*}
    line=${${hit#*:}%%:*}
    _notes_nvim "+$line" -- "$file"
}

_notes_help() {
    print -r -- "notes — ${NOTES:-$HOME/notes}

  notes                 cd into the vault + open the running todo, file tree open
  notes index           the vault map
  notes <words>         fuzzy-pick a note, seeded with <words>
  notes cd              cd into the vault, no editor
  notes today|d         today's daily note      (also: yesterday|y, tomorrow|t)
  notes dailies         browse past daily notes
  notes new <title>     create a note and open it
  notes find|f          fuzzy-pick a note
  notes grep|g <pat>    search note contents, open at the match
  notes tags            browse tags
  notes sync            git status of the vault (Syncthing moves the files)

Aliased to 'nn'."
}

notes() {
    emulate -L zsh
    local vault="${NOTES:-$HOME/notes}"
    [[ -d $vault ]] || { print -ru2 -- "notes: no vault at $vault"; return 1 }

    local cmd=${1-}
    (( $# )) && shift

    case $cmd in
        ''|todo)           _notes_enter ;;
        index)             _notes_nvim index.md ;;
        cd)                cd -- "$vault" ;;   # a function, so this sticks
        d|today)           _notes_nvim +'Obsidian today' ;;
        y|yesterday)       _notes_nvim +'Obsidian yesterday' ;;
        t|tomorrow)        _notes_nvim +'Obsidian tomorrow' ;;
        dailies)           _notes_nvim +'Obsidian dailies' ;;
        tags)              _notes_nvim +'Obsidian tags' ;;
        new|n)
            (( $# )) || { print -ru2 -- "notes new <title>"; return 1 }
            _notes_nvim +"Obsidian new $*" ;;
        find|f)            _notes_pick "$@" ;;
        grep|g|search|s)
            (( $# )) || { print -ru2 -- "notes grep <pattern>"; return 1 }
            _notes_grep "$@" ;;
        sync)              git -C "$vault" status --short --branch ;;
        help|h|-h|--help)  _notes_help ;;
        # Anything else is treated as a search query, so `notes docker` just works.
        *)                 _notes_pick "$cmd${*:+ $*}" ;;
    esac
}

alias nn='notes'

_notes() {
    local vault="${NOTES:-$HOME/notes}"
    (( CURRENT == 2 )) || return 0

    local -a subs=(
        'todo:cd in + open the running todo, file tree open'
        'index:the vault map'
        'cd:cd into the vault, no editor'
        'today:daily note for today'
        'yesterday:daily note for yesterday'
        'tomorrow:daily note for tomorrow'
        'dailies:browse past daily notes'
        'new:create a note (title follows)'
        'find:fuzzy-pick a note'
        'grep:search note contents'
        'tags:browse tags'
        'sync:git status of the vault'
        'help:usage'
    )
    _describe -t commands 'command' subs

    # A bare word is a search query, so offer note names alongside the verbs.
    local -a titles
    titles=( ${vault}/**/*.md(.omN:t:r) )
    (( $#titles )) && _describe -t notes 'note' titles
}
compdef _notes notes

# ------------------------------------------------------------------
# Alvar-method tutoring (learnsing)
#
# The teach/probe/learn-* skills persist to `.alvar/` *relative to Claude's
# cwd*, so launching from anywhere else scatters LEARNER.md, maps, and session
# logs outside the vault. Same cwd trap as Telescope above, different tool.
#
# Subshell, like _notes_nvim: quitting Claude leaves the caller where they
# started. Use `notes cd` when the point is to stay in the vault.
#
# Args pass through, so `learnsing /teach docker networking` works.
# ------------------------------------------------------------------
learnsing() {
    ( cd -- "${NOTES:-$HOME/notes}" && claude "$@" )
}

# ------------------------------------------------------------------
# Boards: `todo` opens the default board, `todo <name>` opens or creates one.
#
# A thin wrapper over `:Todo` in the Neovim config. The "unknown name means a
# new board" logic lives there rather than here, because tsk writes the file
# from its own template on first open -- so `todo garden` is how a board gets
# created, not something to set up first. Doing it in the shell would mean
# hand-rolling the frontmatter and the **Complete** marker and getting them
# subtly wrong.
#
# Subshell with the vault as cwd, like _notes_nvim and for the same two
# reasons: quitting the board leaves you where you started, and Telescope
# inside nvim searches the vault instead of wherever you happened to be.
#
# $TODO_BOARD is what a bare `todo` opens.
# ------------------------------------------------------------------
: "${TODO_BOARD:=work}"

todo() {
    ( cd -- "${NOTES:-$HOME/notes}" && nvim -c "Todo ${*:-$TODO_BOARD}" )
}

# Complete on the boards that exist. The glob qualifiers are (N) no error when
# nothing matches, (:t) tail, (:r) drop the extension -- so todo/work.md offers
# `work`. A name that does not exist is still valid input; it just makes a new
# board, so this completes rather than restricts.
_todo() {
    local -a boards
    boards=( "${NOTES:-$HOME/notes}"/todo/*.md(N:t:r) )
    (( $#boards )) && _describe -t boards 'board' boards
}
compdef _todo todo
