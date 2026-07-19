#!/usr/bin/env bash

DISTRO_REQUIRED_SPECS=(
    'git:git'
    'curl:curl'
    'jq:jq'
    'quickshell:quickshell|qs'
    'wl-clipboard:wl-copy|wl-paste'
    'cliphist:cliphist'
    'cava:cava'
    'brightnessctl:brightnessctl'
    'networkmanager:nmcli'
    'bluez:bluetoothctl'
    'wireplumber:wpctl'
    'libnotify:notify-send'
    'grim:grim'
    'slurp:slurp'
    'playerctl:playerctl'
)

DISTRO_OPTIONAL_SPECS=(
    'swappy:swappy'
    'wf-recorder:wf-recorder'
    'libqalculate:qalc'
    'swww:swww'
)

distro::prepare() {
    command -v nix >/dev/null 2>&1 || {
        ui::error 'Nix is unavailable on this NixOS system.'
        return 1
    }
}

distro::install() {
    local package attrs=()
    test $# -gt 0 || return 0
    for package in "$@"; do
        case "$package" in
            networkmanager|bluez|wireplumber)
                # These are system services on NixOS; placing them in a user
                # profile does not enable the service. Doctor reports them.
                continue
                ;;
            *) attrs+=("nixpkgs#$package") ;;
        esac
    done
    test ${#attrs[@]} -gt 0 || return 0
    packages::run nix \
        --extra-experimental-features 'nix-command flakes' \
        profile install --accept-flake-config "${attrs[@]}"
}
