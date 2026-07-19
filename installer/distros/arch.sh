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
    'bluez-utils:bluetoothctl'
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
    return 0
}

distro::install() {
    test $# -gt 0 || return 0
    packages::run sudo pacman -S --needed --noconfirm "$@"
}
