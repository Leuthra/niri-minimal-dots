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

(
    for i in $(seq 1 50); do
        if busctl --user status org.gnome.Mutter.ScreenCast >/dev/null 2>&1; then
            systemctl --user restart xdg-desktop-portal-gnome.service 2>/dev/null || true
            break
        fi
        sleep 0.2
    done
) &

# Wallpaper
swaybg -i "$HOME/Pictures/wallpapers/forest_dark_winter.jpg" -m fill &

# Notifications
mako &

# Clipboard
wl-paste --watch cliphist store &

# Bar
waybar &

# Polkit
POLKIT_AGENT="/usr/libexec/kf6/polkit-kde-authentication-agent-1"
if [ -x "$POLKIT_AGENT" ]; then
    "$POLKIT_AGENT" &
else
    echo "Warning: polkit-kde authentication agent not found."
fi
