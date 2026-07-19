#!/usr/bin/env bash

MISSING_REQUIRED_PACKAGES=()
MISSING_OPTIONAL_PACKAGES=()
MISSING_REQUIRED_LABELS=()
MISSING_OPTIONAL_LABELS=()
CHROMA_NEEDS_QUICKSHELL_REPO=0

packages::command_available() {
    local alternatives="$1" command
    IFS='|' read -r -a command_list <<<"$alternatives"
    for command in "${command_list[@]}"; do
        if command -v "$command" >/dev/null 2>&1; then
            return 0
        fi
    done
    return 1
}

packages::append_unique() {
    local array_name="$1" value="$2" current
    local -n target="$array_name"
    for current in "${target[@]:-}"; do
        test "$current" = "$value" && return 0
    done
    target+=("$value")
}

packages::load_adapter() {
    local root="$1"
    local adapter="$root/installer/distros/$CHROMA_DISTRO.sh"
    test -f "$adapter" || {
        ui::error "No package adapter exists for $CHROMA_DISTRO."
        return 1
    }
    # shellcheck disable=SC1090
    source "$adapter"
}

packages::scan_specs() {
    local kind="$1"
    shift
    local spec package commands label current_version minimum='0.3.0'

    for spec in "$@"; do
        package="${spec%%:*}"
        commands="${spec#*:}"
        label="$package"

        if test "${CHROMA_ENABLE_CLIPBOARD:-1}" -ne 1; then
            case "$package" in
                wl-clipboard|cliphist)
                    ui::status skip "$label" 'clipboard disabled'
                    continue
                    ;;
            esac
        fi

        if test "$CHROMA_DISTRO" = nixos; then
            case "$package" in
                networkmanager|bluez|wireplumber)
                    if packages::command_available "$commands"; then
                        ui::status ok "$label" 'service command available'
                    else
                        ui::status warn "$label" 'enable declaratively in NixOS'
                    fi
                    continue
                    ;;
            esac
        fi

        if test "$package" = quickshell; then
            current_version="$(system::quickshell_version 2>/dev/null || true)"
            if test -n "$current_version" && system::version_ge "$current_version" "$minimum"; then
                ui::status ok "$label" "$current_version"
                continue
            fi
            CHROMA_NEEDS_QUICKSHELL_REPO=1
            if test -n "$current_version"; then
                ui::status install "$label" "$current_version → $minimum+"
            else
                ui::status install "$label" 'not installed'
            fi
        elif packages::command_available "$commands"; then
            ui::status ok "$label" 'installed'
            continue
        else
            if test "$kind" = required; then
                ui::status install "$label" 'will install'
            elif test "${CHROMA_INSTALL_OPTIONAL:-0}" -eq 1; then
                ui::status install "$label" 'selected for install'
            else
                ui::status optional "$label" 'optional'
            fi
        fi

        if test "$kind" = required; then
            packages::append_unique MISSING_REQUIRED_PACKAGES "$package"
            MISSING_REQUIRED_LABELS+=("$label")
        else
            packages::append_unique MISSING_OPTIONAL_PACKAGES "$package"
            MISSING_OPTIONAL_LABELS+=("$label")
        fi
    done
}

packages::scan() {
    MISSING_REQUIRED_PACKAGES=()
    MISSING_OPTIONAL_PACKAGES=()
    MISSING_REQUIRED_LABELS=()
    MISSING_OPTIONAL_LABELS=()
    CHROMA_NEEDS_QUICKSHELL_REPO=0

    ui::section 'Dependencies'
    packages::scan_specs required "${DISTRO_REQUIRED_SPECS[@]}"
    packages::scan_specs optional "${DISTRO_OPTIONAL_SPECS[@]}"
    export CHROMA_NEEDS_QUICKSHELL_REPO
}

packages::run() {
    if test "${CHROMA_DRY_RUN:-0}" -eq 1; then
        printf '  %sDRY-RUN%s ' "$c_dim" "$c_reset"
        printf '%q ' "$@"
        printf '\n'
        return 0
    fi
    "$@"
}

packages::install_required() {
    if test "${CHROMA_SKIP_PACKAGES:-0}" -eq 1; then
        ui::warn 'Package installation was disabled; missing capabilities may remain.'
        return 0
    fi
    distro::prepare
    distro::install "${MISSING_REQUIRED_PACKAGES[@]}"
}

packages::install_optional() {
    if test "${CHROMA_INSTALL_OPTIONAL:-0}" -ne 1; then
        return 0
    fi
    test ${#MISSING_OPTIONAL_PACKAGES[@]} -gt 0 || return 0
    distro::install "${MISSING_OPTIONAL_PACKAGES[@]}"
}

packages::postcheck() {
    local missing=0 spec package commands version
    for spec in "${DISTRO_REQUIRED_SPECS[@]}"; do
        package="${spec%%:*}"
        commands="${spec#*:}"

        if test "${CHROMA_ENABLE_CLIPBOARD:-1}" -ne 1; then
            case "$package" in
                wl-clipboard|cliphist) continue ;;
            esac
        fi

        if test "$package" = quickshell; then
            version="$(system::quickshell_version 2>/dev/null || true)"
            if test -z "$version" || ! system::version_ge "$version" '0.3.0'; then
                ui::status error quickshell '0.3.0 or newer required'
                missing=1
            fi
        elif ! packages::command_available "$commands"; then
            case "$CHROMA_DISTRO:$package" in
                nixos:networkmanager|nixos:bluez|nixos:wireplumber)
                    ui::status warn "$package" 'enable declaratively in NixOS'
                    ;;
                *)
                    ui::status error "$package" 'command still missing'
                    missing=1
                    ;;
            esac
        fi
    done
    return "$missing"
}
