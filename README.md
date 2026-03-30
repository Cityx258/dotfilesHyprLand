# 🌿 dotfilesHyprLand

A nature-themed Hyprland rice for Arch Linux. Forest greens, blur, smooth animations, and a modular config structure that's easy to hack on.

![Hyprland](https://img.shields.io/badge/WM-Hyprland-5a9e4a?style=flat-square)
![Arch](https://img.shields.io/badge/OS-Arch_Linux-1793d1?style=flat-square&logo=arch-linux)
![License](https://img.shields.io/badge/License-MIT-88c057?style=flat-square)

---

## 📦 Packages

Install everything you need in one shot:

```bash
# Core
sudo pacman -S hyprland waybar rofi kitty mako \
               swww polkit-gnome gnome-keyring \
               pipewire wireplumber pavucontrol \
               qt5ct qt6ct kvantum-qt5 kvantum \
               papirus-icon-theme adw-gtk-theme \
               fastfetch grim slurp \
               playerctl brightnessctl dolphin \
               ttf-jetbrains-mono-nerd noto-fonts

# AUR (use yay or paru)
yay -S adw-gtk3 better-miku-cursor candy-icons
```

> **Note:** `swww` is used for wallpaper rendering. `better-miku-cursor` and `candy-icons` are AUR packages.

---

## 🗂 Structure

```
~/.config/
├── hypr/
│   ├── hyprland.conf       # Entry point — sources all modules
│   ├── animations.conf     # Window & workspace animations
│   ├── autostart.conf      # Startup apps (waybar, mako, swww, keyring)
│   ├── environment.conf    # Env vars (Wayland, QT, GTK, cursor)
│   ├── input.conf          # Keyboard, mouse, touchpad
│   ├── keybinds.conf       # All keybindings
│   ├── look.conf           # Gaps, borders, blur, shadows, rounding
│   ├── monitors.conf       # Monitor layout
│   └── windowrules.conf    # Per-window rules
├── waybar/
│   ├── config.jsonc        # Bar modules (workspaces, clock, cpu, mem, audio)
│   └── style.css           # Bar styling
├── rofi/
│   ├── config.rasi         # Rofi behavior & font
│   └── theme.rasi          # Custom theme
├── kitty/
│   └── kitty.conf          # Terminal colors & font
├── mako/
│   └── config              # Notification styling
├── fastfetch/
│   └── config.jsonc        # Fetch layout with kitty-direct image
├── gtk-3.0/
│   └── settings.ini
├── gtk-4.0/
│   └── settings.ini
├── qt5ct/
│   └── qt5ct.conf
└── qt6ct/
    └── qt6ct.conf
```

---

## 🚀 Installation

### 1. Clone the repo

```bash
git clone https://github.com/Cityx258/dotfilesHyprLand.git ~/dotfilesHyprLand
cd ~/dotfilesHyprLand
```

### 2. Back up your existing configs (optional)

```bash
cp -r ~/.config/hypr ~/.config/hypr.bak
```

### 3. Copy configs

```bash
cp -r hypr        ~/.config/hypr
cp -r waybar      ~/.config/waybar
cp -r rofi        ~/.config/rofi
cp -r kitty       ~/.config/kitty
cp -r mako        ~/.config/mako
cp -r fastfetch   ~/.config/fastfetch
cp -r gtk-3.0     ~/.config/gtk-3.0
cp -r gtk-4.0     ~/.config/gtk-4.0
cp -r qt5ct       ~/.config/qt5ct
cp -r qt6ct       ~/.config/qt6ct
```

### 4. Set up your wallpaper

The config expects a wallpaper at `~/Wallpapers/FrierenForest.jpeg`. Either put your wallpaper there or edit `~/.config/hypr/autostart.conf` to point to your own:

```ini
exec-once = swww img ~/Wallpapers/YourWallpaper.jpg
```

### 5. Set up fastfetch image (optional)

The fastfetch config uses a custom image via `kitty-direct`. Either place your image at the path in the config or update it:

```json
"source": "/home/YOUR_USERNAME/Fastfetch-Images/your-image.png"
```

### 6. Apply Qt theming

Open `qt5ct` and `qt6ct` and set the style to **Kvantum**. Then open `kvantummanager` and apply a theme.

### 7. Log in to Hyprland

Select Hyprland from your display manager, or launch it with:

```bash
Hyprland
```

---

## ⌨️ Keybinds

| Keybind | Action |
|---|---|
| `Super + T` | Terminal (Kitty) |
| `Super + A` | App launcher (Rofi) |
| `Super + E` | File manager (Dolphin) |
| `Super + Q` | Close window |
| `Super + W` | Toggle floating |
| `Super + J` | Toggle split |
| `Alt + Return` | Fullscreen |
| `Super + 1–0` | Switch workspace |
| `Super + Shift + 1–0` | Move window to workspace |
| `Super + Arrow keys` | Move focus |
| `Super + Ctrl + Arrow keys` | Move window |
| `Super + Shift + Arrow keys` | Resize window |
| `Super + S` | Toggle scratchpad |
| `Super + Ctrl + S` | Send to scratchpad |
| `Super + Ctrl + P` | Screenshot (full) |
| `Super + Shift + P` | Screenshot (selection) |
| `XF86Audio*` | Volume / mute / mic |
| `XF86Brightness*` | Brightness |
| `XF86Media*` | Playerctl (play/pause/next/prev) |

---

## 🎨 Theme

| Element | Value |
|---|---|
| Color scheme | Forest green (`#5a9e4a` / `#88c057`) |
| GTK theme | `adw-gtk3-dark` |
| Icon theme | `Papirus-Dark` / `candy-icons` |
| Cursor | `better-miku-cursor` (size 30) |
| Font | `JetBrainsMono Nerd Font` |
| Qt style | Kvantum |
| Border | Green gradient, 2px, 10px rounding |
| Blur | Enabled (size 3, 1 pass) |
| Opacity | Active 95% / Inactive 90% |

---

## 🖥 Monitors

The config assumes two 1920×1080 @ 180Hz displays side by side (`DP-1` and `DP-2`). Edit `~/.config/hypr/monitors.conf` to match your setup:

```ini
monitor = YOUR_OUTPUT, WIDTHxHEIGHT@RATE, XOFFSETxYOFFSET, SCALE
```

Run `hyprctl monitors` to see your available outputs.
