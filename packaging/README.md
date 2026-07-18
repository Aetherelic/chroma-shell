# Installer contract

The future CHROMA installer should be a thin orchestration layer around these files.
It should not patch QML source per distribution.

## Stable locations

- Shell source: `${XDG_DATA_HOME:-$HOME/.local/share}/chroma-shell`
- CLI: `$HOME/.local/bin/chroma`
- User settings: `${XDG_CONFIG_HOME:-$HOME/.config}/chroma/settings.json`
- Runtime state: `${XDG_STATE_HOME:-$HOME/.local/state}/chroma-shell`
- Cache: `${XDG_CACHE_HOME:-$HOME/.cache}/chroma-shell`
- Managed data and recovery: `${XDG_DATA_HOME:-$HOME/.local/share}/chroma-settings`

## Distribution adapters

NixOS, Arch, Fedora and Ubuntu adapters should only resolve package names and the
Quickshell installation method. Runtime files, commands, settings and Hyprland
integration must remain identical.

Optional capabilities must be detected with `chroma doctor`; missing optional tools
must disable only the related feature.
