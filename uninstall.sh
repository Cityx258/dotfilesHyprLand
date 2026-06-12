#!/usr/bin/env bash

#
# uninstall.sh - remove the dotfilesHyprLand rice from your system
#
# this is a clean-slate uninstall: it deletes the rice's deployed configs and
# assets, then removes the repo itself. It does NOT restore configs you had before
# installing (run ./restore.sh first if you want those back), and it does NOT remove
# installed packages or disable services (those are listed at the end so you can remove)
# them by hand if you like).
#
# Usage:
# 	./uninstall.sh [options]
# 
# Options:
# 	--keep-repo		Don't delete the repo directory itself
# 	-y, --yes 		Assyme "yes" to all prompts (non-interactive)
# 	-h, --help		Show this help
#
set -euo pipefail

#---------------------------------------------------------------------------------------
# Setup
#---------------------------------------------------------------------------------------
REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}"

# Config directories deployed under ~/.config (must match install.sh)
CONFIGS=(hypr waybar rofi kitty mako fastfetch gtk-3.0 gtk-4.0 qt5ct qt6ct)

# Asset folders merged into $HOME (must match install.sh)
Assets=(Wallpapers Fastfetch-Images)

# Packages install.sh may have installed - listed for the user, never removed.
PKG_NOTE=(
	hyprland waybar rofi kitty mako awww polkit-gnome gnome-keyring
	pipewire wireplumber pavucontrol qt5ct qt6ct kvantum-qt5 kvantum
	papirus-icon-theme hyprlock fastfetch grim slurp playerctl
	brightnessctl dolphin networkmanager bluez bluez-utils
	ttf-jetbrains-mono-nerd noto-fonts adw-gtk3 candy-icons
)

# Options
KEEP_REPO=0
ASSUME_YES=0

#---------------------------------------------------------------------------------------
# Pretty output
#---------------------------------------------------------------------------------------
if [[-t 1 ]]; then
	BOLD=$'\e[1m'; GREEN=$'\e[32m'; YELLOW=$'\e[33m'; RED=$'\e[31m'; BLUE=$'\e[34m'; 
	RESET=$'\e[0m'
else
	BOLD=''; GREEN=''; YELLOW=''; RED=''; BLUE=''; RESET=''
fi

info() 	{printf '%s==>%s %s\n' "$BLUE$BOLD" "$RESET" "$*";}
ok()	{ printf '%s  ✓%s %s\n' "$GREEN" "$RESET" "$*"; }
warn()  { printf '%s  !%s %s\n' "$YELLOW" "$RESET" "$*"; }
err()   { printf '%s  ✗%s %s\n' "$RED" "$RESET" "$*" >&2; }
die()   { err "$*"; exit 1; }
confirm() {
    (( ASSUME_YES )) && return 0
    local reply
    read -r -p "$(printf '%s?%s %s [y/N] ' "$YELLOW$BOLD" "$RESET" "$1")" reply
    [[ "$reply" =~ ^[Yy]$ ]]
}

#---------------------------------------------------------------------------------------
# Parse args
#---------------------------------------------------------------------------------------
while [[ $# -gt 0 ]]; do
    case "$1" in
        --keep-repo) KEEP_REPO=1 ;;
        -y|--yes)    ASSUME_YES=1 ;;
        -h|--help)   sed -n '2,18p' "${BASH_SOURCE[0]}" | sed 's/^# \{0,1\}//'; exit 0 ;;
        *)           die "Unknown option: $1 (try --help)" ;;
    esac
    shift
done

# ---------------------------------------------------------------------------
# Sanity checks
# ---------------------------------------------------------------------------
[[ $EUID -eq 0 ]] && die "Don't run this as root."
# Guard the rm -rf below: an empty REPO_DIR would be catastrophic.
[[ -n "$REPO_DIR" && -d "$REPO_DIR" ]] || die "Could not locate repo directory."

# ---------------------------------------------------------------------------
# Confirm — this is destructive and does not restore your old configs.
# ---------------------------------------------------------------------------
info "This will remove the rice's configs and assets from your system."
warn "It does NOT restore your pre-install configs (run ./restore.sh first for that)."
(( KEEP_REPO )) || warn "It will also delete the repo at: $REPO_DIR"
confirm "Proceed with uninstall" || { warn "Aborted."; exit 0; }

# ---------------------------------------------------------------------------
# 1. Remove deployed configs (covers both copies and --link symlinks)
# ---------------------------------------------------------------------------
info "Removing configs from $CONFIG_DIR..."
for name in "${CONFIGS[@]}"; do
    dest="${CONFIG_DIR:?}/$name"
    if [[ -e "$dest" || -L "$dest" ]]; then
        rm -rf "$dest"
        ok "Removed $name"
    fi
done

# ---------------------------------------------------------------------------
# 2. Remove the rice's assets — use the repo as the manifest of what it added,
#    so we only delete files the rice shipped and leave your own files alone.
# ---------------------------------------------------------------------------
info "Removing rice assets from your home directory..."
for base in "${ASSETS[@]}"; do
    src="$REPO_DIR/$base"
    [[ -d "$src" ]] || continue
    removed=0
    while IFS= read -r -d '' f; do
        rel="${f#"$src/"}"
        target="$HOME/$base/$rel"
        [[ -e "$target" ]] && rm -f "$target" && removed=$((removed + 1))
    done < <(find "$src" -type f -print0)
    # Drop now-empty asset dirs, but keep ~/$base if you put your own files there.
    find "$HOME/$base" -type d -empty -delete 2>/dev/null || true
    ok "Removed $removed file(s) from ~/$base"
done

# ---------------------------------------------------------------------------
# 3. Note packages/services — we don't touch these.
# ---------------------------------------------------------------------------
info "Packages and services were left untouched."
echo "  If you want to remove the packages this rice installed, review and run:"
echo "      sudo pacman -Rns ${PKG_NOTE[*]}"
echo "  (Check the list first — some may be used by other things you rely on.)"

# ---------------------------------------------------------------------------
# 4. Remove the repo itself — last, so nothing above depended on it.
# ---------------------------------------------------------------------------
if (( KEEP_REPO )); then
    info "Leaving the repo in place: $REPO_DIR"
else
    info "Removing the repo directory: $REPO_DIR"
    # cd out first so we're not deleting the directory we're standing in.
    cd "$HOME"
    rm -rf "${REPO_DIR:?}"
    ok "Repo removed"
fi

echo
info "${BOLD}Done — the rice has been uninstalled.${RESET}"
echo "  Log out of Hyprland (or reboot) to fully clear the running session."
