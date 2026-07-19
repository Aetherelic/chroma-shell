#!/usr/bin/env bash

hypr::paths() {
    local config_home
    config_home="${XDG_CONFIG_HOME:-$HOME/.config}"
    CHROMA_HYPRLAND_CONFIG="$config_home/hypr/hyprland.conf"
    CHROMA_HYPRLAND_FRAGMENT="$config_home/hypr/conf.d/chroma.conf"
    if test "$config_home" = "$HOME/.config"; then
        CHROMA_HYPRLAND_SOURCE='source = ~/.config/hypr/conf.d/chroma.conf'
    else
        CHROMA_HYPRLAND_SOURCE="source = $CHROMA_HYPRLAND_FRAGMENT"
    fi
    export CHROMA_HYPRLAND_CONFIG CHROMA_HYPRLAND_FRAGMENT CHROMA_HYPRLAND_SOURCE
}

hypr::normalise_bind_line() {
    printf '%s' "$1" | tr -d '[:space:]' | tr '[:lower:]' '[:upper:]'
}

hypr::find_binding_conflict() {
    local modifiers="$1" key="$2" file line normalised wanted_mods wanted_key
    wanted_mods="$(printf '%s' "$modifiers" | tr -d '[:space:]' | tr '[:lower:]' '[:upper:]')"
    wanted_key="$(printf '%s' "$key" | tr -d '[:space:]' | tr '[:lower:]' '[:upper:]')"

    while IFS= read -r -d '' file; do
        while IFS= read -r line; do
            case "$line" in
                *chroma*) continue ;;
            esac
            normalised="$(hypr::normalise_bind_line "$line")"
            case "$normalised" in
                BIND*=*"$wanted_mods,$wanted_key,"*)
                    printf '%s:%s\n' "$file" "$line"
                    return 0
                    ;;
            esac
        done < "$file"
    done < <(
        find "$(dirname -- "$CHROMA_HYPRLAND_CONFIG")" \
            -type f \
            \( -name '*.conf' -o -name 'hyprland.conf' \) \
            ! -name 'chroma.conf' \
            ! -name '*.bak' \
            ! -name '*.bak.*' \
            ! -name '*.backup*' \
            -print0 2>/dev/null
    )
    return 1
}

hypr::emit_binding() {
    local modifiers="$1" key="$2" command="$3" conflict
    conflict="$(hypr::find_binding_conflict "$modifiers" "$key" 2>/dev/null || true)"

    if test -n "$conflict"; then
        if test "${CHROMA_REPLACE_BINDINGS:-0}" -ne 1; then
            printf '# Skipped conflicting binding: %s + %s\n' "$modifiers" "$key"
            printf '# Existing: %s\n' "$conflict"
            CHROMA_SKIPPED_BINDINGS+=("$modifiers + $key")
            return 0
        fi

        # Override without editing the user's original configuration. Removing
        # CHROMA restores the original binding automatically.
        printf 'unbind = %s, %s\n' "$modifiers" "$key"
    fi

    printf 'bind = %s, %s, exec, %s\n' "$modifiers" "$key" "$command"
}

hypr::write_fragment() {
    hypr::paths
    local temporary cli cli_quoted
    cli="$CHROMA_CLI_PATH"
    cli_quoted="$(printf '%q' "$cli")"
    CHROMA_SKIPPED_BINDINGS=()

    if test "${CHROMA_DRY_RUN:-0}" -eq 1; then
        printf '  Would write %s\n' "$CHROMA_HYPRLAND_FRAGMENT"
        return 0
    fi

    mkdir -p "$(dirname -- "$CHROMA_HYPRLAND_FRAGMENT")"
    temporary="$(mktemp "${CHROMA_HYPRLAND_FRAGMENT}.tmp.XXXXXX")"
    {
        printf '# CHROMA managed Hyprland integration\n'
        printf '# Generated %s\n\n' "$(date --iso-8601=seconds 2>/dev/null || date)"

        if test "${CHROMA_ENABLE_AUTOSTART:-1}" -eq 1; then
            printf 'exec-once = %s start\n' "$cli_quoted"
        fi

        if test "${CHROMA_ENABLE_BINDINGS:-1}" -eq 1; then
            printf '\n# CHROMA shortcuts\n'
            hypr::emit_binding 'ALT' 'SPACE' "$cli_quoted launcher"
            hypr::emit_binding 'SUPER' 'I' "$cli_quoted control"
            hypr::emit_binding 'SUPER' 'N' "$cli_quoted notifications"
            hypr::emit_binding 'SUPER SHIFT' 'T' "$cli_quoted themes"
            hypr::emit_binding 'SUPER SHIFT' 'V' "$cli_quoted clipboard"
            hypr::emit_binding 'SUPER' 'COMMA' "$cli_quoted settings"
        fi
    } > "$temporary"
    chmod 0644 "$temporary"
    mv -- "$temporary" "$CHROMA_HYPRLAND_FRAGMENT"
}

hypr::ensure_source() {
    hypr::paths
    if test "${CHROMA_DRY_RUN:-0}" -eq 1; then
        printf '  Would source %s from %s\n' "$CHROMA_HYPRLAND_FRAGMENT" "$CHROMA_HYPRLAND_CONFIG"
        return 0
    fi

    test -f "$CHROMA_HYPRLAND_CONFIG" || {
        ui::error "Hyprland configuration was not found at $CHROMA_HYPRLAND_CONFIG"
        return 1
    }

    if ! grep -Fqx "$CHROMA_HYPRLAND_SOURCE" "$CHROMA_HYPRLAND_CONFIG" 2>/dev/null; then
        printf '\n# CHROMA shell\n%s\n' "$CHROMA_HYPRLAND_SOURCE" >> "$CHROMA_HYPRLAND_CONFIG"
    fi
}

hypr::reload() {
    if test "${CHROMA_DRY_RUN:-0}" -eq 1; then
        printf '  Would reload Hyprland\n'
        return 0
    fi
    command -v hyprctl >/dev/null 2>&1 || return 0
    hyprctl reload >/dev/null 2>&1 || ui::warn 'Hyprland could not be reloaded automatically.'
}

hypr::remove() {
    hypr::paths
    if test "${CHROMA_DRY_RUN:-0}" -eq 1; then
        printf '  Would remove CHROMA Hyprland integration\n'
        return 0
    fi

    rm -f -- "$CHROMA_HYPRLAND_FRAGMENT"
    if test -f "$CHROMA_HYPRLAND_CONFIG"; then
        local temporary
        temporary="$(mktemp "${CHROMA_HYPRLAND_CONFIG}.tmp.XXXXXX")"
        awk -v source="$CHROMA_HYPRLAND_SOURCE" '
            $0 == source { next }
            $0 == "# CHROMA shell" { next }
            { print }
        ' "$CHROMA_HYPRLAND_CONFIG" > "$temporary"
        mv -- "$temporary" "$CHROMA_HYPRLAND_CONFIG"
    fi
}
