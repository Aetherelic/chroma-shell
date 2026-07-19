#!/usr/bin/env bash

backup::paths() {
    CHROMA_INSTALLER_DATA="${XDG_DATA_HOME:-$HOME/.local/share}/chroma-installer"
    CHROMA_BACKUP_ROOT="$CHROMA_INSTALLER_DATA/backups"
    mkdir -p "$CHROMA_BACKUP_ROOT"
    export CHROMA_INSTALLER_DATA CHROMA_BACKUP_ROOT
}

backup::create() {
    backup::paths
    local stamp target manifest
    stamp="$(date +%Y%m%d-%H%M%S)"
    target="$CHROMA_BACKUP_ROOT/$stamp"
    manifest="$target/manifest.txt"

    if test "${CHROMA_DRY_RUN:-0}" -eq 1; then
        printf '  Backup would be created at %s\n' "$target"
        CHROMA_LAST_BACKUP="$target"
        export CHROMA_LAST_BACKUP
        return 0
    fi

    mkdir -p "$target"
    : > "$manifest"

    backup::copy_if_exists "${CHROMA_INSTALL_ROOT:-}" "$target/chroma-shell" "$manifest"
    backup::copy_if_exists "${CHROMA_CLI_PATH:-}" "$target/chroma" "$manifest"
    backup::copy_if_exists "${CHROMA_INSTALL_CONF:-}" "$target/install.conf" "$manifest"
    backup::copy_if_exists "${CHROMA_HYPRLAND_CONFIG:-}" "$target/hyprland.conf" "$manifest"
    backup::copy_if_exists "${CHROMA_HYPRLAND_FRAGMENT:-}" "$target/chroma.conf" "$manifest"

    printf 'created=%s\n' "$(date --iso-8601=seconds 2>/dev/null || date)" >> "$manifest"
    printf 'version=%s\n' "${CHROMA_SOURCE_VERSION:-unknown}" >> "$manifest"
    printf 'source=%s\n' "${CHROMA_SOURCE_ROOT:-unknown}" >> "$manifest"

    CHROMA_LAST_BACKUP="$target"
    export CHROMA_LAST_BACKUP
    printf '  Backup: %s\n' "$target"
}

backup::copy_if_exists() {
    local source="${1:-}" destination="$2" manifest="$3"
    test -n "$source" && test -e "$source" || return 0
    mkdir -p "$(dirname -- "$destination")"
    cp -a -- "$source" "$destination"
    printf '%s -> %s\n' "$source" "$destination" >> "$manifest"
}

backup::list() {
    backup::paths
    find "$CHROMA_BACKUP_ROOT" -mindepth 1 -maxdepth 1 -type d -printf '%f\n' 2>/dev/null | sort -r
}
