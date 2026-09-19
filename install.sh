#!/bin/bash

# Niri Dotfiles - Installation Script (Fedora)
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"

# Helper functions
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

log()   { echo -e "${GREEN}[+]${NC} $1"; }
warn()  { echo -e "${YELLOW}[!]${NC} $1"; }
error() { echo -e "${RED}[x]${NC} $1"; exit 1; }

# Preflight checks
if ! command -v dnf >/dev/null 2>&1; then
    error "This installer requires Fedora or a dnf-based distribution."
fi

if ! command -v sudo >/dev/null 2>&1; then
    error "sudo is required to install packages."
fi

if [ "$(id -u)" -eq 0 ]; then
    error "Do not run this installer as root. It uses sudo when necessary."
fi

# Directories excluded from ~/.config symlinking
IGNORE_DIRS=(
    ".git"
    "Screenshots"
    "local"
    "nvim"
    "xdg-desktop-portal"
    "greetd"
    "systemd"
    "udev"
    "security"
)

is_ignored() {
    local target="$1"
    for ignore in "${IGNORE_DIRS[@]}"; do
        if [[ "$target" == "$ignore" ]]; then
            return 0
        fi
    done
    return 1
}

# 1. Official Fedora packages
log "Reading packages from packages.txt..."
if [ -f "$DOTFILES_DIR/packages.txt" ]; then
    mapfile -t PKG_ARRAY < <(
        grep -vE '^[[:space:]]*#|^[[:space:]]*$' "$DOTFILES_DIR/packages.txt"
    )
    
    if [ ${#PKG_ARRAY[@]} -eq 0 ]; then
        log "No packages found in packages.txt."
    else
        log "Installing ${#PKG_ARRAY[@]} packages..."
        if ! sudo dnf install -y "${PKG_ARRAY[@]}"; then
            warn "Strict installation failed, retrying with --setopt=strict=0..."
            if ! sudo dnf install -y --setopt=strict=0 "${PKG_ARRAY[@]}"; then
                error "Package installation failed. Check internet connection or Fedora repositories."
            fi
        fi
        
        # System services
        if command -v bluetoothctl >/dev/null 2>&1; then
            log "Enabling Bluetooth service..."
            sudo systemctl enable --now bluetooth.service
        fi

        if command -v podman >/dev/null 2>&1; then
            log "Enabling rootless Podman socket..."
            systemctl --user enable --now podman.socket 2>/dev/null || true
        fi

        if command -v boltctl >/dev/null 2>&1; then
            log "Enabling Thunderbolt daemon..."
            sudo systemctl enable --now bolt.service 2>/dev/null || true
        fi

        if command -v cupsd >/dev/null 2>&1; then
            log "Enabling printer services (CUPS & Avahi)..."
            sudo systemctl enable --now cups.service 2>/dev/null || true
            sudo systemctl enable --now avahi-daemon.service 2>/dev/null || true
        fi

        if getent group video >/dev/null 2>&1; then
            log "Adding user to video group for camera access..."
            sudo usermod -aG video "$USER" 2>/dev/null || true
        fi
    fi
else
    warn "packages.txt not found, skipping package installation."
fi

# Flatpak applications
if command -v flatpak >/dev/null 2>&1; then
    log "Configuring Flathub..."
    flatpak remote-add --if-not-exists --user flathub https://dl.flathub.org/repo/flathub.flatpakrepo 2>/dev/null || \
    sudo flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo 2>/dev/null || true

    log "Checking OnlyOffice Desktop Editors (Flatpak)..."
    flatpak install -y --noninteractive flathub org.onlyoffice.desktopeditors 2>/dev/null || \
    flatpak install -y --user --noninteractive flathub org.onlyoffice.desktopeditors 2>/dev/null || warn "Failed to install OnlyOffice via Flatpak."

    log "Checking Vesktop Discord (Flatpak)..."
    flatpak install -y --noninteractive flathub dev.vencord.Vesktop 2>/dev/null || \
    flatpak install -y --user --noninteractive flathub dev.vencord.Vesktop 2>/dev/null || warn "Failed to install Vesktop via Flatpak."

    log "Checking Bruno API Client (Flatpak)..."
    flatpak install -y --noninteractive flathub com.usebruno.Bruno 2>/dev/null || \
    flatpak install -y --user --noninteractive flathub com.usebruno.Bruno 2>/dev/null || warn "Failed to install Bruno via Flatpak."
fi

# Starship prompt
if ! command -v starship >/dev/null 2>&1; then
    log "Installing Starship..."
    mkdir -p "$HOME/.local/bin"
    if command -v curl >/dev/null 2>&1; then
        curl --fail --silent --show-error https://starship.rs/install.sh | \
            sh -s -- -y -b "$HOME/.local/bin"
        command -v "$HOME/.local/bin/starship" >/dev/null 2>&1 || error "Starship installation failed."
    else
        error "curl is required to install Starship"
    fi
fi

# Hyprlock
if ! command -v hyprlock >/dev/null 2>&1; then
    log "Installing Hyprlock..."
    if sudo dnf copr enable -y sdegler/hyprland 2>/dev/null; then
        sudo dnf install -y hyprlock 2>/dev/null || warn "Failed to install Hyprlock from COPR sdegler/hyprland."
    fi
fi

# Zed editor
if ! command -v zed >/dev/null 2>&1 && [ ! -f "$HOME/.local/bin/zed" ]; then
    log "Installing Zed editor..."
    if command -v curl >/dev/null 2>&1; then
        curl -f https://zed.dev/install.sh | sh 2>/dev/null || warn "Failed to install Zed editor."
    fi
fi

# Clean custom PipeWire configs
rm -rf "$HOME/.config/pipewire" 2>/dev/null || true

# 2. Directory structure
log "Creating directory structure..."
mkdir -p ~/.config ~/.local/bin ~/.local/share/screenshots
echo "enabled=False" > "$HOME/.config/user-dirs.conf" 2>/dev/null || true

# Remove unwanted directories if empty
[ -d "$HOME/bruno" ] && rmdir "$HOME/bruno" 2>/dev/null || true
[ -d "$HOME/Bruno" ] && rmdir "$HOME/Bruno" 2>/dev/null || true

# 3. Symlink configuration directories
log "Symlinking configurations to ~/.config..."
for dir_path in "$DOTFILES_DIR"/*/; do
    [ -d "$dir_path" ] || continue
    name="$(basename "$dir_path")"
    
    if is_ignored "$name"; then
        continue
    fi
    
    src_dir="$DOTFILES_DIR/$name"
    dest_dir="$HOME/.config/$name"

    if [ -L "$dest_dir" ] && [ "$(readlink "$dest_dir")" = "$src_dir" ]; then
        continue
    fi
    
    if [ -e "$dest_dir" ] && [ ! -L "$dest_dir" ]; then
        warn "Backing up existing directory: ~/.config/$name -> ~/.config/$name.bak"
        rm -rf "$dest_dir.bak" 2>/dev/null || true
        mv "$dest_dir" "$dest_dir.bak"
    fi
    
    ln -sfn "$src_dir" "$dest_dir"
    log "Linked ~/.config/$name"
done

# 4. Symlink local scripts and applications
log "Symlinking scripts to ~/.local/bin..."
if [ -d "$DOTFILES_DIR/local/bin" ]; then
    for script in "$DOTFILES_DIR/local/bin"/*; do
        [ -f "$script" ] || continue
        script_name="$(basename "$script")"
        src_file="$DOTFILES_DIR/local/bin/$script_name"
        dest_file="$HOME/.local/bin/$script_name"

        if [ -L "$dest_file" ] && [ "$(readlink "$dest_file")" = "$src_file" ]; then
            continue
        fi

        chmod +x "$src_file"
        ln -sfn "$src_file" "$dest_file"
        log "Linked script: $script_name"
    done
fi

if [ -d "$DOTFILES_DIR/local/share/applications" ]; then
    mkdir -p "$HOME/.local/share/applications"
    for app in "$DOTFILES_DIR/local/share/applications"/*.desktop; do
        [ -f "$app" ] || continue
        app_name="$(basename "$app")"
        ln -sfn "$app" "$HOME/.local/share/applications/$app_name"
        log "Linked desktop entry: $app_name"
    done
fi

# 5. Copy static configs
log "Copying static configurations..."
if [ -f "$DOTFILES_DIR/mimeapps.list" ]; then
    cp -f "$DOTFILES_DIR/mimeapps.list" "$HOME/.config/mimeapps.list"
fi

if compgen -G "$DOTFILES_DIR/xdg-desktop-portal/*.conf" > /dev/null; then
    cp -f "$DOTFILES_DIR"/xdg-desktop-portal/*.conf "$HOME/.config/xdg-desktop-portal/"
fi

# 6. Ensure executable permissions
log "Ensuring executable permissions..."
[ -f "$DOTFILES_DIR/niri/autostart.sh" ] && chmod +x "$DOTFILES_DIR/niri/autostart.sh"
[ -d "$DOTFILES_DIR/waybar/scripts" ] && chmod +x "$DOTFILES_DIR"/waybar/scripts/*.sh 2>/dev/null || true
[ -d "$DOTFILES_DIR/local/bin" ] && chmod +x "$DOTFILES_DIR"/local/bin/* 2>/dev/null || true

# 7. Login screen (ReGreet) & Boot splash (Plymouth)
log "Configuring ReGreet & Plymouth..."

if ! dnf copr --help >/dev/null 2>&1; then
    log "Installing dnf-plugins-core..."
    sudo dnf install -y dnf-plugins-core || warn "Failed to install dnf-plugins-core."
fi

if dnf copr --help >/dev/null 2>&1 && ! dnf repolist 2>/dev/null | grep -qi "regreet"; then
    log "Enabling COPR mystical-devil/ReGreet..."
    sudo dnf copr enable -y mystical-devil/ReGreet || warn "Failed to enable ReGreet COPR."
fi

log "Installing login & boot packages..."
if sudo dnf install -y greetd greetd-selinux cage regreet plymouth plymouth-system-theme; then
    sudo mkdir -p /usr/share/backgrounds
    if [ -f "$DOTFILES_DIR/wallpapers/forest_dark_winter.jpg" ]; then
        sudo cp -f "$DOTFILES_DIR/wallpapers/forest_dark_winter.jpg" /usr/share/backgrounds/login-wallpaper.jpg
    fi

    if [ -d "$DOTFILES_DIR/greetd" ]; then
        sudo mkdir -p /etc/greetd
        sudo cp -f "$DOTFILES_DIR/greetd/config.toml" /etc/greetd/config.toml
        sudo cp -f "$DOTFILES_DIR/greetd/regreet.toml" /etc/greetd/regreet.toml
        sudo chmod -R 755 /etc/greetd
    fi

    if command -v plymouth-set-default-theme >/dev/null 2>&1; then
        log "Setting Plymouth boot theme to spinner..."
        sudo plymouth-set-default-theme spinner -R 2>/dev/null || true
    fi

    if ! id "greeter" >/dev/null 2>&1; then
        log "Creating system user 'greeter' for greetd..."
        sudo useradd -r -M -d /var/lib/greeter -G video,input -s /sbin/nologin greeter 2>/dev/null || true
    else
        sudo usermod -aG video,input greeter 2>/dev/null || true
    fi
    sudo mkdir -p /var/lib/greeter /var/log/regreet /var/cache/regreet
    sudo chown -R greeter:greeter /var/lib/greeter /var/log/regreet /var/cache/regreet 2>/dev/null || true

    if command -v greetd >/dev/null 2>&1 && command -v cage >/dev/null 2>&1 && command -v regreet >/dev/null 2>&1; then
        log "Enabling greetd service and graphical target..."
        sudo systemctl set-default graphical.target 2>/dev/null || true
        sudo systemctl disable gdm.service 2>/dev/null || true
        sudo systemctl disable sddm.service 2>/dev/null || true
        sudo systemctl enable greetd.service 2>/dev/null || true
        sudo systemctl restart greetd.service 2>/dev/null || true
    else
        warn "greetd/cage/regreet incomplete, skipping display manager switch."
    fi
else
    warn "Failed to install greetd/regreet/plymouth. Keeping existing display manager."
fi

# 8. Battery charge threshold (80%) if supported
if [ -d "/sys/class/power_supply" ] && ls /sys/class/power_supply/BAT* >/dev/null 2>&1; then
    log "Configuring battery charge limit (80%)..."
    if [ -f "$DOTFILES_DIR/udev/99-battery-charge-threshold.rules" ]; then
        sudo cp -f "$DOTFILES_DIR/udev/99-battery-charge-threshold.rules" /etc/udev/rules.d/
        sudo udevadm control --reload-rules 2>/dev/null || true
    fi
    if [ -f "$DOTFILES_DIR/systemd/battery-charge-threshold.service" ]; then
        sudo cp -f "$DOTFILES_DIR/systemd/battery-charge-threshold.service" /etc/systemd/system/
        sudo systemctl daemon-reload 2>/dev/null || true
        sudo systemctl enable --now battery-charge-threshold.service 2>/dev/null || true
    fi
fi

# 9. System security hardening
log "Applying security hardening..."
if command -v firewall-cmd >/dev/null 2>&1; then
    log "Enabling firewalld..."
    sudo systemctl enable --now firewalld.service 2>/dev/null || true
fi

if [ -f "$DOTFILES_DIR/security/99-security.conf" ]; then
    apply_sec="n"
    if [ -t 0 ]; then
        echo -e "${YELLOW}[!]${NC} Note: sysctl hardening (ptrace_scope, rp_filter) may affect debuggers, VPNs, or containers."
        read -r -p "Apply sysctl security hardening? [y/N] " answer
        [[ "$answer" =~ ^[Yy]$ ]] && apply_sec="y"
    fi

    if [ "$apply_sec" = "y" ]; then
        log "Applying sysctl security rules..."
        sudo cp -f "$DOTFILES_DIR/security/99-security.conf" /etc/sysctl.d/
        sudo sysctl --system >/dev/null 2>&1 || true
    else
        log "Skipping sysctl hardening (default developer-friendly rules kept)."
    fi
fi

chmod 700 "$HOME" 2>/dev/null || true

# 10. Systemd journal memory and disk limits
log "Configuring systemd-journald memory and disk limits..."
if [ -d "$DOTFILES_DIR/systemd/journald.conf.d" ]; then
    sudo mkdir -p /etc/systemd/journald.conf.d
    sudo cp -f "$DOTFILES_DIR/systemd/journald.conf.d/"*.conf /etc/systemd/journald.conf.d/
    sudo systemctl restart systemd-journald 2>/dev/null || true
    sudo journalctl --vacuum-size=50M >/dev/null 2>&1 || true
fi

# 11. Camera privacy permissions & portal reset
log "Configuring camera permissions..."
if command -v gsettings >/dev/null 2>&1; then
    gsettings set org.gnome.desktop.privacy disable-camera false 2>/dev/null || true
fi

if command -v busctl >/dev/null 2>&1; then
    busctl --user call org.freedesktop.impl.portal.PermissionStore \
        /org/freedesktop/impl/portal/PermissionStore \
        org.freedesktop.impl.portal.PermissionStore \
        DeletePermission ss s "devices" "camera" "" 2>/dev/null || true

    busctl --user call org.freedesktop.impl.portal.PermissionStore \
        /org/freedesktop/impl/portal/PermissionStore \
        org.freedesktop.impl.portal.PermissionStore \
        SetPermission ssbays "devices" true "camera" "" 1 "yes" 2>/dev/null || true

    busctl --user call org.freedesktop.impl.portal.PermissionStore \
        /org/freedesktop/impl/portal/PermissionStore \
        org.freedesktop.impl.portal.PermissionStore \
        SetPermission ssbays "devices" true "camera" "org.gnome.Snapshot" 1 "yes" 2>/dev/null || true
fi

if command -v flatpak >/dev/null 2>&1; then
    flatpak permission-reset org.gnome.Snapshot 2>/dev/null || true
    flatpak permission-set devices camera org.gnome.Snapshot yes 2>/dev/null || true
fi

# 11. Restart audio and portal services
log "Restarting audio and portal services..."
systemctl --user reset-failed pipewire.service wireplumber.service pipewire-pulse.service 2>/dev/null || true
systemctl --user restart pipewire.service wireplumber.service pipewire-pulse.service 2>/dev/null || true
systemctl --user restart xdg-desktop-portal.service 2>/dev/null || true
systemctl --user restart xdg-desktop-portal-gnome.service 2>/dev/null || true

log "Dotfiles installation completed successfully!"
