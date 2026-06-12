#!/usr/bin/env bash
#
# restore.sh — restore configs that install.sh moved into a backup folder.
#
# install.sh moves your old ~/.config/<app> dirs into ~/.config-backup-<timestamp>/
# before deploying the rice. This script puts them back.
#
# Usage:
#   ./restore.sh [options] [config...]
#
#   With no config names, every config in the chosen backup is restored.
#   Otherwise only the named ones are (e.g. ./restore.sh hypr waybar).
#
# Options:
#   --from DIR   Restore from a specific backup dir (default: the newest one)
#   --list       List available backups (and what's in the newest) and exit
#   --no-backup  Don't set the current configs aside before overwriting
#   -y, --yes    Assume "yes" to all prompts (non-interactive)
#   -h, --help   Show this help
#
set -euo pipefail

CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}"
PRE_RESTORE_DIR="$HOME/.config-prerestore-$(date +%Y%m%d-%H%M%S)"

FROM=""
DO_LIST=0
DO_BACKUP=1
ASSUME_YES=0
SELECTED=()

# ---------------------------------------------------------------------------
# Pretty output (same style as install.sh)
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
        --from)      FROM="${2:-}"; [[ -n "$FROM" ]] || die "--from needs a directory"; shift ;;
        --list)      DO_LIST=1 ;;
        --no-backup) DO_BACKUP=0 ;;
        -y|--yes)    ASSUME_YES=1 ;;
        -h|--help)   sed -n '2,19p' "${BASH_SOURCE[0]}" | sed 's/^# \{0,1\}//'; exit 0 ;;
        -*)          die "Unknown option: $1 (try --help)" ;;
        *)           SELECTED+=("$1") ;;
    esac
    shift
done

# ---------------------------------------------------------------------------
# Find backups
# ---------------------------------------------------------------------------
# Newest last, so the final element is the most recent (names sort by timestamp).
mapfile -t BACKUPS < <(find "$HOME" -maxdepth 1 -type d -name '.config-backup-*' 2>/dev/null | sort)
[[ ${#BACKUPS[@]} -gt 0 ]] || die "No backups found (~/.config-backup-* don't exist)."

if (( DO_LIST )); then
    info "Available backups (newest last):"
    for b in "${BACKUPS[@]}"; do printf '    %s\n' "$b"; done
    echo
    info "Contents of newest (${BACKUPS[-1]##*/}):"
    for d in "${BACKUPS[-1]}"/*/; do [[ -d "$d" ]] && printf '    %s\n' "$(basename "$d")"; done
    exit 0
fi

# Choose the source backup
if [[ -n "$FROM" ]]; then
    [[ -d "$FROM" ]] || die "Backup dir not found: $FROM"
    SRC="$FROM"
else
    SRC="${BACKUPS[-1]}"
    if [[ ${#BACKUPS[@]} -gt 1 ]]; then
        warn "Found ${#BACKUPS[@]} backups; using the newest. Use --list to see all, --from to pick."
    fi
fi
info "Restoring from: $SRC"

# ---------------------------------------------------------------------------
# Decide what to restore
# ---------------------------------------------------------------------------
if [[ ${#SELECTED[@]} -eq 0 ]]; then
    SELECTED=()
    for d in "$SRC"/*/; do [[ -d "$d" ]] && SELECTED+=("$(basename "$d")"); done
    [[ ${#SELECTED[@]} -gt 0 ]] || die "Backup is empty: $SRC"
fi

printf '%s==>%s Will restore: %s%s%s\n' "$BLUE$BOLD" "$RESET" "$BOLD" "${SELECTED[*]}" "$RESET"
confirm "Proceed" || { warn "Aborted."; exit 0; }

# ---------------------------------------------------------------------------
# Restore
# ---------------------------------------------------------------------------
restored=0
for name in "${SELECTED[@]}"; do
    src="$SRC/$name"
    dest="$CONFIG_DIR/$name"
    if [[ ! -d "$src" ]]; then
        warn "Not in backup: $name (skipped)"
        continue
    fi

    # Set the current config aside so this restore is itself reversible.
    if [[ -e "$dest" || -L "$dest" ]]; then
        if (( DO_BACKUP )); then
            mkdir -p "$PRE_RESTORE_DIR"
            mv "$dest" "$PRE_RESTORE_DIR/"
        else
            rm -rf "$dest"
        fi
    fi

    cp -r "$src" "$dest"
    ok "Restored $name"
    restored=$((restored + 1))
done

# ---------------------------------------------------------------------------
# Done
# ---------------------------------------------------------------------------
echo
info "${BOLD}Done — restored $restored config(s).${RESET}"
if (( DO_BACKUP )) && [[ -d "$PRE_RESTORE_DIR" ]]; then
    echo "  Your pre-restore configs were saved in: $PRE_RESTORE_DIR"
fi
echo "  Restart Hyprland (or reload: hyprctl reload) for changes to take effect."
