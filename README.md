<div align="center">

# ✦ CHROMA ✦

**A vibrant, kinetic Quickshell desktop shell for Hyprland.**

<img src="https://img.shields.io/github/last-commit/Aetherelic/chroma-shell?style=for-the-badge&logo=git&color=63d6a3&labelColor=11111b" alt="Last commit" />
<img src="https://img.shields.io/github/license/Aetherelic/chroma-shell?style=for-the-badge&color=8ea8ff&labelColor=11111b" alt="License" />

<br />

<img src="https://img.shields.io/badge/Hyprland-Shell-82d9ff?style=flat-square&labelColor=11111b" alt="Hyprland" />
<img src="https://img.shields.io/badge/Quickshell-QML-dc8cff?style=flat-square&labelColor=11111b" alt="Quickshell" />
<img src="https://img.shields.io/badge/NixOS-Ready-7eb8ff?style=flat-square&labelColor=11111b" alt="NixOS" />
<img src="https://img.shields.io/badge/Arch-Ready-5bc0eb?style=flat-square&labelColor=11111b" alt="Arch" />
<img src="https://img.shields.io/badge/Fedora-Ready-71a5de?style=flat-square&labelColor=11111b" alt="Fedora" />
<img src="https://img.shields.io/badge/Ubuntu-Ready-ff9d66?style=flat-square&labelColor=11111b" alt="Ubuntu" />

<br /><br />

<img width="100%" src="./assets/readme/chroma-showcase.gif" alt="Animated CHROMA showcase" />

</div>

---

## ✦ CHROMA at a glance

<table>
<tr>
<td width="50%"><b>Style Studio</b><br />Sharp, Technical, Soft, Capsule and Hybrid geometry with coordinated Hyprland window rounding.</td>
<td width="50%"><b>Live desktop tools</b><br />Launcher, clipboard history, notifications, control centre, wallpaper selector, media and CAVA.</td>
</tr>
<tr>
<td><b>Real settings suite</b><br />Display management, application defaults, autostart, widgets, recovery, diagnostics and shell styling.</td>
<td><b>Cross-distro installer</b><br />A branded terminal installer for NixOS, Arch, Fedora and Ubuntu.</td>
</tr>
</table>

## ✦ Preview

<div align="center">

<img width="49%" src="https://github.com/user-attachments/assets/4642ee00-34cc-451d-b116-62e637d7fab3" alt="CHROMA Style Studio" />
<img width="49%" src="https://github.com/user-attachments/assets/de837cbf-41a4-4ec9-a1d1-68ad81715c6f" alt="CHROMA Display Manager" />

<img width="49%" src="https://github.com/user-attachments/assets/da45cbc5-b273-4040-85eb-47668214c397" alt="CHROMA Credits" />
<img width="49%" src="https://github.com/user-attachments/assets/79bfd9d2-661b-4a2f-b064-dacd11c4edcf" alt="CHROMA Wallpaper Selector" />

<br /><br />

<img width="100%" src="./assets/readme/chroma-settings-tour.gif" alt="Animated CHROMA settings tour" />

</div>

## ✦ Features

- Theme-aware top bar with workspaces, media controls, album art, CAVA, utilities and clock
- Global geometry and colour systems shared by every CHROMA surface
- Safe display previews with Keep / Revert protection
- Application defaults, launcher favourites, hidden apps and user autostart management
- Searchable clipboard history with image previews and private mode
- Notifications, OSDs, control centre, theme browser and wallpaper selection
- Snapshot recovery, diagnostics, repair tools and Git-aware project status
- CLI controls plus an aesthetic cross-distro installer

## ✦ Install

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/Aetherelic/chroma-shell/main/install.sh)
```

Preview the installer without changing anything:

```bash
git clone https://github.com/Aetherelic/chroma-shell.git
cd chroma-shell
./install.sh --local --dry-run
```

> CHROMA expects an existing Hyprland session. The installer deploys the shell and its integrations without replacing the rest of your desktop configuration.

## ✦ CLI

```bash
chroma start          # launch CHROMA
chroma restart        # restart the shell
chroma settings       # open settings
chroma launcher       # open the launcher
chroma clipboard      # open clipboard history
chroma doctor         # run diagnostics
chroma update         # update the installation
chroma uninstall      # remove managed files
```

## ✦ Status

| Area | State |
|---|:---:|
| Shell, bar and style engine | ✅ |
| Settings and display manager | ✅ |
| Applications and clipboard | ✅ |
| Recovery and diagnostics | ✅ |
| Cross-distro installer | ✅ |
| Declarative NixOS / Home Manager modules | 🚧 |

## ✦ Credits

<div align="center">

### CHROMA

Designed and developed by **Aetherelic**  
GitHub: [@Aetherelic](https://github.com/Aetherelic)

Built with Quickshell, Hyprland, Qt/QML, CAVA and the wider Linux desktop ecosystem.

</div>

## ✦ License

CHROMA is available under the [MIT License](./LICENSE).

---

<div align="center">

**Made with <3 by Aetherelic.**

</div>
