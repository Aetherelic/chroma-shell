#!/usr/bin/env bash

system::detect() {
    CHROMA_ARCH="$(uname -m)"
    CHROMA_DISTRO='unknown'
    CHROMA_DISTRO_NAME='Unknown Linux'
    CHROMA_DISTRO_VERSION='unknown'

    if test -n "${CHROMA_TEST_DISTRO:-}"; then
        CHROMA_DISTRO="$CHROMA_TEST_DISTRO"
        CHROMA_DISTRO_NAME="CHROMA test ${CHROMA_DISTRO}"
        CHROMA_DISTRO_VERSION='test'
    elif test -e /etc/NIXOS || grep -qi '^ID=nixos' /etc/os-release 2>/dev/null; then
        CHROMA_DISTRO='nixos'
    elif test -r /etc/os-release; then
        # shellcheck disable=SC1091
        . /etc/os-release
        CHROMA_DISTRO_VERSION="${VERSION_ID:-unknown}"
        CHROMA_DISTRO_NAME="${PRETTY_NAME:-${NAME:-Linux}}"
        case "${ID:-}" in
            arch|cachyos|endeavouros|manjaro) CHROMA_DISTRO='arch' ;;
            fedora|nobara) CHROMA_DISTRO='fedora' ;;
            ubuntu|pop|linuxmint) CHROMA_DISTRO='ubuntu' ;;
            nixos) CHROMA_DISTRO='nixos' ;;
            *)
                case " ${ID_LIKE:-} " in
                    *' arch '*) CHROMA_DISTRO='arch' ;;
                    *' fedora '*) CHROMA_DISTRO='fedora' ;;
                    *' ubuntu '*|*' debian '*) CHROMA_DISTRO='ubuntu' ;;
                esac
                ;;
        esac
    fi

    if test "$CHROMA_DISTRO" = nixos; then
        CHROMA_DISTRO_NAME="$(nixos-version 2>/dev/null || printf 'NixOS')"
        CHROMA_DISTRO_VERSION="${CHROMA_DISTRO_NAME#NixOS }"
    fi

    case "$CHROMA_DISTRO" in
        arch) CHROMA_PACKAGE_MANAGER='pacman' ;;
        fedora) CHROMA_PACKAGE_MANAGER='dnf' ;;
        ubuntu) CHROMA_PACKAGE_MANAGER='apt' ;;
        nixos) CHROMA_PACKAGE_MANAGER='nix profile' ;;
        *) CHROMA_PACKAGE_MANAGER='unsupported' ;;
    esac

    export CHROMA_ARCH CHROMA_DISTRO CHROMA_DISTRO_NAME \
        CHROMA_DISTRO_VERSION CHROMA_PACKAGE_MANAGER
}

system::require_user() {
    if test "${EUID:-$(id -u)}" -eq 0 && test "${CHROMA_TEST_MODE:-0}" -ne 1; then
        printf 'Run the CHROMA installer as your normal desktop user, not root.\n' >&2
        return 1
    fi
}

system::supported() {
    case "$CHROMA_DISTRO" in
        arch|fedora|ubuntu|nixos) return 0 ;;
        *) return 1 ;;
    esac
}

system::hyprland_available() {
    command -v hyprctl >/dev/null 2>&1 || test "${CHROMA_TEST_MODE:-0}" -eq 1
}

system::hyprland_session() {
    test -n "${HYPRLAND_INSTANCE_SIGNATURE:-}" || \
        test "${XDG_CURRENT_DESKTOP:-}" = Hyprland || \
        pgrep -x Hyprland >/dev/null 2>&1
}

system::focused_monitor() {
    if command -v hyprctl >/dev/null 2>&1 && command -v jq >/dev/null 2>&1; then
        hyprctl monitors -j 2>/dev/null \
            | jq -r '([.[] | select(.focused == true)][0].name // .[0].name // "")' \
            2>/dev/null || true
    fi
}

system::shell_conflicts() {
    local process cmdline pid command_line installed_config
    for process in waybar swaync swaync-client mako dunst ags astal-shell; do
        if pgrep -x "$process" >/dev/null 2>&1; then
            printf '%s\n' "$process"
        fi
    done

    installed_config="${CHROMA_INSTALL_ROOT:-}/shell.qml"
    for cmdline in /proc/[0-9]*/cmdline; do
        test -r "$cmdline" || continue
        pid="${cmdline#/proc/}"
        pid="${pid%/cmdline}"
        test "$pid" = "$$" && continue
        test "$pid" = "${PPID:-}" && continue
        command_line="$(tr '\0' ' ' < "$cmdline" 2>/dev/null || true)"

        case " $command_line " in
            *quickshell*|*'/qs '*|*' qs '*) ;;
            *) continue ;;
        esac

        if test -n "${CHROMA_INSTALL_ROOT:-}"; then
            case "$command_line" in
                *"$installed_config"*) continue ;;
            esac
        fi

        printf '%s\n' 'another Quickshell process'
        break
    done
}

system::version_ge() {
    local current="$1" minimum="$2"
    test "$(printf '%s\n%s\n' "$minimum" "$current" | sort -V | head -n1)" = "$minimum"
}

system::quickshell_binary() {
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
        "$HOME/.nix-profile/bin/quickshell" \
        "/etc/profiles/per-user/${USER:-$(id -un)}/bin/quickshell" \
        /run/current-system/sw/bin/quickshell
    do
        test -x "$candidate" && { printf '%s\n' "$candidate"; return; }
    done
    return 1
}

system::quickshell_version() {
    local binary version
    binary="$(system::quickshell_binary 2>/dev/null || true)"
    test -n "$binary" || return 1
    version="$($binary --version 2>/dev/null | grep -Eo '[0-9]+\.[0-9]+\.[0-9]+' | head -n1)"
    test -n "$version" || return 1
    printf '%s\n' "$version"
}
