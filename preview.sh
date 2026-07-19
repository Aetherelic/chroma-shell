#!/usr/bin/env bash

set -u
set -o pipefail

project="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
home="${HOME:?HOME is not set}"
config_home="${XDG_CONFIG_HOME:-$home/.config}"
state="${XDG_STATE_HOME:-$home/.local/state}/chroma-shell"
config="$project/shell.qml"
pidfile="$state/chroma.pid"
log="$state/chroma.log"
install_conf="$config_home/chroma/install.conf"

mkdir -p "$state"

if test -f "$install_conf"; then
    # shellcheck disable=SC1090
    source "$install_conf"
fi

find_quickshell() {
    local candidate
    if test -n "${CHROMA_QUICKSHELL_BIN:-}" && test -x "$CHROMA_QUICKSHELL_BIN"; then
        printf '%s\n' "$CHROMA_QUICKSHELL_BIN"
        return
    fi
    for candidate in quickshell qs; do
        if command -v "$candidate" >/dev/null 2>&1; then
            command -v "$candidate"
            return
        fi
    done
    for candidate in \
        "$home/.nix-profile/bin/quickshell" \
        "/etc/profiles/per-user/${USER:-$(id -un)}/bin/quickshell" \
        /run/current-system/sw/bin/quickshell
    do
        test -x "$candidate" && { printf '%s\n' "$candidate"; return; }
    done
    return 1
}

chroma_pids() {
    local cmdline pid command_line
    for cmdline in /proc/[0-9]*/cmdline; do
        test -r "$cmdline" || continue
        pid="${cmdline#/proc/}"
        pid="${pid%/cmdline}"
        test "$pid" = "$$" && continue
        command_line="$(tr '\0' ' ' < "$cmdline" 2>/dev/null || true)"

        # First require the exact CHROMA config path, then recognise either
        # Quickshell binary name. This avoids matching unrelated shell sessions.
        case "$command_line" in
            *"$config"*) ;;
            *) continue ;;
        esac

        case " $command_line " in
            *quickshell*|*'/qs '*|*' qs '*) printf '%s\n' "$pid" ;;
        esac
    done
}

stop_chroma() {
    local pid
    for pid in $(chroma_pids); do
        kill "$pid" 2>/dev/null || true
    done
    sleep 0.4
    for pid in $(chroma_pids); do
        kill -9 "$pid" 2>/dev/null || true
    done
    rm -f "$pidfile"
}

start_chroma() {
    local quickshell_bin
    if test -n "$(chroma_pids)"; then
        printf 'CHROMA is already running.\n'
        return 0
    fi
    quickshell_bin="$(find_quickshell 2>/dev/null || true)"
    if test -z "$quickshell_bin" || ! test -x "$quickshell_bin"; then
        printf 'Could not locate Quickshell.\n' | tee "$log" >&2
        return 1
    fi
    {
        printf 'CHROMA root: %s\n' "$project"
        printf 'Quickshell: %s\n\n' "$quickshell_bin"
    } > "$log"
    nohup "$quickshell_bin" -p "$config" >> "$log" 2>&1 &
    printf '%s\n' "$!" > "$pidfile"
}

case "${1:-restart}" in
    start) start_chroma ;;
    stop) stop_chroma ;;
    restart) stop_chroma; start_chroma ;;
    log)
        if test "${2:-}" = '--follow'; then
            touch "$log"
            tail -n 180 -f "$log"
        else
            tail -n 180 "$log" 2>/dev/null || true
        fi
        ;;
    status)
        count="$(chroma_pids | sed '/^$/d' | wc -l)"
        printf 'CHROMA instances: %s\n' "$count"
        for pid in $(chroma_pids); do printf '  PID %s\n' "$pid"; done
        ;;
    *) printf 'Usage: %s {start|stop|restart|log [--follow]|status}\n' "$0" >&2; exit 2 ;;
esac
