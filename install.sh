#!/bin/bash

# ╔═══════════════════════════════════════════════════════════════╗
# ║  Niri Dotfiles - Scalable Installation Script (Fedora)        ║
# ╚═══════════════════════════════════════════════════════════════╝

set -euo pipefail

# Konfigurasi Direktori
DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"

# Daftar Folder yang TIDAK akan di-symlink ke ~/.config
IGNORE_DIRS=(
    ".git"
    "Screenshots"
    "wallpapers"
    "local"
    "nvim"
    "xdg-desktop-portal"
)

# ── Helper Functions ───────────────────────────────────────────
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log()   { echo -e "${GREEN}[+]${NC} $1"; }
warn()  { echo -e "${YELLOW}[!]${NC} $1"; }
error() { echo -e "${RED}[x]${NC} $1"; exit 1; }

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
        sudo dnf install -y "${PKG_ARRAY[@]}" || true
    fi
else
    warn "packages.txt tidak ditemukan, melewati instalasi paket."
fi

# 2. Buat struktur folder
log "Membuat struktur direktori..."
mkdir -p ~/.config ~/.local/bin
mkdir -p ~/Pictures/wallpapers ~/Pictures/Screenshots
mkdir -p ~/.config/xdg-desktop-portal

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

# 5. Salin wallpaper & pengaturan MIME
log "Menyalin file statis..."
cp -f "$DOTFILES_DIR"/wallpapers/* ~/Pictures/wallpapers/ 2>/dev/null || true
cp -f "$DOTFILES_DIR/mimeapps.list" ~/.config/mimeapps.list 2>/dev/null || true
cp -f "$DOTFILES_DIR"/xdg-desktop-portal/*.conf ~/.config/xdg-desktop-portal/ 2>/dev/null || true

# 6. Pastikan permission script bisa dieksekusi
log "Memastikan permissions skrip..."
[ -f "$DOTFILES_DIR/niri/autostart.sh" ] && chmod +x "$DOTFILES_DIR/niri/autostart.sh"



log "Instalasi/Update dotfiles selesai!"
