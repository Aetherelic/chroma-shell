#!/usr/bin/env bash

set -Eeuo pipefail

root="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../.." && pwd -P)"
temporary="$(mktemp -d -t chroma-installer-test.XXXXXX)"
cleanup() { rm -rf -- "$temporary"; }
trap cleanup EXIT

mock_bin="$temporary/bin"
host_path="${PATH:-}"
true_bin="$(type -P true)"
mkdir -p "$mock_bin"

cat > "$mock_bin/quickshell" <<'MOCK'
#!/usr/bin/env bash
if test "${1:-}" = '--version'; then
    printf 'Quickshell 0.3.0\n'
    exit 0
fi
exit 0
MOCK

cat > "$mock_bin/hyprctl" <<'MOCK'
#!/usr/bin/env bash
if test "${1:-}" = monitors; then
    printf '[{"name":"DP-1","focused":true,"width":2560,"height":1440}]\n'
fi
exit 0
MOCK

cat > "$mock_bin/sudo" <<'MOCK'
#!/usr/bin/env bash
exec "$@"
MOCK

chmod +x "$mock_bin/quickshell" "$mock_bin/hyprctl" "$mock_bin/sudo"

commands=(
    git curl wl-copy wl-paste cliphist cava brightnessctl nmcli
    bluetoothctl wpctl notify-send grim slurp playerctl swappy
    wf-recorder qalc swww pacman dnf apt-get add-apt-repository nix
)
for command in "${commands[@]}"; do
    test -e "$mock_bin/$command" || ln -s "$true_bin" "$mock_bin/$command"
done

for distro in arch fedora ubuntu nixos; do
    home="$temporary/home-$distro"
    mkdir -p "$home/.config/hypr"
    : > "$home/.config/hypr/hyprland.conf"
    HOME="$home" \
    XDG_CONFIG_HOME="$home/.config" \
    XDG_DATA_HOME="$home/.local/share" \
    XDG_STATE_HOME="$home/.local/state" \
    XDG_CACHE_HOME="$home/.cache" \
    XDG_CURRENT_DESKTOP=Hyprland \
    CHROMA_TEST_DISTRO="$distro" \
    CHROMA_TEST_MODE=1 \
    CHROMA_DISABLE_TEE=1 \
    PATH="$mock_bin:$host_path" \
        "$root/installer/chroma-installer" \
            --source "$root" \
            --action plan \
            --non-interactive \
            --dry-run \
            --no-packages \
            > "$temporary/plan-$distro.log"
    grep -Fq '██████╗██╗' "$temporary/plan-$distro.log"
    grep -Fq 'DEPENDENCIES' "$temporary/plan-$distro.log"
done

home="$temporary/home-install"
mkdir -p "$home/.config/hypr"
: > "$home/.config/hypr/hyprland.conf"

HOME="$home" \
XDG_CONFIG_HOME="$home/.config" \
XDG_DATA_HOME="$home/.local/share" \
XDG_STATE_HOME="$home/.local/state" \
XDG_CACHE_HOME="$home/.cache" \
XDG_CURRENT_DESKTOP=Hyprland \
CHROMA_TEST_DISTRO=arch \
CHROMA_TEST_MODE=1 \
CHROMA_DISABLE_TEE=1 \
PATH="$mock_bin:$host_path" \
    "$root/installer/chroma-installer" \
        --source "$root" \
        --action install \
        --non-interactive \
        --no-packages \
        --no-start \
        > "$temporary/install.log"

test -f "$home/.local/share/chroma-shell/shell.qml"
test -x "$home/.local/bin/chroma"
test -f "$home/.config/chroma/install.conf"
test -f "$home/.config/hypr/conf.d/chroma.conf"
grep -Fq 'source = ~/.config/hypr/conf.d/chroma.conf' "$home/.config/hypr/hyprland.conf"
grep -Fq 'SUPER SHIFT, V' "$home/.config/hypr/conf.d/chroma.conf"
test -f "$home/.config/chroma/settings.json"
jq -e '.version == 6 and .layout.barMonitor == "DP-1"'     "$home/.config/chroma/settings.json" >/dev/null

HOME="$home" \
XDG_CONFIG_HOME="$home/.config" \
XDG_DATA_HOME="$home/.local/share" \
XDG_STATE_HOME="$home/.local/state" \
XDG_CACHE_HOME="$home/.cache" \
XDG_CURRENT_DESKTOP=Hyprland \
CHROMA_TEST_DISTRO=arch \
CHROMA_TEST_MODE=1 \
CHROMA_DISABLE_TEE=1 \
PATH="$mock_bin:$host_path" \
    "$home/.local/share/chroma-shell/installer/chroma-installer" \
        --source "$home/.local/share/chroma-shell" \
        --action uninstall \
        --non-interactive \
        --purge \
        > "$temporary/uninstall.log"

test ! -e "$home/.local/share/chroma-shell"
test ! -e "$home/.local/bin/chroma"
test ! -e "$home/.config/hypr/conf.d/chroma.conf"
! grep -Fq 'source = ~/.config/hypr/conf.d/chroma.conf' "$home/.config/hypr/hyprland.conf"
! grep -Fq '# CHROMA shell' "$home/.config/hypr/hyprland.conf"

# A requested shortcut replacement is isolated inside CHROMA's fragment. The
# user's original binding is left untouched and returns after uninstall.
conflict_home="$temporary/home-conflict"
mkdir -p "$conflict_home/.config/hypr"
printf 'bind = SUPER SHIFT, V, togglefloating\n'     > "$conflict_home/.config/hypr/hyprland.conf"

HOME="$conflict_home" XDG_CONFIG_HOME="$conflict_home/.config" XDG_DATA_HOME="$conflict_home/.local/share" XDG_STATE_HOME="$conflict_home/.local/state" XDG_CACHE_HOME="$conflict_home/.cache" XDG_CURRENT_DESKTOP=Hyprland CHROMA_TEST_DISTRO=arch CHROMA_TEST_MODE=1 CHROMA_DISABLE_TEE=1 PATH="$mock_bin:$host_path"     "$root/installer/chroma-installer"         --source "$root"         --action install         --non-interactive         --no-packages         --no-start         --replace-bindings         > "$temporary/install-conflict.log"

grep -Fq 'unbind = SUPER SHIFT, V'     "$conflict_home/.config/hypr/conf.d/chroma.conf"
grep -Fq 'bind = SUPER SHIFT, V, exec,'     "$conflict_home/.config/hypr/conf.d/chroma.conf"
grep -Fq 'bind = SUPER SHIFT, V, togglefloating'     "$conflict_home/.config/hypr/hyprland.conf"

HOME="$conflict_home" XDG_CONFIG_HOME="$conflict_home/.config" XDG_DATA_HOME="$conflict_home/.local/share" XDG_STATE_HOME="$conflict_home/.local/state" XDG_CACHE_HOME="$conflict_home/.cache" XDG_CURRENT_DESKTOP=Hyprland CHROMA_TEST_DISTRO=arch CHROMA_TEST_MODE=1 CHROMA_DISABLE_TEE=1 PATH="$mock_bin:$host_path"     "$conflict_home/.local/share/chroma-shell/installer/chroma-installer"         --source "$conflict_home/.local/share/chroma-shell"         --action uninstall         --non-interactive         > "$temporary/uninstall-conflict.log"

grep -Fq 'bind = SUPER SHIFT, V, togglefloating'     "$conflict_home/.config/hypr/hyprland.conf"
! grep -Fq '# CHROMA shell' "$conflict_home/.config/hypr/hyprland.conf"

printf 'CHROMA installer smoke tests passed.\n'
