#!/bin/bash

toggle_power() {
	if bluetoothctl show | grep -q "Powered: yes"; then
		bluetoothctl power off
	else
		bluetoothctl power on
	fi
}

devices=$(bluetoothctl devices | awk '{print $2, $3}')
options="Toggle Power\nScan for devices\n$devices"
chosen=$(printf '%b' "$options" | rofi -show drun -dmenu -p "Bluetooth")
case "$chosen" in
	"Toggle Power")      toggle_power ;;
    "Scan for devices")  bluetoothctl scan on & sleep 5 && bluetoothctl scan off ;;
    *)
        mac=$(echo "$chosen" | awk '{print $1}')
        if [ -n "$mac" ]; then
            bluetoothctl connect "$mac"
        fi
        ;;
esac
