#!/bin/bash

chosen=$(echo -e "󰍃 Logout\n󰤄 Suspend\n󰜉 Reboot\n󰐥 Shutdown" | rofi -show drun -dmenu -p "Power")

case $chosen in
    "󰍃 Logout")   hyprctl dispatch exit ;;
    "󰤄 Suspend")  systemctl suspend ;;
    "󰜉 Reboot")   systemctl reboot ;;
    "󰐥 Shutdown") systemctl poweroff ;;
esac
