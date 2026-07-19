<div align="center">

<img width="100%" src="./assets/readme/chroma-logo.gif" alt="Animated CHROMA logo" />

<br />

<img src="https://img.shields.io/github/stars/Aetherelic/chroma-shell?style=for-the-badge&logo=github&color=ff4f79&labelColor=090b12" alt="GitHub stars" />
<img src="https://img.shields.io/github/forks/Aetherelic/chroma-shell?style=for-the-badge&logo=git&color=ff9f43&labelColor=090b12" alt="GitHub forks" />
<img src="https://img.shields.io/github/last-commit/Aetherelic/chroma-shell?style=for-the-badge&logo=git&color=45f0a8&labelColor=090b12" alt="Last commit" />
<img src="https://img.shields.io/github/license/Aetherelic/chroma-shell?style=for-the-badge&color=8f7cff&labelColor=090b12" alt="MIT License" />

<br />

<img src="https://img.shields.io/badge/Release-1.0.0--rc.1-db5cff?style=flat-square&labelColor=090b12" alt="Release" />
<img src="https://img.shields.io/badge/Hyprland-Shell-42c8ff?style=flat-square&labelColor=090b12" alt="Hyprland shell" />
<img src="https://img.shields.io/badge/Quickshell-QML-ffe66d?style=flat-square&labelColor=090b12" alt="Quickshell QML" />
<img src="https://img.shields.io/badge/Themes-25-45f0a8?style=flat-square&labelColor=090b12" alt="25 themes" />
<img src="https://img.shields.io/badge/Widgets-Desktop_Canvas-ff9f43?style=flat-square&labelColor=090b12" alt="Desktop widgets" />

<br /><br />

**A vibrant, modular desktop shell that turns Hyprland into a complete visual environment.**

Themes, widgets, settings, desktop tools and installation — designed as one coherent CHROMA system.

</div>

---

<div align="center">
<img width="100%" src="./assets/readme/chroma-showcase.gif" alt="CHROMA live showcase" />
</div>

## ✦ The shell at a glance

<table>
<tr>
<td width="50%"><b>Style Studio</b><br />Five geometry systems, coordinated Hyprland rounding, transparent or solid bars, live palettes and per-module control.</td>
<td width="50%"><b>Desktop Canvas</b><br />Draggable and resizable Music, CAVA, Clock and System widgets with per-monitor layouts.</td>
</tr>
<tr>
<td><b>System surfaces</b><br />Launcher, clipboard history, notifications, OSDs, theme browser, wallpaper selector and quick settings.</td>
<td><b>Real configuration</b><br />Display management, application defaults, autostart, diagnostics, snapshots and recovery.</td>
</tr>
</table>

## ✦ Settings suite

<div align="center">
<img width="100%" src="./assets/readme/chroma-settings-tour.gif" alt="Animated CHROMA settings tour" />
</div>

The settings application manages the shell without reducing it to a pile of text files: Wi‑Fi, Bluetooth, displays, desktop widgets, applications, recovery, themes, shell geometry and system information all share one visual language.

## ✦ System surfaces

<div align="center">
<img width="49%" src="./assets/readme/chroma-theme-browser.png" alt="CHROMA theme browser" />
<img width="49%" src="./assets/readme/chroma-control-centre.png" alt="CHROMA control centre" />
<br />
<img width="75%" src="./assets/readme/chroma-widget-canvas.png" alt="CHROMA desktop widget edit mode" />
</div>

## ✦ Theme engine

<div align="center">
<img width="100%" src="./assets/readme/chroma-theme-cycle.gif" alt="CHROMA live theme cycle" />
</div>

<details>
<summary><b>Open the complete 25-theme catalogue</b></summary>

<br />

<div align="center">
<img width="100%" src="./assets/readme/chroma-theme-catalogue.png" alt="All 25 CHROMA themes" />
</div>

<br />

| Family | Included palettes |
|---|---|
| **CHROMA Originals** | Voltage · Toxic · Ultraviolet · Solar Flare · Aqua Circuit · Candy Static |
| **Community Classics** | Catppuccin Mocha · Gruvbox Dark · Tokyo Night · Nord · Rosé Pine · Kanagawa · Dracula · Everforest Dark |
| **CHROMA Dark** | Matrix · Moonlight · Ember · Aurora · Midnight Signal |
| **CHROMA Light** | Sunlight · Paperwave · Glacier · Sakura Day |
| **Monochrome** | Mono Dark · Mono Light |

</details>

## ✦ Install

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/Aetherelic/chroma-shell/main/install.sh)
```

Preview the installation plan without changing the system:

```bash
git clone https://github.com/Aetherelic/chroma-shell.git
cd chroma-shell
./install.sh --local --dry-run
```

> CHROMA expects an existing Hyprland session. The installer deploys its own isolated configuration and does not replace the rest of your desktop.

### Supported targets

<img src="https://img.shields.io/badge/NixOS-Quick_Profile-7eb8ff?style=flat-square&logo=nixos&logoColor=white&labelColor=090b12" alt="NixOS" />
<img src="https://img.shields.io/badge/Arch-Linux-42c8ff?style=flat-square&logo=archlinux&logoColor=white&labelColor=090b12" alt="Arch Linux" />
<img src="https://img.shields.io/badge/Fedora_/_Nobara-Linux-8f7cff?style=flat-square&logo=fedora&logoColor=white&labelColor=090b12" alt="Fedora and Nobara" />
<img src="https://img.shields.io/badge/Ubuntu_Family-Linux-ff9f43?style=flat-square&logo=ubuntu&logoColor=white&labelColor=090b12" alt="Ubuntu family" />

## ✦ What ships

- Theme-aware bar with workspaces, centred media, CAVA, utilities, clock and optional solid background
- Desktop widget canvas with edit mode, resizing, snapping, fonts and per-monitor placement
- Safe display previews with Keep / Revert protection
- Application defaults, launcher favourites, hidden applications and user autostart management
- Searchable clipboard history, notifications, quick settings, wallpaper management and session controls
- Configuration snapshots, diagnostics, repair tools and Git-aware project status
- Six bundled CHROMA wallpapers installed without overwriting user files

## ✦ CLI

```bash
chroma start
chroma restart
chroma settings
chroma launcher
chroma clipboard
chroma widgets edit
chroma themes
chroma doctor
chroma update
chroma uninstall
```

## ✦ Editions

**CHROMA Kinetic** is the distribution-neutral shell available through this repository.

**CHROMA Kaizen** is the extended edition intended for [Kaizen Linux](https://github.com/Aetherelic/Kaizen-Linux), with deeper distribution integration.

## ✦ Credits

<div align="center">

### CHROMA

Designed and developed by **Aetherelic**  
GitHub: [@Aetherelic](https://github.com/Aetherelic)

Built with Quickshell, Hyprland, Qt/QML, CAVA and the wider Linux desktop ecosystem.

[MIT License](./LICENSE)

<br />

**Theme your system. Shape your shell.**

</div>
