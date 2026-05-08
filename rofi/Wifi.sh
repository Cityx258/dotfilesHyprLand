#!/bin/bash

networks=$(nmcli -f SSID, SECURITY, BARS device wifi list | tail -n +2)

chosen=$(echo $n"networks" | rofi -show drun -dmenu -p "WiFi")

if [ -n "$chosen" ]; then
	ssid=$(echo "$chosen" | awk '{print $1}')

	nmcli device wifi connect "$ssid"

	if [ $? -ne 0 ]; then
		password=$(rofi -show drun -dmenu -p "Password for $ssid" -password)
		nmcli device wifi connect "$ssid" password "$password"
	fi
fi
