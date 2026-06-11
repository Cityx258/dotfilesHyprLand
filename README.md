# 🌿 dotfilesHyprLand

A nature-themed Hyprland rice for Arch Linux. Forest greens, blur, smooth animations, and a modular config structure that's easy to hack on.

![Hyprland](https://img.shields.io/badge/WM-Hyprland-5a9e4a?style=flat-square)
![Arch](https://img.shields.io/badge/OS-Arch_Linux-1793d1?style=flat-square&logo=arch-linux)
![License](https://img.shields.io/badge/License-MIT-88c057?style=flat-square)

---
## 📸 Screenshots

![](https://raw.githubusercontent.com/Cityx258/dotfilesHyprLand/main/Screenshots/screenshot-20260408-192908.png)
![](https://raw.githubusercontent.com/Cityx258/dotfilesHyprLand/main/Screenshots/screenshot-20260408-193608.png)
![](https://raw.githubusercontent.com/Cityx258/dotfilesHyprLand/main/Screenshots/screenshot-20260408-193805.png)
![](https://raw.githubusercontent.com/Cityx258/dotfilesHyprLand/main/Screenshots/screenshot-20260505-011205.png)

---

## 🚀 Quick start

```bash
git clone https://github.com/Cityx258/dotfilesHyprLand.git ~/dotfilesHyprLand
cd ~/dotfilesHyprLand
./install.sh
```

That's it. The installer does everything for you — installs packages, deploys the
configs, drops in the wallpapers, and wires up the paths so the rice works on first
launch. When it finishes, log out and pick **Hyprland** from your display manager.

> Don't run it as root — it installs into your own home directory and uses `sudo`
> only for the package/service steps, prompting for your password when needed.

### What the installer does

- **Installs packages** — all the repo packages via `pacman --needed`, plus the AUR
  ones if `yay` or `paru` is found (skips this if you decline the prompt).
- **Deploys configs** — copies every config into `~/.config`. Anything already there
  is **moved into a timestamped backup** (`~/.config-backup-<timestamp>/`), never
  overwritten in place.
- **Installs assets** — copies the bundled wallpapers to `~/Wallpapers` and the
  fastfetch images to `~/Fastfetch-Images` (existing files of yours are kept). The
  configs reference these out of the box, so the wallpaper and fetch image just work.
- **Enables services** — optionally enables NetworkManager and Bluetooth.
- Marks the rofi scripts executable and prints clear next steps at the end.

### Options

```bash
./install.sh [options]
```

| Option | Effect |
|---|---|
| `--no-packages` | Skip package installation; just deploy the configs |
| `--link` | Symlink the configs instead of copying (so `git pull` updates them live) |
| `--no-backup` | Overwrite existing configs without backing them up first |
| `-y`, `--yes` | Assume "yes" to every prompt (non-interactive) |
| `-h`, `--help` | Show usage |

---

## ♻️ Restoring your old configs

`install.sh` moves whatever was in `~/.config` into a timestamped
`~/.config-backup-<timestamp>/` folder before deploying. To put the originals back:

```bash
./restore.sh --list          # show available backups and what's inside the newest
./restore.sh                 # restore everything from the newest backup
./restore.sh hypr waybar     # restore only specific configs
./restore.sh --from ~/.config-backup-20260101-120000   # restore from a specific backup
```

Before overwriting, `restore.sh` sets your *current* configs aside in
`~/.config-prerestore-<timestamp>/`, so the restore is itself reversible.

| Option | Effect |
|---|---|
| `--from DIR` | Restore from a specific backup dir (default: the newest) |
| `--list` | List available backups and exit |
| `--no-backup` | Don't set the current configs aside before overwriting |
| `-y`, `--yes` | Assume "yes" to every prompt |
| `-h`, `--help` | Show usage |

---

## 🛠 Manual installation

Prefer to do it by hand? The installer just automates these steps.

<details>
<summary>Show manual steps</summary>

```bash
# 1. Install packages
sudo pacman -S --needed hyprland waybar rofi kitty mako \
               awww polkit-gnome gnome-keyring \
               pipewire wireplumber pavucontrol \
               qt5ct qt6ct kvantum-qt5 kvantum \
               papirus-icon-theme \
               fastfetch grim slurp \
               playerctl brightnessctl dolphin \
               networkmanager bluez bluez-utils \
               ttf-jetbrains-mono-nerd noto-fonts

# AUR (use yay or paru)
yay -S --needed adw-gtk3 candy-icons

# 2. Deploy configs
for d in hypr waybar rofi kitty mako fastfetch gtk-3.0 gtk-4.0 qt5ct qt6ct; do
    cp -r "$d" ~/.config/
done
chmod +x ~/.config/rofi/*.sh

# 3. Copy assets
cp -rn Wallpapers/.       ~/Wallpapers/
cp -rn Fastfetch-Images/. ~/Fastfetch-Images/
```

Then finish setup:

- **Qt theming** — open `qt5ct`/`qt6ct`, set the style to **Kvantum**, then apply a
  theme in `kvantummanager`.
- **Monitors** — edit `~/.config/hypr/monitors.conf` to match your displays
  (see [Monitors](#-monitors)).

Finally, log out and select Hyprland from your display manager, or run `Hyprland`.

</details>

---

## 📦 Packages

The installer pulls these in for you; listed here for reference.

**Repo (pacman):**
`hyprland` `waybar` `rofi` `kitty` `mako` `awww` `polkit-gnome` `gnome-keyring`
`pipewire` `wireplumber` `pavucontrol` `qt5ct` `qt6ct` `kvantum-qt5` `kvantum`
`papirus-icon-theme` `fastfetch` `grim` `slurp` `playerctl` `brightnessctl` `dolphin`
`networkmanager` `bluez` `bluez-utils` `ttf-jetbrains-mono-nerd` `noto-fonts`

**AUR (yay/paru):** `adw-gtk3` `candy-icons`

> **Notes:** `awww` renders the wallpaper. For the cursor in the theme table below,
> install `better-miku-cursor` from the AUR as well (optional).

---

## 🗂 Structure

```
dotfilesHyprLand/
├── install.sh              # One-shot installer
├── restore.sh              # Restore backed-up configs
└── (configs below get deployed to ~/.config/)

~/.config/
├── hypr/
│   ├── hyprland.conf       # Entry point — sources all modules
│   ├── animations.conf     # Window & workspace animations
│   ├── autostart.conf      # Startup apps (waybar, mako, awww, keyring)
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
│   ├── PowerMenu.sh        # Power menu (logout, suspend, reboot, shutdown)
│   ├── WallpaperSwapper.sh # Live wallpaper picker
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

## ⌨️ Keybinds

| Keybind | Action |
|---|---|
| `Super + T` | Terminal (Kitty) |
| `Super + A` | App launcher (Rofi) |
| `Super + E` | File manager (Dolphin) |
| `Super + Q` | Close window |
| `Super + M` | Exit Hyprland |
| `Super + W` | Toggle floating |
| `Super + J` | Toggle split |
| `Super + P` | Pseudo (dwindle layout) |
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
| `Ctrl + Alt + Delete` | Power menu |
| `Super + Shift + W` | Wallpaper swapper |
| `Super + L` | Lock screen |


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

---

## 🎛 Customizing

Everything here is plain text config, so making the rice your own is mostly a matter of
swapping colors and a few numbers. Nothing is generated or hidden.

> Tip: run `./install.sh --link` to symlink the configs instead of copying, so editing
> the files in this repo (and `git pull`) updates your live setup directly. Otherwise
> edit the deployed copies under `~/.config/` and reload with `hyprctl reload`.

### Recolor it

The palette is forest green (`#5a9e4a` / `#88c057` accents on a near-black `#0f160f`
base). To take it somewhere else — like the alternate looks in the
[gallery below](#-make-it-your-own) — swap those values everywhere they appear:

| What | File | Look for |
|---|---|---|
| Window borders | `hypr/look.conf` | `col.active_border` / `col.inactive_border` |
| Bar colors | `waybar/style.css` | `background`, `color`, the `#workspaces` rules |
| Terminal palette | `kitty/kitty.conf` | `foreground` / `background` / `color0`–`color15` |
| Notifications | `mako/config` | `background-color`, `text-color`, `border-color` |
| Launcher / menus | `rofi/theme.rasi` | the `*` block: `fg`, `accent`, `urgent`, `bg` |

`rofi/theme.rasi` is the easiest starting point — it defines named color variables at the
top that the rest of the theme references, so changing `accent` recolors the whole menu.

### Feel & layout

- **Gaps, borders, rounding, blur, opacity, shadows** all live in `hypr/look.conf`.
- **Animations** (speed, curves) are in `hypr/animations.conf`.
- **Window placement rules** are in `hypr/windowrules.conf`.
- **Keybinds** are in `hypr/keybinds.conf` (see the [table above](#️-keybinds)).

### Wallpaper & fetch image

- **Wallpaper** — change it live with `Super + Shift + W` (the rofi wallpaper picker),
  or edit the `awww img` line in `hypr/autostart.conf` for the boot default. Drop your
  own images in `~/Wallpapers/`.
- **Fastfetch image** — swap the `"source"` path in `fastfetch/config.jsonc`; put new
  images in `~/Fastfetch-Images/`.

### GTK / Qt / fonts / cursor

- **GTK** theme, icons, cursor, and font are in `gtk-3.0/settings.ini` and
  `gtk-4.0/settings.ini`.
- **Qt** style is Kvantum — set it in `qt5ct`/`qt6ct` and theme it in `kvantummanager`.
- **Font** is `JetBrainsMono Nerd Font` throughout; search for it across the configs to
  change it everywhere.

---

## 🌈 Make it your own

The whole rice is just colors, gaps, and blur in plain config files — so it's easy to
take it somewhere completely different. Here's the same setup recolored into an entirely
different palette, as a taste of what you can do with `look.conf`, the GTK/Qt themes, and
your own wallpapers:

![](https://raw.githubusercontent.com/Cityx258/dotfilesHyprLand/main/Screenshots/screenshot-20260604-164917.png)
![](https://raw.githubusercontent.com/Cityx258/dotfilesHyprLand/main/Screenshots/screenshot-20260605-105157.png)
![](https://raw.githubusercontent.com/Cityx258/dotfilesHyprLand/main/Screenshots/screenshot-20260609-140830.png)
![](https://raw.githubusercontent.com/Cityx258/dotfilesHyprLand/main/Screenshots/screenshot-20260609-152708.png)
