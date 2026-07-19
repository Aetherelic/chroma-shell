#!/usr/bin/env bash

deploy::paths() {
    local config_home data_home state_home cache_home
    config_home="${XDG_CONFIG_HOME:-$HOME/.config}"
    data_home="${XDG_DATA_HOME:-$HOME/.local/share}"
    state_home="${XDG_STATE_HOME:-$HOME/.local/state}"
    cache_home="${XDG_CACHE_HOME:-$HOME/.cache}"

    CHROMA_INSTALL_ROOT="$data_home/chroma-shell"
    CHROMA_CLI_PATH="$HOME/.local/bin/chroma"
    CHROMA_INSTALL_CONF="$config_home/chroma/install.conf"
    CHROMA_STATE_ROOT="$state_home/chroma-shell"
    CHROMA_CACHE_ROOT="$cache_home/chroma-shell"
    CHROMA_SETTINGS_ROOT="$config_home/chroma"
    CHROMA_METADATA="$data_home/chroma-installer/installed.json"
    CHROMA_WALLPAPER_TARGET="$HOME/Pictures/Wallpapers/CHROMA"

    export CHROMA_INSTALL_ROOT CHROMA_CLI_PATH CHROMA_INSTALL_CONF \
        CHROMA_STATE_ROOT CHROMA_CACHE_ROOT CHROMA_SETTINGS_ROOT CHROMA_METADATA \
        CHROMA_WALLPAPER_TARGET
}

deploy::validate_source() {
    local source="$1" required
    for required in \
        shell.qml \
        preview.sh \
        bin/chroma \
        bin/chroma-wallpaper \
        installer/chroma-installer \
        installer/manifests/dependencies.json \
        assets/branding/chroma-logo.svg \
        assets/wallpapers/voltage-bloom.webp \
        VERSION
    do
        test -f "$source/$required" || {
            ui::error "Source tree is missing $required."
            return 1
        }
    done

    bash -n "$source/preview.sh"
    bash -n "$source/bin/chroma"

    if test -f "$source/packaging/layout.json" && command -v jq >/dev/null 2>&1; then
        jq -e . "$source/packaging/layout.json" >/dev/null
    fi
    if test -f "$source/packaging/capabilities.json" && command -v jq >/dev/null 2>&1; then
        jq -e . "$source/packaging/capabilities.json" >/dev/null
    fi
}

deploy::copy_source() {
    local source="$1" stage="$2"
    mkdir -p "$stage"
    tar \
        --exclude='.git' \
        --exclude='.direnv' \
        --exclude='result' \
        --exclude='result-*' \
        --exclude='backups' \
        --exclude='*.bak' \
        --exclude='*.bak.*' \
        -C "$source" -cf - . \
        | tar -C "$stage" -xf -
}

deploy::install_wallpapers() {
    local source="$1" wallpaper target copied=0

    test -d "$source/assets/wallpapers" || return 0

    if test "${CHROMA_DRY_RUN:-0}" -eq 1; then
        printf '  Wallpaper target: %s\n' "$CHROMA_WALLPAPER_TARGET"
        return 0
    fi

    mkdir -p "$CHROMA_WALLPAPER_TARGET"

    while IFS= read -r -d '' wallpaper; do
        target="$CHROMA_WALLPAPER_TARGET/$(basename -- "$wallpaper")"
        if ! test -e "$target"; then
            install -m0644 "$wallpaper" "$target"
            copied=$((copied + 1))
        fi
    done < <(
        find "$source/assets/wallpapers" \
            -maxdepth 1 \
            -type f \
            \( -iname '*.png' -o -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.webp' \) \
            -print0
    )

    ui::status ok 'Bundled wallpapers' "$copied copied"
}

deploy::install() {
    deploy::paths
    local source="$1" parent stage old
    parent="$(dirname -- "$CHROMA_INSTALL_ROOT")"

    if test "${CHROMA_DRY_RUN:-0}" -eq 1; then
        printf '  Deploy source: %s\n' "$source"
        printf '  Install root: %s\n' "$CHROMA_INSTALL_ROOT"
        printf '  CLI:          %s\n' "$CHROMA_CLI_PATH"
        printf '  Wallpapers:   %s\n' "$CHROMA_WALLPAPER_TARGET"
        return 0
    fi

    mkdir -p "$parent" "$HOME/.local/bin" "$CHROMA_SETTINGS_ROOT" \
        "$CHROMA_STATE_ROOT" "$CHROMA_CACHE_ROOT" "$(dirname -- "$CHROMA_METADATA")"

    stage="$(mktemp -d "$parent/.chroma-shell.stage.XXXXXX")"
    deploy::copy_source "$source" "$stage"
    deploy::validate_source "$stage"

    chmod +x "$stage/preview.sh" "$stage/bin/chroma" 2>/dev/null || true
    find "$stage/backend" "$stage/tools" "$stage/installer" \
        -maxdepth 2 -type f \
        \( -name '*.sh' -o -name '*ctl' -o -name 'chroma-doctor' -o -name 'chroma-installer' \) \
        -exec chmod +x {} + 2>/dev/null || true

    old=''
    if test -e "$CHROMA_INSTALL_ROOT"; then
        old="$parent/.chroma-shell.previous.$(date +%s)"
        mv -- "$CHROMA_INSTALL_ROOT" "$old"
    fi

    mv -- "$stage" "$CHROMA_INSTALL_ROOT"
    rm -rf -- "$old"

    install -Dm755 "$CHROMA_INSTALL_ROOT/bin/chroma" "$CHROMA_CLI_PATH"
    if test -f "$CHROMA_INSTALL_ROOT/bin/chroma-wallpaper"; then
        install -Dm755 "$CHROMA_INSTALL_ROOT/bin/chroma-wallpaper" "$HOME/.local/bin/chroma-wallpaper"
    fi
    deploy::write_install_conf
    deploy::seed_settings
    deploy::install_wallpapers "$CHROMA_INSTALL_ROOT"
    deploy::write_metadata
}

deploy::write_install_conf() {
    local temporary quickshell_bin
    quickshell_bin="$(system::quickshell_binary 2>/dev/null || true)"
    mkdir -p "$(dirname -- "$CHROMA_INSTALL_CONF")"
    temporary="$(mktemp "${CHROMA_INSTALL_CONF}.tmp.XXXXXX")"
    {
        printf 'CHROMA_ROOT=%q\n' "$CHROMA_INSTALL_ROOT"
        printf 'CHROMA_REPO_URL=%q\n' "${CHROMA_REPO_URL:-https://github.com/Aetherelic/chroma-shell.git}"
        printf 'CHROMA_REF=%q\n' "${CHROMA_REF:-main}"
        printf 'CHROMA_CHANNEL=%q\n' "${CHROMA_CHANNEL:-development}"
        printf 'CHROMA_QUICKSHELL_BIN=%q\n' "$quickshell_bin"
    } > "$temporary"
    chmod 0600 "$temporary"
    mv -- "$temporary" "$CHROMA_INSTALL_CONF"
}

deploy::first_available_command() {
    local candidate
    for candidate in "$@"; do
        if command -v "$candidate" >/dev/null 2>&1; then
            printf '%s\n' "$candidate"
            return 0
        fi
    done
    return 1
}

deploy::seed_settings() {
    local settings_file monitor terminal browser files editor temporary
    settings_file="$CHROMA_SETTINGS_ROOT/settings.json"

    if test -f "$settings_file"; then
        ui::status ok 'Existing settings' 'preserved'
        return 0
    fi

    monitor="$(system::focused_monitor 2>/dev/null || true)"
    monitor="${monitor:-AUTO}"
    terminal="$(deploy::first_available_command kitty foot alacritty wezterm ghostty xterm 2>/dev/null || printf 'kitty')"
    browser="$(deploy::first_available_command chromium google-chrome-stable brave firefox 2>/dev/null || printf 'chromium')"
    files="$(deploy::first_available_command thunar dolphin nautilus nemo pcmanfm 2>/dev/null || printf 'thunar')"
    editor="$(deploy::first_available_command code codium kate gnome-text-editor nvim nano 2>/dev/null || printf 'code')"

    if test "${CHROMA_DRY_RUN:-0}" -eq 1; then
        printf '  Would create first-run settings for monitor %s\n' "$monitor"
        return 0
    fi

    mkdir -p "$(dirname -- "$settings_file")"
    temporary="$(mktemp "${settings_file}.tmp.XXXXXX")"
    jq -n \
        --arg monitor "$monitor" \
        --arg terminal "$terminal" \
        --arg browser "$browser" \
        --arg files "$files" \
        --arg editor "$editor" \
        '{version:6,layout:{barMonitor:$monitor},applications:{terminal:$terminal,browser:$browser,files:$files,editor:$editor}}' \
        > "$temporary"
    chmod 0600 "$temporary"
    mv -- "$temporary" "$settings_file"
    ui::status ok 'First-run settings' "monitor: $monitor"
}

deploy::write_metadata() {
    local version temporary
    version="$(cat "$CHROMA_INSTALL_ROOT/VERSION" 2>/dev/null || printf 'development')"
    temporary="$(mktemp "${CHROMA_METADATA}.tmp.XXXXXX")"
    jq -n \
        --arg version "$version" \
        --arg installedAt "$(date --iso-8601=seconds 2>/dev/null || date)" \
        --arg distro "$CHROMA_DISTRO" \
        --arg distroName "$CHROMA_DISTRO_NAME" \
        --arg architecture "$CHROMA_ARCH" \
        --arg repository "${CHROMA_REPO_URL:-}" \
        --arg ref "${CHROMA_REF:-main}" \
        --arg root "$CHROMA_INSTALL_ROOT" \
        '{schema:1,version:$version,installedAt:$installedAt,distro:$distro,distroName:$distroName,architecture:$architecture,repository:$repository,ref:$ref,root:$root}' \
        > "$temporary"
    mv -- "$temporary" "$CHROMA_METADATA"
}

deploy::remove() {
    deploy::paths
    if test "${CHROMA_DRY_RUN:-0}" -eq 1; then
        printf '  Would remove %s\n' "$CHROMA_INSTALL_ROOT"
        printf '  Would remove %s\n' "$CHROMA_CLI_PATH"
        return 0
    fi
    rm -rf -- "$CHROMA_INSTALL_ROOT"
    rm -f -- "$CHROMA_CLI_PATH" "$HOME/.local/bin/chroma-wallpaper" "$CHROMA_INSTALL_CONF" "$CHROMA_METADATA"
}
