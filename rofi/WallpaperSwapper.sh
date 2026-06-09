#!/bin/bash

WALLPAPER_DIR="$HOME/Wallpapers"

chosen=$(
	for img in "$WALLPAPER_DIR"/*; do
		[ -f "$img" ] || continue
		name=$(basename "$img")
		printf '%s\x00icon\x1f%s\n' "$name" "$img"
	done | rofi -dmenu -p "Wallpaper" -show-icons -theme ~/.config/rofi/wallpaper.rasi
)

if [ -n "$chosen" ]; then
	awww img --transition-type wipe --transition-duration 1 "$WALLPAPER_DIR/$chosen"
fi
