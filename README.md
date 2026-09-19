<p align="center">
  <img src="Screenshots/landing.png" alt="Niri Dotfiles" width="800">
</p>

<h1 align="center">Niri Dotfiles</h1>

<p align="center">
  A reproducible, minimal, and modern <a href="https://github.com/YaLTeR/niri">Niri</a> Wayland desktop environment for Fedora Linux.
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Niri-Wayland_compositor-5E9FD6?style=flat-square&logo=gnome-terminal&logoColor=white" alt="Niri">
  <img src="https://img.shields.io/badge/Fedora-294172?style=flat-square&logo=fedora&logoColor=white" alt="Fedora Linux">
  <img src="https://img.shields.io/badge/License-MIT-green?style=flat-square" alt="MIT License">
</p>

---

## Preview

| Desktop | Tiled | Waybar |
|---------|-------|--------|
| ![Desktop](Screenshots/desktop.png) | ![Tiled](Screenshots/desktop-tiled.png) | ![Waybar](Screenshots/waybar.png) |

| Launcher | Workspaces | Zed |
|----------|------------|-----|
| ![Launcher](Screenshots/launcher.png) | ![Workspaces](Screenshots/workspaces.png) | ![Zed](Screenshots/zed.png) |

| Neovim | Power Menu | Wallpaper Picker |
|--------|------------|------------------|
| ![Neovim](Screenshots/neovim.png) | ![Power Menu](Screenshots/powermenu.png) | ![Wallpapers](Screenshots/wallpaperpicker.png) |

| btop | Cava |
|------|------|
| ![btop](Screenshots/btopbtm.png) | ![Cava](Screenshots/cava.png) |

---

## Highlights

- **Niri Compositor** — Smooth scrollable tiling window manager with Catppuccin Mocha aesthetic, blur, and animations.
- **Modern Lockscreen** — Hyprlock with real-time blur, digital clock, date, and user avatar (with Swaylock fallback).
- **PowerToys Run (Fuzzel)** — Fast launcher with inline calculator (`= 25 * 4`), web search (`? query`), command runner (`> cmd`), and Flatpak support.
- **Smart Idle & Sleep** — Multi-stage power saving: 3m lock screen, 4m display power off (DPMS), 15m system suspend. Configurable in `~/.config/niri/idle.conf`.
- **Battery Care** — Optional hardware charge threshold capped at 80% to maximize laptop battery longevity.
- **Display Manager & Boot** — Modern ReGreet (greetd) login screen and clean Plymouth spinner boot animation.
- **Multimedia & Audio** — Cava visualizer with PulseAudio bridge, PipeWire multimedia stack, and camera portal support.
- **Waybar** — Modular status bar with workspace overview, media controller, battery stats, volume, and quick power controls.

---

## Quick Start

```bash
# Clone the repository
git clone https://github.com/Leuthra/niri-minimal-dots.git ~/dotfiles
cd ~/dotfiles

# Run the installer
chmod +x install.sh
./install.sh

# Reboot system
sudo reboot
```

---

## Keybindings

### Applications & System

| Keybinding | Action |
|------------|--------|
| `Mod + Return` | Open terminal (Alacritty) |
| `Alt + Return` | Open terminal (Kitty) |
| `Mod + Space` | PowerToys Run (Launcher, Calculator, Search, Commands) |
| `Mod + B` | Open browser (Firefox) |
| `Mod + E` | Open file manager (Nautilus) |
| `Mod + Z` | Open code editor (Zed) |
| `Mod + V` | Open Discord (Vesktop) |
| `Mod + Alt + W` | Interactive wallpaper picker |
| `Mod + Shift + W` | Random wallpaper switcher |
| `Mod + Alt + L` | Lock screen (Hyprlock / Swaylock) |
| `Mod + Shift + P` | Suspend / Sleep system |
| `Mod + Alt + I` | Toggle Caffeine mode (disable/enable idle sleep) |
| `Mod + T` | Power menu (Shutdown, Reboot, Sleep, Logout, Lock) |
| `Print` | Interactive screenshot area (Grim + Slurp + Swappy) |

### Window Management

| Keybinding | Action |
|------------|--------|
| `Mod + Q` | Close focused window |
| `Mod + F` | Maximize column |
| `Mod + Shift + F` | Fullscreen window |
| `Mod + D` | Toggle floating mode |
| `Mod + Shift + V` | Switch focus between floating and tiling windows |
| `Mod + R` | Cycle column width (33%, 50%, 66%) |
| `Mod + -` / `Mod + =` | Shrink / expand column width by 10% |
| `Mod + ,` / `Mod + .` | Consume window into column / expel window to side |
| `Mod + O` | Toggle workspace overview |
| `Mod + H` / `Mod + L` | Focus column left / right |
| `Mod + J` / `Mod + K` | Focus window down / up inside column |
| `Mod + Ctrl + H/J/K/L` | Move column or window |

### Workspaces & Monitors

| Keybinding | Action |
|------------|--------|
| `Mod + 1-9` | Switch to workspace 1-9 |
| `Mod + Ctrl + 1-9` | Move column to workspace 1-9 |
| `Mod + U` / `Mod + I` | Switch workspace down / up |
| `Mod + Shift + H/J/K/L` | Focus monitor left / down / up / right |
| `Mod + Shift + Ctrl + H/J/K/L` | Move column to target monitor |

---

## Custom Scripts (`~/.local/bin/`)

| Script | Description |
|--------|-------------|
| `fuzzel-powertoys` | Fast launcher with math calculation, web lookup, command execution, and Flatpak indexing |
| `lockscreen` | Smart screen locker with Hyprlock priority and Swaylock Catppuccin fallback |
| `idle-manager` | Automated multi-tier idle manager (lock -> screen off -> sleep) with Caffeine toggle |
| `set-wallpaper` | Wallpaper selector with fuzzel UI, randomizer, and state persistence |
| `powermenu` | Wayland-native power action menu |
| `clipboard-history` | Clipboard history browser using `cliphist` and `wl-copy` |
| `battery-threshold` | Laptop battery charge limiter toggle (80% / 100%) |

---

## Power & Idle Configuration

Idle settings can be customized in `~/.config/niri/idle.conf`:

```ini
# Timeouts in seconds
LOCK_TIMEOUT=180          # 3 minutes: Lock screen
SCREEN_OFF_TIMEOUT=240    # 4 minutes: Turn off monitors (1 min after lock)
SUSPEND_TIMEOUT=900       # 15 minutes: Suspend / Sleep laptop
```

To temporarily prevent the laptop from locking or sleeping (e.g. during presentations or downloads), press **`Mod + Alt + I`** to toggle Caffeine mode.

---

## Theming & Appearance

| Component | Theme |
|-----------|-------|
| GTK3 / GTK4 | adw-gtk3-dark with Papirus-Dark icons |
| Cursor | Adwaita (24px) |
| Status Bar | Waybar with Catppuccin Mocha styling |
| Lockscreen | Hyprlock with live blur, digital clock, date, and user avatar |
| Notifications | Mako with Catppuccin accents |
| Terminals | Alacritty & Kitty with custom color palettes |

---

## Directory Structure

```
.
├── alacritty/           # Alacritty terminal configuration
├── btop/                # System resource monitor theme
├── cava/                # Audio visualizer configuration
├── fastfetch/           # System information display
├── fish/                # Fish shell functions and configs
├── fuzzel/              # Application launcher styling
├── greetd/              # ReGreet login screen configuration
├── gtk-3.0/ & gtk-4.0/  # GTK appearance tokens and settings
├── hypr/                # Hyprlock configuration
├── kitty/               # Kitty terminal configuration
├── local/bin/           # Helper scripts (launcher, idle, lock, wallpaper)
├── mako/                # Notification daemon theme
├── mpv/                 # Media player configuration
├── niri/                # Niri compositor config, keybinds, and autostart
├── packages.txt         # Fedora RPM packages list
├── install.sh           # Automated deployment script
├── wallpapers/          # Curated wallpapers
├── waybar/              # Waybar bar modules and styles
└── xdg-desktop-portal/  # Wayland portal configuration for screen sharing
```

---

## License

This project is licensed under the MIT License — see the [LICENSE](LICENSE) file for details.
