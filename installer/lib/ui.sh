#!/usr/bin/env bash

ui_tty=0
ui_width=72

ui::init() {
    if test -t 1 && test -z "${NO_COLOR:-}"; then
        ui_tty=1
        c_reset=$'\033[0m'
        c_bold=$'\033[1m'
        c_dim=$'\033[2m'
        c_cyan=$'\033[38;5;51m'
        c_pink=$'\033[38;5;213m'
        c_green=$'\033[38;5;84m'
        c_yellow=$'\033[38;5;220m'
        c_red=$'\033[38;5;203m'
        c_grey=$'\033[38;5;245m'
    else
        c_reset='' c_bold='' c_dim='' c_cyan='' c_pink=''
        c_green='' c_yellow='' c_red='' c_grey=''
    fi

    if command -v tput >/dev/null 2>&1; then
        columns="$(tput cols 2>/dev/null || printf '72')"
        if [[ "$columns" =~ ^[0-9]+$ ]] && test "$columns" -gt 48; then
            ui_width="$columns"
            test "$ui_width" -gt 92 && ui_width=92
        fi
    fi
    return 0
}

ui::clear() {
    if test "$ui_tty" -eq 1; then
        printf '\033[2J\033[H'
    fi
    return 0
}
ui::repeat() {
    local character="$1" count="$2" index
    for ((index = 0; index < count; index++)); do
        printf '%s' "$character"
    done
}

ui::line() {
    local character="${1:-─}"
    local count=$((ui_width - 2))
    printf '╰'
    ui::repeat "$character" "$count"
    printf '╯\n'
}

ui::header() {
    local accent="${c_cyan:-}"
    local reset="${c_reset:-}"
    local dim="${c_dim:-${c_muted:-}}"

    printf '\n%b' "$accent"

    cat <<'BANNER'
 ██████╗██╗  ██╗██████╗  ██████╗ ███╗   ███╗ █████╗
██╔════╝██║  ██║██╔══██╗██╔═══██╗████╗ ████║██╔══██╗
██║     ███████║██████╔╝██║   ██║██╔████╔██║███████║
██║     ██╔══██║██╔══██╗██║   ██║██║╚██╔╝██║██╔══██║
╚██████╗██║  ██║██║  ██║╚██████╔╝██║ ╚═╝ ██║██║  ██║
 ╚═════╝╚═╝  ╚═╝╚═╝  ╚═╝ ╚═════╝ ╚═╝     ╚═╝╚═╝  ╚═╝
BANNER

    printf '%b' "$reset"
    printf '%b%s%b\n\n' \
        "$dim" \
        '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━' \
        "$reset"
}

ui::footer() {
    local inner=$((ui_width - 2))
    printf '%s╰' "$c_cyan"
    ui::repeat '─' "$inner"
    printf '╯%s\n' "$c_reset"
}

ui::section() {
    printf '\n%s%s%s\n' "$c_bold" "${1^^}" "$c_reset"
}

ui::kv() {
    local key="$1" value="$2"
    printf '  %s%-20s%s %s\n' "$c_grey" "$key" "$c_reset" "$value"
}

ui::status() {
    local state="$1" label="$2" detail="${3:-}"
    local glyph colour
    case "$state" in
        ok) glyph='●'; colour="$c_green" ;;
        install) glyph='→'; colour="$c_cyan" ;;
        optional) glyph='○'; colour="$c_pink" ;;
        skip) glyph='–'; colour="$c_grey" ;;
        warn) glyph='!'; colour="$c_yellow" ;;
        error) glyph='×'; colour="$c_red" ;;
        *) glyph='·'; colour="$c_grey" ;;
    esac
    printf '  %s%s%s %-24s %s%s%s\n' \
        "$colour" "$glyph" "$c_reset" "$label" "$c_dim" "$detail" "$c_reset"
}

ui::step() {
    local current="$1" total="$2" label="$3" state="${4:-RUNNING}"
    local colour="$c_cyan"
    case "$state" in
        DONE) colour="$c_green" ;;
        WARN) colour="$c_yellow" ;;
        FAILED) colour="$c_red" ;;
    esac
    printf '%s[%02d/%02d]%s %-46s %s%s%s\n' \
        "$c_dim" "$current" "$total" "$c_reset" "$label" "$colour" "$state" "$c_reset"
}

ui::note() {
    printf '  %s%s%s\n' "$c_dim" "$1" "$c_reset"
}

ui::warn() {
    printf '%sWARNING:%s %s\n' "$c_yellow" "$c_reset" "$1" >&2
}

ui::error() {
    printf '%sERROR:%s %s\n' "$c_red" "$c_reset" "$1" >&2
}

ui::success() {
    printf '%s%s%s\n' "$c_green" "$1" "$c_reset"
}

ui::confirm() {
    local prompt="$1" default="${2:-yes}" answer
    if test "${CHROMA_NON_INTERACTIVE:-0}" -eq 1; then
        test "$default" = yes
        return
    fi
    if test "$default" = yes; then
        read -r -p "$prompt [Y/n] " answer || return 1
        answer="${answer:-y}"
    else
        read -r -p "$prompt [y/N] " answer || return 1
        answer="${answer:-n}"
    fi
    [[ "$answer" =~ ^[Yy]$ ]]
}

ui::choice() {
    local prompt="$1" fallback="$2" answer
    if test "${CHROMA_NON_INTERACTIVE:-0}" -eq 1; then
        printf '%s\n' "$fallback"
        return
    fi
    read -r -p "$prompt " answer || answer=''
    printf '%s\n' "${answer:-$fallback}"
}
