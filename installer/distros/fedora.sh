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
    'NetworkManager:nmcli'
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
)

distro::prepare() {
    if test "${CHROMA_NEEDS_QUICKSHELL_REPO:-0}" -eq 1; then
        packages::run sudo dnf install -y dnf-plugins-core
        packages::run sudo dnf copr enable -y errornointernet/quickshell
    fi
}

distro::install() {
    test $# -gt 0 || return 0
    packages::run sudo dnf install -y "$@"
}
