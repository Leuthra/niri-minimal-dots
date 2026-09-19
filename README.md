<p align="center">
  <img src="Screenshots/landing.png" alt="Niri Dotfiles" width="800">
</p>

<h1 align="center">Niri Dotfiles</h1>

<p align="center">
  A complete, reproducible <a href="https://github.com/YaLTeR/niri">Niri</a> Wayland desktop environment for Fedora Linux.
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

## What's Included

This repository reproduces a complete Niri desktop environment from a fresh Fedora Linux install. It includes:

- **Niri** — scrollable tiling compositor with blur, animations, and rounded corners
- **Waybar** — modular status bar with player, clipboard, notifications, CPU, memory, power
- **Fuzzel** — fast Wayland-native application launcher
- **Mako** — notification daemon with sakura rice theme
- **Fish** — smart shell with Starship prompt
- **Alacritty + Kitty** — dual terminal setup
- **Custom scripts** — power menu, wallpaper picker, clipboard history, notification history
- **MIME associations** — PDF, images, code, archives, media all configured
- **Portal configuration** — screen sharing and screenshots working out of the box
- **GTK/Qt theming** — adw-gtk3-dark, Papirus-Dark icons, Adwaita cursor

---

## Quick Start

```bash
# Clone the repository
git clone https://github.com/Leuthra/niri-minimal-dots.git
cd niri-minimal-dots

# Run the installer (installs packages, symlinks configs, sets up everything)
chmod +x install.sh
./install.sh

# Reboot
sudo reboot
```

That's it. The installer handles:
- Package installation (dnf)
- Config symlinking with backups
- MIME associations
- Wallpaper installation
- Portal configuration
- Script permissions

---

## What the Installer Does

<details>
<summary><strong>Click to expand full install.sh behavior</strong></summary>

1. **Installs packages** from `packages.txt` via `dnf install` (uses `mapfile` to safely parse the array)
2. **Creates directories** (`~/.config`, `~/.local/bin`, `~/Pictures/wallpapers`)
3. **Symlinks all config directories** from the repo to `~/.config/` (backs up existing)
4. **Links local/bin scripts** to `~/.local/bin/`
5. **Installs wallpapers** from `wallpapers/` to `~/Pictures/wallpapers/`
6. **Installs MIME associations** (`mimeapps.list` → `~/.config/`)
7. **Installs portal configs** (`xdg-desktop-portal/*.conf` → `~/.config/xdg-desktop-portal/`)
8. **Sets executable permissions** on all scripts

</details>

---

## Keybindings

### Applications

| Keybinding | Action |
|------------|--------|
| `Mod + Return` | Open terminal (Alacritty) |
| `Alt + Return` | Open terminal (Kitty) |
| `Mod + Space` | Launcher & PowerToys Run (Fuzzel apps, calc, search, commands) |
| `Mod + B` | Open browser (Firefox) |
| `Mod + E` | Open file manager (Nautilus) |
| `Mod + Z` | Open editor (Zed) |
| `Mod + V` | Open Discord (Vesktop) |
| `Mod + Alt + W` | Interactive wallpaper picker |
| `Mod + Shift + W` | Random wallpaper switcher |
| `Mod + Alt + L` | Lock screen (Swaylock) |
| `Mod + Shift + P` | Suspend / Sleep PC |
| `Mod + Alt + I` | Toggle Caffeine / Idle sleep mode |
| `Mod + T` | Power menu (Fuzzel-based) |
| `Print` | Screenshot (Grim + Slurp + Swappy) |

### Window Management

| Keybinding | Action |
|------------|--------|
| `Mod + Q` | Close window |
| `Mod + F` | Maximize column |
| `Mod + Shift + F` | Fullscreen window |
| `Mod + D` | Toggle floating |
| `Mod + Shift + V` | Switch focus floating/tiling |
| `Mod + W` | Toggle tabbed column |
| `Mod + R` | Cycle column width |
| `Mod + O` | Toggle overview |
| `Mod + H/L` | Focus left/right |
| `Mod + J/K` | Focus window down/up |
| `Mod + Ctrl + H/J/K/L` | Move window |

### Workspaces

| Keybinding | Action |
|------------|--------|
| `Mod + 1-9` | Switch to workspace 1-9 |
| `Mod + Ctrl + 1-9` | Move window to workspace 1-9 |
| `Mod + U/I` | Workspace down/up |
| `Mod + Ctrl + U/I` | Move window to workspace down/up |
| `Mod + Page_Down/Up` | Workspace down/up |

### Monitors

| Keybinding | Action |
|------------|--------|
| `Mod + Shift + H/J/K/L` | Focus monitor left/down/up/right |
| `Mod + Shift + Ctrl + H/J/K/L` | Move window to monitor |
| `Mod + Shift + M` | Turn off monitors |

### Media Keys

| Keybinding | Action |
|------------|--------|
| `XF86AudioRaise/Lower` | Volume up/down |
| `XF86AudioMute` | Toggle mute |
| `XF86AudioMicMute` | Toggle mic mute |
| `XF86AudioPlay/Prev/Next` | Media controls |
| `XF86BrightnessUp/Down` | Brightness up/down |

### Screenshots

| Keybinding | Action |
|------------|--------|
| `Print` | Screenshot (Grim + Slurp + Swappy) |
| `Ctrl + Print` | Screenshot (current output) |
| `Alt + Print` | Screenshot (current window) |

---

## Custom Scripts

### `~/.local/bin/` Scripts

| Script | Description | Dependencies |
|--------|-------------|--------------|
| `powermenu` | Fuzzel-based power menu (Shutdown/Reboot/Suspend/Logout/Lock) | fuzzel, systemctl, swaylock |
| `lockscreen` | Smart screen locker (wallpaper background or blur with swaylock-effects) | swaylock |
| `set-wallpaper` | Interactive wallpaper picker & random switcher | fuzzel, swaybg |
| `fuzzel-powertoys` | PowerToys Run (calc `= 2+2`, web `? query`, run `> cmd`) | fuzzel, python3, wl-copy |
| `battery-threshold` | Set and toggle battery charge limit (80% / 100%) | sysfs, notify-send |
| `idle-manager` | Configurable idle screen lock & sleep manager | swayidle, swaylock, niri |
| `clipboard-history` | Browse and select from clipboard history | cliphist, fuzzel, wl-copy |
| `notification-history` | Browse notification history | fuzzel, makoctl |
| `mako-history` | View Mako notification log | fuzzel |
| `whatsapp` | Launch WhatsApp Web in Firefox | firefox |
| `spotify` | Launch Spotify Web in Firefox | firefox |

### Waybar Scripts (`waybar/scripts/`)

| Script | Description |
|--------|-------------|
| `powermenu.sh` | Power menu triggered from waybar |
| `clipboard.sh` | Clipboard history/clear from waybar |
| `bluetooth-control.sh` | Bluetooth device picker with Fuzzel |
| `bluetooth.sh` | Bluetooth status display |
| `volume-control.sh` | Volume control with device selection |
| `network-control.sh` | Network manager with WiFi scanning |
| `notification-control.sh` | Notification history (Python, uses makoctl) |
| `notifications.sh` | Notification count display |
| `mediaplayer.sh` | Media player status (playerctl) |
| `launch-waybar.sh` | Waybar launcher with warning suppression |

---

## MIME Associations

Configured in `mimeapps.list`:

| Type | Default App |
|------|------------|
| PDF | Firefox |
| JPEG/PNG/WEBP/GIF | Nautilus |
| SVG | Firefox |
| Plain text | Kitty |
| Directories | Nautilus |
| HTML | Firefox |
| Video (mp4) | mpv |
| Audio (mp3) | mpv |
| HTTP/HTTPS | Firefox |

---

## Portal Configuration

Screen sharing and screenshots work via `xdg-desktop-portal-gnome`. The repository includes:

- `xdg-desktop-portal/niri-portals.conf` — Routes ScreenCast and Screenshot to GNOME backend
- `xdg-desktop-portal/portals.conf` — General fallback (FileChooser/OpenURI/Print → GTK)

These are installed to `~/.config/xdg-desktop-portal/` by the installer.

---

## Fonts

The following fonts are required (installed by `packages.txt`):

| Font | Package | Used By |
|------|---------|---------|
| Cascadia Code NF | `cascadia-code-nf-fonts` | Alacritty, Kitty, Waybar, Mako, Fuzzel |
| Symbols Nerd Font | (fallback within Cascadia/FontAwesome) | Waybar icon fallback |
| Noto Color Emoji | `google-noto-color-emoji-fonts` | Emoji rendering |
| Noto Emoji | `google-noto-emoji-fonts` | Emoji fallback |
| DejaVu Sans | (base system) | System default |

---

## Themes

| Component | Theme / Style |
|-----------|--------------|
| GTK Theme | adw-gtk3-dark |
| Icon Theme | Papirus-Dark |
| Cursor Theme | Adwaita |
| Waybar | Catppuccin Mocha (custom) |
| Alacritty | Deep navy with sunset accents |
| Kitty | Glassy Frost Dracula-inspired |
| Mako | Sakura rice (pink/purple) |
| Fuzzel | Catppuccin Mocha overlay |

---

## Directory Structure

```
.
├── alacritty/
│   └── alacritty.toml           # Terminal config (deep navy theme)
├── btop/
│   └── btop.conf                # System monitor (glassy frost theme)
├── cava/
│   ├── config                   # Audio visualizer
│   ├── shaders/
│   └── themes/
├── environment.d/
│   ├── cursors.conf             # XCURSOR_THEME, XCURSOR_SIZE
│   └── unset-gtk-theme.conf     # Clears GTK_THEME env
├── fastfetch/
│   └── config.jsonc             # System info display
├── fish/
│   ├── config.fish              # Fish shell config
│   └── conf.d/                  # Theme, keybindings, auto-ls
├── fuzzel/
│   └── fuzzel.ini               # App launcher (DejaVu Sans, Catppuccin)
├── gtk-3.0/
│   ├── settings.ini             # GTK3 settings
│   ├── gtk.css
│   ├── colors.css
│   └── bookmarks
├── gtk-4.0/
│   ├── settings.ini             # GTK4 settings
│   └── colors.css
├── kitty/
│   ├── kitty.conf               # Kitty terminal (Glassy Frost theme)
│   ├── colors.conf
│   └── sessions/
├── local/bin/                   # Custom scripts
│   ├── powermenu                # Fuzzel power menu
│   ├── set-wallpaper            # Wallpaper picker
│   ├── clipboard-history        # Clipboard manager
│   ├── notification-history     # Notification viewer
│   └── mako-history             # Mako log viewer
├── mako/
│   └── config                   # Notifications (sakura rice theme)
├── mpv/
│   ├── mpv.conf                 # Media player
│   ├── fonts/
│   ├── script-opts/
│   └── scripts/
├── niri/
│   ├── config.kdl               # Main Niri config
│   ├── basicsettings.kdl        # Input, layout, animations
│   ├── keybinds.kdl             # All keybindings
│   ├── window_rules.kdl         # Per-app window rules
│   ├── autostart.sh             # Startup script
│   └── index.theme              # Cursor theme index
├── nvim/                        # Optional Neovim/LazyVim configuration — not installed by the Fedora installer
│   ├── init.lua
│   ├── lazy-lock.json
│   └── lua/
├── starship/
│   └── starship.toml            # Shell prompt
├── swappy/
│   └── config                   # Screenshot annotation
├── tmux/
│   └── tmux.conf                # Terminal multiplexer
├── waybar/
│   ├── config.jsonc             # Bar config (11 modules)
│   ├── style.css                # Bar styling (Catppuccin Mocha)
│   ├── modules/                 # Individual module configs
│   └── scripts/                 # 10 custom scripts
├── xdg-desktop-portal/
│   ├── niri-portals.conf        # Niri portal routing
│   └── portals.conf             # General portal fallback
├── wallpapers/
│   ├── forest_dark_winter.jpg   # Default wallpaper
│   └── rogue.jpg                # Alternative wallpaper
├── mimeapps.list                # MIME associations
├── packages.txt                 # Fedora package list for the core Niri desktop
├── install.sh                   # Automated installer
├── .gitignore
├── LICENSE
└── README.md
```

---

## Customization

### Change the Wallpaper

```bash
# Place images in ~/Pictures/wallpapers/
# Then use the picker:
~/.local/bin/set-wallpaper
```

Or edit `niri/autostart.sh` to change the default:
```bash
swaybg -i "$HOME/Pictures/wallpapers/your-wallpaper.jpg" -m fill &
```

### Change the Color Scheme

| File | Controls |
|------|----------|
| `waybar/style.css` | Waybar colors |
| `mako/config` | Notification colors |
| `alacritty/alacritty.toml` | Alacritty colors |
| `kitty/kitty.conf` | Kitty colors |
| `fuzzel/fuzzel.ini` | Launcher colors |

### Add Waybar Modules

Edit `waybar/config.jsonc` to add modules to `modules-left`, `modules-center`, or `modules-right`. Define new modules in `waybar/modules/`.

### Change Terminal Font

Edit `font_family` in `alacritty/alacritty.toml` or `font_family` in `kitty/kitty.conf`.

---

## Troubleshooting

### Waybar icons not showing
```bash
# Install the missing symbols font
sudo dnf install cascadia-code-nf-fonts -y
fc-cache -fv
killall waybar && waybar &
```

### Waybar not showing
```bash
killall waybar
~/.config/waybar/scripts/launch-waybar.sh
```

### No notifications
```bash
killall mako
mako &
```

### Wallpaper not changing
```bash
# Test manually
swaybg -i ~/Pictures/wallpapers/your-wallpaper.jpg -m fill &
```

### Lock screen not working
```bash
# Test swaylock
swaylock -f
```

### Screen sharing not working
```bash
# Verify portal config
cat ~/.config/xdg-desktop-portal/niri-portals.conf
# Should show:
# [preferred]
# default=gnome
# org.freedesktop.impl.portal.ScreenCast=gnome
# org.freedesktop.impl.portal.Screenshot=gnome

# Restart portal
systemctl --user restart xdg-desktop-portal
systemctl --user restart xdg-desktop-portal-gnome
```

### Fonts look wrong
```bash
# Rebuild font cache
fc-cache -fv
# Verify fonts are found
fc-match "Cascadia Code NF"
```

---

## Applications

| Category | Application |
|----------|-------------|
| Compositor | [Niri](https://github.com/YaLTeR/niri) |
| Bar | [Waybar](https://github.com/Alexays/Waybar) |
| Launcher | [Fuzzel](https://codeberg.org/dnkl/fuzzel) |
| Terminal | [Alacritty](https://github.com/alacritty/alacritty) + [Kitty](https://sw.kovidgoyal.net/kitty/) |
| Shell | [Fish](https://fishshell.com/) |
| Prompt | [Starship](https://starship.rs/) |
| Notifications | [Mako](https://github.com/emersion/mako) |
| Lock Screen | [Hyprlock](https://github.com/hyprwm/hyprlock) / [Swaylock](https://github.com/swaywm/swaylock) |
| Power Menu | Fuzzel custom |
| Clipboard | [Cliphist](https://github.com/sentriz/cliphist) + [wl-clipboard](https://github.com/bugaevc/wl-clipboard) |
| Screenshot | [Grim](https://sr.ht/~emersion/grim/) + [Slurp](https://wayland.emersion.fr/slurp/) + [Swappy](https://github.com/jtheoof/swappy) |
| Wallpaper | [Swaybg](https://github.com/swaywm/swaybg) |
| File Manager | [Nautilus](https://apps.gnome.org/Nautilus/) |
| Browser | [Firefox](https://www.mozilla.org/) |
| Media Player | [mpv](https://mpv.io/) |
| System Monitor | [btop](https://github.com/aristocratos/btop) |
| Audio Visualizer | [Cava](https://github.com/kornerc/cava) |
| System Info | [Fastfetch](https://github.com/fastfetch-cli/fastfetch) |

---

## Credits

- [Niri](https://github.com/YaLTeR/niri) — Wayland compositor
- [Waybar](https://github.com/Alexays/Waybar) — Status bar
- [Fuzzel](https://codeberg.org/dnkl/fuzzel) — Application launcher
- [Catppuccin](https://github.com/catppuccin/catppuccin) — Color scheme inspiration
- [LazyVim](https://github.com/LazyVim/LazyVim) — Neovim config

---

## License

This project is licensed under the MIT License — see the [LICENSE](LICENSE) file for details.

---

<p align="center">
  Made with ❤️ by <a href="https://github.com/youngcoder45">Aditya Verma</a>
</p>
