#!/usr/bin/env bash
#
# install.sh — set up the dotfilesHyprLand rice on Arch Linux.
#
# Usage:
#   ./install.sh [options]
#
# Options:
#   --no-packages   Skip package installation (just deploy configs)
#   --link          Symlink configs instead of copying them
#   --no-backup     Don't back up existing configs before deploying
#   -y, --yes       Assume "yes" to all prompts (non-interactive)
#   -h, --help      Show this help
#
set -euo pipefail

# ---------------------------------------------------------------------------
# Setup
# ---------------------------------------------------------------------------
REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}"
BACKUP_DIR="$HOME/.config-backup-$(date +%Y%m%d-%H%M%S)"

# Config directories that live under ~/.config
CONFIGS=(hypr waybar rofi kitty mako fastfetch gtk-3.0 gtk-4.0 qt5ct qt6ct)

# Pacman (repo) packages
PACMAN_PKGS=(
    hyprland waybar rofi kitty mako
    awww polkit-gnome gnome-keyring
    pipewire wireplumber pavucontrol
    qt5ct qt6ct kvantum-qt5 kvantum
    papirus-icon-theme hyprlock
    fastfetch grim slurp
    playerctl brightnessctl dolphin
    networkmanager bluez bluez-utils
    ttf-jetbrains-mono-nerd noto-fonts zsh
)

# AUR packages

#uncomment the next line to install these packages from the AUR
# AUR_PKGS=(adw-gtk3 candy-icons)

#comment the next line to install the previous packages from the AUR
AUR_PKGS=()

# Options
DO_PACKAGES=1
DO_BACKUP=1
USE_LINK=0
ASSUME_YES=0

# ---------------------------------------------------------------------------
# Pretty output
# ---------------------------------------------------------------------------
if [[ -t 1 ]]; then
    BOLD=$'\e[1m'; GREEN=$'\e[32m'; YELLOW=$'\e[33m'; RED=$'\e[31m'; BLUE=$'\e[34m'; RESET=$'\e[0m'
else
    BOLD=''; GREEN=''; YELLOW=''; RED=''; BLUE=''; RESET=''
fi

info()  { printf '%s==>%s %s\n' "$BLUE$BOLD" "$RESET" "$*"; }
ok()    { printf '%s  ✓%s %s\n' "$GREEN" "$RESET" "$*"; }
warn()  { printf '%s  !%s %s\n' "$YELLOW" "$RESET" "$*"; }
err()   { printf '%s  ✗%s %s\n' "$RED" "$RESET" "$*" >&2; }
die()   { err "$*"; exit 1; }

confirm() {
    # confirm "Question?" -> returns 0 for yes
    (( ASSUME_YES )) && return 0
    local reply
    read -r -p "$(printf '%s?%s %s [y/N] ' "$YELLOW$BOLD" "$RESET" "$1")" reply
    [[ "$reply" =~ ^[Yy]$ ]]
}

# ---------------------------------------------------------------------------
# Parse args
# ---------------------------------------------------------------------------
while [[ $# -gt 0 ]]; do
    case "$1" in
        --no-packages) DO_PACKAGES=0 ;;
        --link)        USE_LINK=1 ;;
        --no-backup)   DO_BACKUP=0 ;;
        -y|--yes)      ASSUME_YES=1 ;;
        -h|--help)
            sed -n '2,13p' "${BASH_SOURCE[0]}" | sed 's/^# \{0,1\}//'
            exit 0
            ;;
        *) die "Unknown option: $1 (try --help)" ;;
    esac
    shift
done

# ---------------------------------------------------------------------------
# Sanity checks
# ---------------------------------------------------------------------------
[[ $EUID -eq 0 ]] && die "Don't run this as root. It installs into your home directory."

if (( DO_PACKAGES )) && ! command -v pacman >/dev/null 2>&1; then
    warn "pacman not found — this rice targets Arch Linux."
    warn "Skipping package installation; deploying configs only."
    DO_PACKAGES=0
fi

# ---------------------------------------------------------------------------
# 1. Packages
# ---------------------------------------------------------------------------
install_packages() {
    info "Installing packages with pacman (needs sudo)..."
    sudo pacman -S --needed "${PACMAN_PKGS[@]}"
    ok "Repo packages installed."

    # Find an AUR helper
    local helper=""
    for h in yay paru; do
        if command -v "$h" >/dev/null 2>&1; then helper="$h"; break; fi
    done

    if [[ -n "$helper" ]]; then
        info "Installing AUR packages with $helper..."
        "$helper" -S --needed "${AUR_PKGS[@]}"
        ok "AUR packages installed."
    else
        warn "No AUR helper (yay/paru) found. Install these manually:"
        warn "    ${AUR_PKGS[*]}"
    fi
}

if (( DO_PACKAGES )); then
    if confirm "Install packages now"; then
        install_packages
    else
        warn "Skipping package installation."
    fi
fi

# ---------------------------------------------------------------------------
# 2. Deploy configs
# ---------------------------------------------------------------------------
backup_path() {
    # Move an existing path into the backup dir, preserving its name.
    local target="$1"
    [[ -e "$target" || -L "$target" ]] || return 0
    (( DO_BACKUP )) || { rm -rf "$target"; return 0; }
    mkdir -p "$BACKUP_DIR"
    mv "$target" "$BACKUP_DIR/"
    warn "Backed up $(basename "$target") -> $BACKUP_DIR/"
}

deploy_one() {
    local name="$1"
    local src="$REPO_DIR/$name"
    local dest="$CONFIG_DIR/$name"
    [[ -d "$src" ]] || { warn "Missing source: $name (skipped)"; return 0; }

    backup_path "$dest"
    if (( USE_LINK )); then
        ln -sfn "$src" "$dest"
        ok "Linked  $name"
    else
        cp -r "$src" "$dest"
        ok "Copied  $name"
    fi
}

info "Deploying configs to $CONFIG_DIR ($( ((USE_LINK)) && echo symlink || echo copy ))..."
mkdir -p "$CONFIG_DIR"
for c in "${CONFIGS[@]}"; do
    deploy_one "$c"
done

# Make rofi scripts executable (only matters when copying; harmless for links)
if [[ -d "$CONFIG_DIR/rofi" ]]; then
    chmod +x "$CONFIG_DIR"/rofi/*.sh 2>/dev/null || true
    ok "Marked rofi scripts executable"
fi

# ---------------------------------------------------------------------------
# 3. Wallpapers & fastfetch images
# ---------------------------------------------------------------------------
deploy_assets() {
    local name="$1" src="$REPO_DIR/$1" dest="$HOME/$1"
    [[ -d "$src" ]] || return 0
    mkdir -p "$dest"
    cp -rn "$src"/. "$dest"/ 2>/dev/null || true
    ok "Assets in ~/$name (existing files kept)"
}

info "Deploying wallpapers and fastfetch images to your home directory..."
deploy_assets "Wallpapers"
deploy_assets "Fastfetch-Images"

# ---------------------------------------------------------------------------
# 4. Services
# ---------------------------------------------------------------------------
if (( DO_PACKAGES )) && command -v systemctl >/dev/null 2>&1; then
    if confirm "Enable NetworkManager and Bluetooth services"; then
        sudo systemctl enable --now NetworkManager.service 2>/dev/null \
            && ok "NetworkManager enabled" || warn "Could not enable NetworkManager"
        sudo systemctl enable --now bluetooth.service 2>/dev/null \
            && ok "Bluetooth enabled" || warn "Could not enable Bluetooth"
    fi
fi

# ---------------------------------------------------------------------------
# Done
# ---------------------------------------------------------------------------
echo
info "${BOLD}Done!${RESET}"
(( DO_BACKUP )) && [[ -d "$BACKUP_DIR" ]] && echo "  Old configs saved in: $BACKUP_DIR"
cat <<EOF

${BOLD}Next steps:${RESET}
  • Open qt5ct / qt6ct and set the style to ${BOLD}Kvantum${RESET}, then pick a theme in kvantummanager.
  • Adjust ${BOLD}~/.config/hypr/monitors.conf${RESET} to match your displays (hyprctl monitors).
  • Log out and select ${BOLD}Hyprland${RESET} from your display manager (or run: Hyprland).

Enjoy the rice. 🌿
EOF
