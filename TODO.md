# TODO

Ideas and improvements for the dotfilesHyprland rice.

## 🐞 Bugs

- [x] Fix power menu keybind case mismatch (`powermenu.sh` → `PowerMenu.sh`) in `hypr/keybinds.conf`
- [x] Add `network` + `battery` to waybar `modules-right` (were defined but not displayed)

## ✨ Features — high value

- [ ] **hypridle** — auto-lock/suspend on idle (companion to existing hyprlock). Add `hypr/hypridle.conf` (dim → lock → DPMS off → suspend) and launch it from `autostart.conf`.
- [ ] **Clipboard history** — `cliphist` + `wl-clipboard` with a rofi frontend bound to `Super+V`.
- [ ] **Screenshot to clipboard + annotation** — pipe `grim` output through `wl-copy`; add `satty`/`swappy` for editing. Ensure `~/Pictures` exists.
- [ ] **Bluetooth in waybar** — `bluez`/`bluez-utils` are installed but there's no bluetooth module on the bar.

## 💅 Polish

- [ ] Waybar tweaks — clickable clock w/ calendar, power/uptime module, network speed tooltip, custom Frieren-themed left module.
- [ ] Notification history in mako — bind a key to `makoctl restore` / dismiss-all.
- [ ] Emoji/glyph picker via rofi (`rofimoji`) — another small rofi script.
- [ ] Brightness/volume OSD — `swayosd` for a visual slider on existing keybinds.

## 🗂️ Repo / project quality

- [ ] `restore.sh` / uninstall symmetry — add `--help`, document install vs restore in README.
- [ ] Theme-switcher — companion to `WallpaperSwapper.sh` that swaps the whole palette (waybar/kitty/rofi) per wallpaper.
- [ ] Shellcheck the scripts in CI (small GitHub Action) since this is a public repo.
