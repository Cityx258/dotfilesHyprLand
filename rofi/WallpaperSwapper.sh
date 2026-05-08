#!/bin/bash

WALLPAPER_DIR="$HOME/Wallpapers"

chosen=$(ls "$WALLPAPER_DIR" | rofi -show drun -dmenu -p "Wallpaper")

if [ -n "$chosen" ]; then
	awww img --transition-type wipe --transition-duration 1 "$WALLPAPER_DIR/$chosen"
fi
