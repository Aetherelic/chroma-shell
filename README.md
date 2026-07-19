<div align="center">

<img width="100%" src="./assets/readme/chroma-logo.gif" alt="Animated CHROMA logo" />

<br />

<img src="https://img.shields.io/github/last-commit/Aetherelic/chroma-shell?style=for-the-badge&logo=git&color=45f0a8&labelColor=090b12" alt="Last commit" />
<img src="https://img.shields.io/github/license/Aetherelic/chroma-shell?style=for-the-badge&color=8f7cff&labelColor=090b12" alt="MIT License" />

<br />

<img src="https://img.shields.io/badge/Release-1.0.0--rc.1-db5cff?style=flat-square&labelColor=090b12" alt="Release" />
<img src="https://img.shields.io/badge/Hyprland-Shell-42c8ff?style=flat-square&labelColor=090b12" alt="Hyprland shell" />
<img src="https://img.shields.io/badge/Quickshell-QML-ffe66d?style=flat-square&labelColor=090b12" alt="Quickshell QML" />
<img src="https://img.shields.io/badge/Themes-25-45f0a8?style=flat-square&labelColor=090b12" alt="25 themes" />
<img src="https://img.shields.io/badge/Widgets-Desktop_Canvas-ff9f43?style=flat-square&labelColor=090b12" alt="Desktop widgets" />

<br /><br />

**A vibrant,colourful and modular desktop shell built for Hyprland**

Themes, widgets, settings, desktop tools and installation — designed as one coherent CHROMA system.

</div>

---

<div align="center">
<img width="100%" src="./assets/readme/chroma-showcase.gif" alt="CHROMA live showcase" />
</div>

## ✦ The shell at a glance

<table>
<tr>
<td width="50%"><b>Style Selection</b><br />Five different styles, coordinated Hyprland rounding, transparent or solid bars, live palettes and per-module control.</td>
<td width="50%"><b>Desktop Widgets</b><br />Draggable and resizable Music, CAVA, Clock and System widgets with per-monitor layouts.</td>
</tr>
<tr>
<td><b>The Basics</b><br />Launcher, clipboard history, notifications, OSDs, theme browser, wallpaper selector and quick settings.</td>
<td><b>Real configuration</b><br />Display management, application defaults, autostart, diagnostics, snapshots and recovery.</td>
</tr>
</table>

## ✦ Settings Page

<div align="center">
<img width="100%" src="./assets/readme/chroma-settings-tour.gif" alt="Animated CHROMA settings tour" />
</div>

The settings application manages the shell without the need of editing the config files: Wi‑Fi, Bluetooth, displays, desktop widgets, applications, recovery, themes, shell geometry and system information all in one settings application

## ✦ Desktop Previews

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

| Theme categories | Included palettes |
|---|---|
| **Chroma Originals** | Voltage · Toxic · Ultraviolet · Solar Flare · Aqua Circuit · Candy Static |
| **Community Made** | Catppuccin Mocha · Gruvbox Dark · Tokyo Night · Nord · Rosé Pine · Kanagawa · Dracula · Everforest Dark |
| **Chroma Dark** | Matrix · Moonlight · Ember · Aurora · Midnight Signal |
| **Chroma Light** | Sunlight · Paperwave · Glacier · Sakura Day |
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

- Themeable bar with workspaces, Now Playing, CAVA, utilities, clock and optional solid background
- Desktop widgets with edit mode, resizing, snapping, fonts and per-monitor placement
- Safe display previews with Keep / Revert protection
- Application defaults, favourited apps, hidden applications and user autostart management
- Searchable clipboard history, notifications, quick settings, wallpaper management and session controls
- Configuration snapshots, diagnostics, repair tools and Git-aware project status
- Six premade wallpapers saved to ```~/Pictures/Wallpapers```

## ✦ Commands

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
## ✦ Keybinds
```
Super + Enter = Terminal
Super + , = Settings
Super + Q = Closes application
Super + L = Power Menu
Super + Shift + T = Theme Menu
Super + Shift + W = Wallpaper Menu
Alt + Space = Spotlight Search
```


## ✦ Editions

**CHROMA Kinetic** is the distribution-neutral shell available through this repository.

**CHROMA Kaizen** is the extended edition intended for [Kaizen Linux](https://github.com/Aetherelic/Kaizen-Linux), with deeper distribution integration.

## ✦ Credits

<div align="center">

### CHROMA

Made with <3 by **Aetherelic**  
GitHub: [@Aetherelic](https://github.com/Aetherelic)

Built with Quickshell, Hyprland and Qt
[MIT License](./LICENSE)

<br />


</div>
