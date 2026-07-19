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
    'network-manager:nmcli'
    'bluez:bluetoothctl'
    'wireplumber:wpctl'
    'libnotify-bin:notify-send'
    'grim:grim'
    'slurp:slurp'
    'playerctl:playerctl'
)

DISTRO_OPTIONAL_SPECS=(
    'swappy:swappy'
    'wf-recorder:wf-recorder'
    'qalc:qalc'
)

distro::prepare() {
    if test "${CHROMA_NEEDS_QUICKSHELL_REPO:-0}" -eq 1; then
        packages::run sudo apt-get update
        packages::run sudo apt-get install -y software-properties-common
        packages::run sudo add-apt-repository -y ppa:avengemedia/danklinux
        packages::run sudo apt-get update
    fi
}

distro::install() {
    test $# -gt 0 || return 0
    packages::run sudo apt-get install -y "$@"
}
