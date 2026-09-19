#!/bin/bash

# ╔═══════════════════════════════════════════════════════════════╗
# ║  Niri Dotfiles - Scalable Installation Script (Fedora)        ║
# ╚═══════════════════════════════════════════════════════════════╝

set -euo pipefail

# Konfigurasi Direktori
DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"

# ── Helper Functions ───────────────────────────────────────────
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log()   { echo -e "${GREEN}[+]${NC} $1"; }
warn()  { echo -e "${YELLOW}[!]${NC} $1"; }
error() { echo -e "${RED}[x]${NC} $1"; exit 1; }

# ── Preflight Checks ───────────────────────────────────────────

if ! command -v dnf >/dev/null 2>&1; then
    error "This installer requires Fedora or another dnf-based distribution."
fi

if ! command -v sudo >/dev/null 2>&1; then
    error "sudo is required to install Fedora packages."
fi

if [ "$(id -u)" -eq 0 ]; then
    error "Do not run this installer as root. It uses sudo when necessary."
fi

# Daftar Folder yang TIDAK akan di-symlink ke ~/.config
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
            return 0 # True, ignored
        fi
    done
    return 1 # False, not ignored
}

# 1. Install paket dari repo resmi Fedora
log "Membaca paket dari packages.txt..."
if [ -f "$DOTFILES_DIR/packages.txt" ]; then
    # Mengambil daftar paket, mengabaikan baris kosong dan baris komentar (#)
    # Install paket dengan list array yang bersih
    mapfile -t PKG_ARRAY < <(
        grep -vE '^[[:space:]]*#|^[[:space:]]*$' "$DOTFILES_DIR/packages.txt"
    )
    
    if [ ${#PKG_ARRAY[@]} -eq 0 ]; then
        log "Tidak ada paket yang ditemukan di packages.txt."
    else
        log "Menginstal ${#PKG_ARRAY[@]} paket..."
        if ! sudo dnf install -y "${PKG_ARRAY[@]}"; then
            warn "Instalasi ketat gagal, mencoba kembali dengan --setopt=strict=0 (abaikan paket yang tidak ditemukan)..."
            if ! sudo dnf install -y --setopt=strict=0 "${PKG_ARRAY[@]}"; then
                warn "Instalasi paket gagal. Periksa koneksi atau repository Fedora."
                exit 1
            fi
        fi
        
        # Enable bluetooth service if installed
        if command -v bluetoothctl >/dev/null 2>&1; then
            log "Mengaktifkan service Bluetooth..."
            sudo systemctl enable --now bluetooth.service
        fi

        # Enable rootless podman socket if installed
        if command -v podman >/dev/null 2>&1; then
            log "Mengaktifkan rootless Podman socket..."
            systemctl --user enable --now podman.socket 2>/dev/null || true
        fi

        # Enable Thunderbolt daemon if installed
        if command -v boltctl >/dev/null 2>&1; then
            log "Mengaktifkan service Thunderbolt (bolt)..."
            sudo systemctl enable --now bolt.service 2>/dev/null || true
        fi

        # Enable printer support (CUPS & Avahi)
        if command -v cupsd >/dev/null 2>&1; then
            log "Mengaktifkan service printer (CUPS & Avahi)..."
            sudo systemctl enable --now cups.service 2>/dev/null || true
            sudo systemctl enable --now avahi-daemon.service 2>/dev/null || true
        fi

        # User video group for webcam access
        if getent group video >/dev/null 2>&1; then
            log "Menambahkan user ke group video untuk akses webcam/kamera..."
            sudo usermod -aG video "$USER" 2>/dev/null || true
        fi
    fi
else
    warn "packages.txt tidak ditemukan, melewati instalasi paket."
fi

# Flatpak Flathub, OnlyOffice & Vesktop
if command -v flatpak >/dev/null 2>&1; then
    log "Mengonfigurasi Flathub..."
    flatpak remote-add --if-not-exists --user flathub https://dl.flathub.org/repo/flathub.flatpakrepo 2>/dev/null || \
    sudo flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo 2>/dev/null || true

    log "Memeriksa instalasi OnlyOffice Desktop Editors (Flatpak)..."
    flatpak install -y --noninteractive flathub org.onlyoffice.desktopeditors 2>/dev/null || \
    flatpak install -y --user --noninteractive flathub org.onlyoffice.desktopeditors 2>/dev/null || warn "Gagal menginstal OnlyOffice via Flatpak."

    log "Memeriksa instalasi Vesktop Discord (Flatpak)..."
    flatpak install -y --noninteractive flathub dev.vencord.Vesktop 2>/dev/null || \
    flatpak install -y --user --noninteractive flathub dev.vencord.Vesktop 2>/dev/null || warn "Gagal menginstal Vesktop via Flatpak."

    log "Memeriksa instalasi Bruno API Client (Flatpak)..."
    flatpak install -y --noninteractive flathub com.usebruno.Bruno 2>/dev/null || \
    flatpak install -y --user --noninteractive flathub com.usebruno.Bruno 2>/dev/null || warn "Gagal menginstal Bruno via Flatpak."
fi

# Install Starship separately because it may not exist in Fedora repositories
if ! command -v starship >/dev/null 2>&1; then
    log "Installing Starship..."
    mkdir -p "$HOME/.local/bin"

    if command -v curl >/dev/null 2>&1; then
        curl --fail --silent --show-error https://starship.rs/install.sh | \
            sh -s -- -y -b "$HOME/.local/bin"
        command -v "$HOME/.local/bin/starship" >/dev/null 2>&1 || error "Starship gagal dipasang."
    else
        error "curl is required to install Starship"
    fi
fi

# Install Hyprlock (modern lockscreen dengan blur, clock, date, dan user avatar)
if ! command -v hyprlock >/dev/null 2>&1; then
    log "Menginstal Hyprlock untuk modern lockscreen..."
    if sudo dnf copr enable -y sdegler/hyprland 2>/dev/null; then
        sudo dnf install -y hyprlock 2>/dev/null || warn "Gagal menginstal hyprlock dari COPR sdegler/hyprland."
    fi
fi

# Install Zed editor if not installed
if ! command -v zed >/dev/null 2>&1 && [ ! -f "$HOME/.local/bin/zed" ]; then
    log "Menginstal Zed editor..."
    if command -v curl >/dev/null 2>&1; then
        curl -f https://zed.dev/install.sh | sh 2>/dev/null || warn "Gagal menginstal Zed editor otomatis."
    fi
fi

# 2. Buat struktur folder
log "Membuat struktur direktori..."
mkdir -p ~/.config ~/.local/bin ~/.local/share/screenshots
mkdir -p ~/.config/xdg-desktop-portal
if [ -d "$HOME/Pictures" ]; then
    mkdir -p "$HOME/Pictures/Screenshots"
fi

# 3. Symlink konfigurasi utama (Idempotent)
log "Melakukan symlink konfigurasi ke ~/.config..."
for dir_path in "$DOTFILES_DIR"/*/; do
    [ -d "$dir_path" ] || continue
    name="$(basename "$dir_path")"
    
    if is_ignored "$name"; then
        continue
    fi
    
    src_dir="$DOTFILES_DIR/$name"
    dest_dir="$HOME/.config/$name"

    # Jika target adalah symlink ke sumber yang benar, lewati
    if [ -L "$dest_dir" ] && [ "$(readlink "$dest_dir")" = "$src_dir" ]; then
        log "Link sudah terpasang: ~/.config/$name"
        continue
    fi
    
    # Backup HANYA jika target ada dan bukan symlink
    if [ -e "$dest_dir" ] && [ ! -L "$dest_dir" ]; then
        warn "Membuat backup: ~/.config/$name -> ~/.config/$name.bak"
        rm -rf "$dest_dir.bak" 2>/dev/null || true # Hapus backup lama
        mv "$dest_dir" "$dest_dir.bak"
    fi
    
    ln -sfn "$src_dir" "$dest_dir"
    log "Linked ~/.config/$name"
done

# 4. Symlink script lokal (powermenu, dll)
log "Melakukan symlink skrip ke ~/.local/bin..."
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
        log "Linked skrip: $script_name"
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

# 5. Salin pengaturan MIME & portal
log "Menyalin file statis..."

if [ -f "$DOTFILES_DIR/mimeapps.list" ]; then
    cp -f "$DOTFILES_DIR/mimeapps.list" "$HOME/.config/mimeapps.list"
fi

if compgen -G "$DOTFILES_DIR/xdg-desktop-portal/*.conf" > /dev/null; then
    cp -f "$DOTFILES_DIR"/xdg-desktop-portal/*.conf \
        "$HOME/.config/xdg-desktop-portal/"
fi

# 6. Pastikan permission script bisa dieksekusi
log "Memastikan permissions skrip..."
[ -f "$DOTFILES_DIR/niri/autostart.sh" ] && chmod +x "$DOTFILES_DIR/niri/autostart.sh"
[ -d "$DOTFILES_DIR/waybar/scripts" ] && chmod +x "$DOTFILES_DIR"/waybar/scripts/*.sh 2>/dev/null || true
[ -d "$DOTFILES_DIR/local/bin" ] && chmod +x "$DOTFILES_DIR"/local/bin/* 2>/dev/null || true



# 7. Setup Login Screen (ReGreet) & Boot Splash (Plymouth)
log "Mengonfigurasi ReGreet & Plymouth..."

# Pastikan dnf copr didukung (dnf-plugins-core)
if ! dnf copr --help >/dev/null 2>&1; then
    log "Memasang dnf-plugins-core untuk dukungan copr..."
    sudo dnf install -y dnf-plugins-core || warn "Gagal memasang dnf-plugins-core."
fi

# Enable COPR untuk ReGreet jika belum aktif
if dnf copr --help >/dev/null 2>&1 && ! dnf repolist 2>/dev/null | grep -qi "regreet"; then
    log "Mengaktifkan COPR mystical-devil/ReGreet..."
    sudo dnf copr enable -y mystical-devil/ReGreet || warn "Gagal mengaktifkan COPR ReGreet."
fi

# Install komponen greetd, cage, regreet, plymouth (Fail-fast check)
log "Menginstal paket login & boot..."
if sudo dnf install -y greetd greetd-selinux cage regreet plymouth plymouth-system-theme; then
    # Setup wallpaper sistem untuk greeter
    sudo mkdir -p /usr/share/backgrounds
    if [ -f "$DOTFILES_DIR/wallpapers/forest_dark_winter.jpg" ]; then
        sudo cp -f "$DOTFILES_DIR/wallpapers/forest_dark_winter.jpg" /usr/share/backgrounds/login-wallpaper.jpg
    fi

    # Pasang konfigurasi greetd
    if [ -d "$DOTFILES_DIR/greetd" ]; then
        sudo mkdir -p /etc/greetd
        sudo cp -f "$DOTFILES_DIR/greetd/config.toml" /etc/greetd/config.toml
        sudo cp -f "$DOTFILES_DIR/greetd/regreet.toml" /etc/greetd/regreet.toml
        sudo chmod -R 755 /etc/greetd
    fi

    # Set tema boot Plymouth ke spinner
    if command -v plymouth-set-default-theme >/dev/null 2>&1; then
        log "Mengatur tema boot Plymouth ke spinner..."
        sudo plymouth-set-default-theme spinner -R 2>/dev/null || true
    fi

    # Aktifkan greetd service hanya jika binary greetd, cage, dan regreet benar-benar tersedia
    if command -v greetd >/dev/null 2>&1 && command -v cage >/dev/null 2>&1 && command -v regreet >/dev/null 2>&1; then
        log "Mengaktifkan greetd service (mengganti display manager aktif)..."
        sudo systemctl disable gdm.service 2>/dev/null || true
        sudo systemctl disable sddm.service 2>/dev/null || true
        sudo systemctl enable greetd.service 2>/dev/null || true
    else
        error "greetd, cage, atau regreet belum lengkap terpasang. Display manager lama tidak diubah."
    fi
else
    error "Gagal memasang greetd/cage/regreet/Plymouth. Display manager tidak diubah."
fi

# 8. Setup Battery Charge Threshold (80%) jika didukung hardware
if [ -d "/sys/class/power_supply" ] && ls /sys/class/power_supply/BAT* >/dev/null 2>&1; then
    log "Mengonfigurasi batas charge baterai 80% (opsional jika didukung hardware)..."
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

# 9. Penguatan Keamanan Sistem (Security Hardening)
log "Menerapkan penguatan keamanan sistem..."

# Aktifkan firewall (firewalld)
if command -v firewall-cmd >/dev/null 2>&1; then
    log "Mengaktifkan firewalld..."
    sudo systemctl enable --now firewalld.service 2>/dev/null || true
fi

# Terapkan aturan sysctl keamanan (opsional, default: no)
if [ -f "$DOTFILES_DIR/security/99-security.conf" ]; then
    apply_sec="n"
    if [ -t 0 ]; then
        echo -e "${YELLOW}[!]${NC} Catatan: sysctl hardening (ptrace_scope, rp_filter) dapat memengaruhi debugger, VPN, atau container."
        read -r -p "Terapkan aturan sysctl security hardening? [y/N] " answer
        [[ "$answer" =~ ^[Yy]$ ]] && apply_sec="y"
    fi

    if [ "$apply_sec" = "y" ]; then
        log "Menerapkan aturan sysctl keamanan..."
        sudo cp -f "$DOTFILES_DIR/security/99-security.conf" /etc/sysctl.d/
        sudo sysctl --system >/dev/null 2>&1 || true
    else
        log "Melewati aturan sysctl keamanan (default aman untuk developer/workload umum)."
    fi
fi

# Lindungi direktori home dari akses user lain
chmod 700 "$HOME" 2>/dev/null || true

# 10. Konfigurasi Izin Privasi Kamera & Reset PermissionStore
log "Mengonfigurasi izin kamera dan multimedia..."
if command -v gsettings >/dev/null 2>&1; then
    gsettings set org.gnome.desktop.privacy disable-camera false 2>/dev/null || true
fi

if command -v busctl >/dev/null 2>&1; then
    # Reset generic denied camera permission
    busctl --user call org.freedesktop.impl.portal.PermissionStore \
        /org/freedesktop/impl/portal/PermissionStore \
        org.freedesktop.impl.portal.PermissionStore \
        DeletePermission ss s "devices" "camera" "" 2>/dev/null || true

    # Explicitly grant camera permission in portal PermissionStore
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

# 11. Restart Portal Services
log "Restarting portal services..."
systemctl --user restart pipewire.service wireplumber.service 2>/dev/null || true
systemctl --user restart xdg-desktop-portal.service 2>/dev/null || true
systemctl --user restart xdg-desktop-portal-gnome.service 2>/dev/null || true

log "Instalasi/Update dotfiles selesai!"
