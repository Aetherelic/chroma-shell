#!/usr/bin/env bash

validate::installed_files() {
    local missing=0 file
    for file in \
        "$CHROMA_INSTALL_ROOT/shell.qml" \
        "$CHROMA_INSTALL_ROOT/preview.sh" \
        "$CHROMA_INSTALL_ROOT/bin/chroma" \
        "$CHROMA_INSTALL_ROOT/VERSION" \
        "$CHROMA_CLI_PATH" \
        "$CHROMA_INSTALL_CONF"
    do
        if test -e "$file"; then
            ui::status ok "$(basename -- "$file")" "$file"
        else
            ui::status error "$(basename -- "$file")" 'missing'
            missing=1
        fi
    done
    return "$missing"
}

validate::shell_source() {
    local source="$1" script file

    for script in \
        "$source/install.sh" \
        "$source/preview.sh" \
        "$source/bin/chroma" \
        "$source/bin/chroma-wallpaper"
    do
        test -f "$script" || continue
        bash -n "$script"
    done

    while IFS= read -r -d '' script; do
        bash -n "$script"
    done < <(
        find "$source/installer" \
            -type f \
            \( -name '*.sh' -o -name 'chroma-installer' \) \
            -print0 2>/dev/null
    )

    if command -v jq >/dev/null 2>&1; then
        while IFS= read -r -d '' file; do
            jq -e . "$file" >/dev/null
        done < <(
            find "$source/installer/manifests" "$source/packaging" \
                -type f -name '*.json' -print0 2>/dev/null
        )
    fi
}

validate::doctor() {
    if test "${CHROMA_DRY_RUN:-0}" -eq 1; then
        printf '  Would run chroma doctor\n'
        return 0
    fi
    if "$CHROMA_CLI_PATH" doctor >/tmp/chroma-doctor.$$ 2>&1; then
        ui::status ok 'chroma doctor' 'passed'
        rm -f /tmp/chroma-doctor.$$
        return 0
    fi
    ui::status warn 'chroma doctor' 'reported missing optional capabilities'
    sed -n '1,120p' /tmp/chroma-doctor.$$ 2>/dev/null || true
    rm -f /tmp/chroma-doctor.$$
    return 0
}

validate::runtime() {
    if test "${CHROMA_START_NOW:-1}" -ne 1; then
        ui::status skip 'Runtime start' 'disabled'
        return 0
    fi
    if test "${CHROMA_DRY_RUN:-0}" -eq 1; then
        printf '  Would run %s start\n' "$CHROMA_CLI_PATH"
        return 0
    fi

    "$CHROMA_CLI_PATH" restart >/dev/null 2>&1 || {
        ui::status error 'CHROMA runtime' 'start command failed'
        return 1
    }
    sleep 3

    if "$CHROMA_CLI_PATH" status 2>/dev/null | grep -Eq 'CHROMA instances: [1-9]'; then
        ui::status ok 'CHROMA runtime' 'running'
        return 0
    fi

    ui::status error 'CHROMA runtime' 'no active instance detected'
    printf '\nRecent log output:\n'
    "$CHROMA_CLI_PATH" log 2>/dev/null | tail -n 60 || true
    return 1
}

validate::all() {
    local failed=0
    validate::installed_files || failed=1
    validate::doctor || true
    validate::runtime || failed=1
    return "$failed"
}
