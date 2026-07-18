# CHROMA Shell

A sharp, kinetic Quickshell desktop for Hyprland. CHROMA uses solid dark surfaces, hard geometry, curated neon palettes, compact panels and contextual interactions instead of glassmorphism.

## Current baseline

- Compact centred media context with a real PipeWire/CAVA spectrum
- Compact Spotlight-style application launcher
- Expandable media drawer with MPRIS controls
- PipeWire, Wi-Fi, Bluetooth and session control centre
- Native system tray and notification history
- Notification toasts, urgency states and persistent Do Not Disturb
- Fourteen live-switching curated themes
- Volume, mute and brightness OSDs
- Multi-monitor targeting: shell UI on `DP-1`

## Controls

| Shortcut | Action |
|---|---|
| `Alt + Space` | Application launcher |
| `Super + I` | Control centre |
| `Super + N` | Notification history |
| `Super + Shift + T` | Theme panel |
| Media keys | Playback, volume and brightness |

The theme tile in the bar opens the palette panel. Right-clicking it cycles to the next theme.

## Runtime

```bash
~/.local/bin/chroma-shell restart
~/.local/bin/chroma-shell status
~/.local/bin/chroma-shell log
chroma-healthcheck
```

## Structure

```text
shell.qml
├── ChromaBar.qml
├── ChromaLauncher.qml
├── ContextDrawer.qml
├── ControlCentre.qml
├── NotificationCentre.qml
├── StateStore.qml
├── ThemePanel.qml
└── ChromaOsd.qml
```

Settings are persisted in Quickshell's CHROMA state directory. No generated store paths are committed.

## Development shell

```bash
nix develop
```

Then restart CHROMA after editing QML:

```bash
~/.local/bin/chroma-shell restart
```

## Audio spectrum

CHROMA consumes CAVA raw ASCII frames from PipeWire. The spectrum is audio-driven; when playback is silent, the bars settle to their baseline rather than running a synthetic animation.

## Theme library

CHROMA ships with fourteen live themes. The original Voltage, Toxic,
Ultraviolet, Solar Flare, Aqua Circuit, and Candy Static palettes are joined
by Catppuccin Mocha, Gruvbox Dark, Tokyo Night, Nord, Rosé Pine, Kanagawa,
Dracula, and Everforest Dark. A theme changes every CHROMA surface, border,
text role, state colour, and the real CAVA spectrum gradient together.

Open the selector with `Super+Shift+T`, or right-click the palette button to
cycle. The selected theme persists across shell restarts.
