#!/bin/sh

# Cursor
export XCURSOR_THEME="Adwaita"
export XCURSOR_SIZE=24
export XCURSOR_PATH="$HOME/.config/niri:$HOME/.icons:$HOME/.local/share/icons:/usr/share/icons"

# CRITICAL ENV (FIXED)
export XDG_CURRENT_DESKTOP=niri
export XDG_SESSION_DESKTOP=niri
export XDG_SESSION_TYPE=wayland
export GTK_USE_PORTAL=1

# Export to DBus (REQUIRED)
dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP &
gsettings set org.gnome.desktop.privacy disable-camera false 2>/dev/null &

(
    for i in $(seq 1 50); do
        if busctl --user status org.gnome.Mutter.ScreenCast >/dev/null 2>&1; then
            systemctl --user restart xdg-desktop-portal-gnome.service 2>/dev/null || true
            break
        fi
        sleep 0.2
    done
) &

# Wallpaper (persisten dari pilihan terakhir)
SAVED_WALL="$HOME/.config/niri/current-wallpaper"
if [ -f "$SAVED_WALL" ]; then
    WALL="$(cat "$SAVED_WALL")"
fi

if [ -n "${WALL:-}" ] && [ -f "$WALL" ]; then
    swaybg -i "$WALL" -m fill &
elif [ -f "$HOME/.config/wallpapers/forest_dark_winter.jpg" ]; then
    swaybg -i "$HOME/.config/wallpapers/forest_dark_winter.jpg" -m fill &
elif [ -f "$HOME/Pictures/wallpapers/forest_dark_winter.jpg" ]; then
    swaybg -i "$HOME/Pictures/wallpapers/forest_dark_winter.jpg" -m fill &
fi

# Notifications
mako &

# Clipboard
wl-paste --watch cliphist store &

# Bar
waybar &

# Idle & Sleep Manager
"$HOME/.local/bin/idle-manager" &

# Polkit
POLKIT_AGENT="/usr/libexec/kf6/polkit-kde-authentication-agent-1"
if [ -x "$POLKIT_AGENT" ]; then
    "$POLKIT_AGENT" &
else
    echo "Warning: polkit-kde authentication agent not found."
fi
