#!/usr/bin/env bash

project="$HOME/Projects/chroma-shell"
state="$HOME/.local/state/chroma-shell"
config="$project/shell.qml"
pidfile="$state/preview.pid"
log="$state/preview.log"

mkdir -p "$state"

find_quickshell() {
    if command -v quickshell >/dev/null 2>&1; then
        command -v quickshell
        return 0
    fi

    running_pid="$(
        pgrep -o -f 'quickshell.*ambxst' 2>/dev/null
    )"

    if test -z "$running_pid"; then
        return 1
    fi

    wrapper="$(
        tr '\0' '\n' <"/proc/$running_pid/cmdline" 2>/dev/null |
            head -n 1
    )"

    if test -x "$wrapper" &&
       test "$(basename "$wrapper")" = "quickshell"; then
        printf '%s\n' "$wrapper"
        return 0
    fi

    wrapped="$(
        readlink -f "/proc/$running_pid/exe" 2>/dev/null
    )"

    candidate="${wrapped%/.quickshell-wrapped}/quickshell"

    if test -x "$candidate"; then
        printf '%s\n' "$candidate"
        return 0
    fi

    return 1
}

chroma_pids() {
    for cmdline in /proc/[0-9]*/cmdline; do
        test -r "$cmdline" || continue

        pid="${cmdline#/proc/}"
        pid="${pid%/cmdline}"

        test "$pid" = "$$" && continue

        command_line="$(
            tr '\0' ' ' <"$cmdline" 2>/dev/null
        )"

        case "$command_line" in
            *quickshell*"$config"*)
                printf '%s\n' "$pid"
                ;;
        esac
    done
}

stop_preview() {
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
    quickshell_bin="$(find_quickshell)"

    if test -z "$quickshell_bin" ||
       ! test -x "$quickshell_bin"; then
        printf '%s\n' \
            "Could not locate the wrapped Quickshell launcher." \
            >"$log"
        return 1
    fi

    {
        printf 'Using wrapper: %s\n\n' "$quickshell_bin"
    } >"$log"

    nohup "$quickshell_bin" \
        -p "$config" \
        >>"$log" 2>&1 &

    printf '%s\n' "$!" >"$pidfile"
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

    log)
        tail -n 180 "$log" 2>/dev/null
        ;;

    status)
        count="$(chroma_pids | wc -l)"
        printf 'CHROMA instances: %s\n' "$count"

        for pid in $(chroma_pids); do
            printf '  PID %s\n' "$pid"
        done
        ;;

    *)
        printf 'Usage: %s {start|stop|restart|log|status}\n' "$0"
        ;;
esac
