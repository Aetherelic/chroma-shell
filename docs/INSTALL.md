# Installing CHROMA

CHROMA provides one Bash installer interface for existing Hyprland desktops on
NixOS, Arch-based systems, Fedora-based systems and Ubuntu-based systems.

## Recommended remote installation

Download and inspect the bootstrap before running it:

```bash
curl -fsSL \
  https://raw.githubusercontent.com/Aetherelic/chroma-shell/main/install.sh \
  -o /tmp/chroma-install

less /tmp/chroma-install
bash /tmp/chroma-install
```

The compact form is:

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/Aetherelic/chroma-shell/main/install.sh)
```

The bootstrap uses Git when available. For the official GitHub repository it
can fall back to a release/archive download, allowing the full installer to
open before Git has been installed.

## Local development installation

From a checked-out repository:

```bash
./install.sh --local --dry-run
./install.sh --local
```

The terminal menu displays the detected distribution, Hyprland session,
focused monitor, components, installed commands, packages that will be added,
optional tools and shortcut conflicts before installation starts.

## Distribution behaviour

- Arch-based systems use `pacman`.
- Fedora-based systems use `dnf`; the documented Quickshell COPR is enabled
  only when a suitable Quickshell package is unavailable.
- Ubuntu-based systems use `apt`; the documented DankLinux PPA is added only
  when Quickshell must be installed or upgraded.
- NixOS quick mode uses `nix profile` for user-level commands. It never edits
  `/etc/nixos` or a system flake.

On NixOS, NetworkManager, BlueZ and WirePlumber remain declarative system
services. The installer reports a missing service instead of pretending that a
user profile can enable it. A Nix package, NixOS module and Home Manager module
are maintained as a separate declarative installation layer.

## Managed paths

```text
${XDG_DATA_HOME:-~/.local/share}/chroma-shell/
~/.local/bin/chroma
~/.local/bin/chroma-wallpaper
${XDG_CONFIG_HOME:-~/.config}/chroma/
${XDG_CONFIG_HOME:-~/.config}/hypr/conf.d/chroma.conf
${XDG_STATE_HOME:-~/.local/state}/chroma-shell/
${XDG_CACHE_HOME:-~/.cache}/chroma-shell/
```

One exact source line is added to the existing Hyprland configuration. With the
default XDG configuration directory it is:

```ini
source = ~/.config/hypr/conf.d/chroma.conf
```

CHROMA does not delete the rest of the Hyprland configuration or silently stop
another bar, notification daemon or shell.

## First run

When no CHROMA settings file exists, the installer creates a small initial
configuration using the focused monitor and detected terminal, browser, file
manager and editor. Existing settings are always preserved during installs,
repairs and updates.

The default shortcuts are:

```text
Alt + Space       Launcher
Super + I         Control centre
Super + N         Notifications
Super + Shift + T Themes
Super + Shift + V Clipboard
Super + Comma     Settings
```

Conflicting shortcuts are shown before installation. They are skipped by
default. Selecting replacement writes an `unbind` and CHROMA binding only in
the managed fragment; the original user configuration is left untouched and
returns when CHROMA is uninstalled.

## Commands

```bash
chroma status
chroma settings
chroma doctor
chroma install-plan
chroma update
chroma repair
chroma uninstall
chroma uninstall --purge
```

`chroma update` follows the repository branch or release tag recorded at
installation. `chroma uninstall` keeps settings, state and snapshots unless
`--purge` is explicitly supplied.

## Options

```text
--dry-run
--non-interactive
--no-packages
--optional
--no-start
--no-autostart
--no-bindings
--no-clipboard
--replace-bindings
```

## Safety and recovery

The installer validates its Bash scripts and JSON manifests, stages the source
before promotion and creates a timestamped manual backup before install,
repair and uninstall operations. It never performs automatic rollback.

```text
${XDG_STATE_HOME:-~/.local/state}/chroma-installer/install.log
${XDG_DATA_HOME:-~/.local/share}/chroma-installer/backups/
```
