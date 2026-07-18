#!/usr/bin/env bash

set -u
set -o pipefail

project="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
home="${HOME:?HOME is not set}"
state="${XDG_STATE_HOME:-$home/.local/state}/chroma-shell"
config="$project/shell.qml"
pidfile="$state/preview.pid"
log="$state/preview.log"

mkdir -p "$state"

find_quickshell() {
    local candidate running_pid wrapped

    if test -n "${CHROMA_QUICKSHELL_BIN:-}" && test -x "$CHROMA_QUICKSHELL_BIN"; then
        printf '%s\n' "$CHROMA_QUICKSHELL_BIN"
        return 0
    fi

    for candidate in quickshell qs; do
        if command -v "$candidate" >/dev/null 2>&1; then
            command -v "$candidate"
            return 0
        fi
    done

    for candidate in \
        "$home/.nix-profile/bin/quickshell" \
        "/etc/profiles/per-user/${USER:-$(id -un)}/bin/quickshell" \
        "/run/current-system/sw/bin/quickshell"
    do
        if test -x "$candidate"; then
            printf '%s\n' "$candidate"
            return 0
        fi
    done

    running_pid="$(pgrep -o -x quickshell 2>/dev/null || true)"
    if test -n "$running_pid"; then
        wrapped="$(readlink -f "/proc/$running_pid/exe" 2>/dev/null || true)"
        if test -x "$wrapped"; then
            printf '%s\n' "$wrapped"
            return 0
        fi
    fi

    return 1
}

chroma_pids() {
    local cmdline pid command_line

    for cmdline in /proc/[0-9]*/cmdline; do
        test -r "$cmdline" || continue
        pid="${cmdline#/proc/}"
        pid="${pid%/cmdline}"
        test "$pid" = "$$" && continue

        command_line="$(tr '\0' ' ' <"$cmdline" 2>/dev/null || true)"
        case "$command_line" in
            *quickshell*"$config"*) printf '%s\n' "$pid" ;;
        esac
    done
}

stop_preview() {
    local pid

    for pid in $(chroma_pids); do
        kill "$pid" 2>/dev/null || true
    done

    sleep 0.5

    for pid in $(chroma_pids); do
        kill -9 "$pid" 2>/dev/null || true
    done

    rm -f "$pidfile"
}

start_preview() {
    local quickshell_bin

    test -f "$config" || {
        printf 'Missing CHROMA entry point: %s\n' "$config" >&2
        return 1
    }

    quickshell_bin="$(find_quickshell 2>/dev/null || true)"
    if test -z "$quickshell_bin" || ! test -x "$quickshell_bin"; then
        printf 'Could not locate Quickshell. Run: chroma doctor\n' | tee "$log" >&2
        return 1
    fi

    {
        printf 'CHROMA root: %s\n' "$project"
        printf 'Quickshell: %s\n\n' "$quickshell_bin"
    } >"$log"

    nohup env \
        QS_NO_RELOAD_POPUP=1 \
        "$quickshell_bin" -p "$config" \
        >>"$log" 2>&1 &

    printf '%s\n' "$!" >"$pidfile"
}

status_preview() {
    local count pid
    count="$(chroma_pids | wc -l)"
    printf 'CHROMA instances: %s\n' "$count"
    for pid in $(chroma_pids); do
        printf '  PID %s\n' "$pid"
    done
    test "$count" -gt 0
}

case "${1:-restart}" in
    start)
        start_preview
        ;;
    stop)
        stop_preview
        ;;
    restart)
        stop_preview
        start_preview
        ;;
    foreground)
        quickshell_bin="$(find_quickshell)" || exit 1
        exec env QS_NO_RELOAD_POPUP=1 "$quickshell_bin" -p "$config"
        ;;
    log)
        if test "${2:-}" = "--follow"; then
            exec tail -n 180 -f "$log"
        fi
        tail -n 180 "$log" 2>/dev/null || true
        ;;
    status)
        status_preview
        ;;
    *)
        printf 'Usage: %s {start|stop|restart|foreground|log [--follow]|status}\n' "$0" >&2
        exit 2
        ;;
esac
