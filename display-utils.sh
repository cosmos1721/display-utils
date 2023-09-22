#!/bin/bash
dbus_service="org.gnome.SettingsDaemon.Power"
dbus_path="/org/gnome/SettingsDaemon/Power"
dbus_interface="org.gnome.SettingsDaemon.Power.Screen"
#ext_bth=$(ddcutil -d "$disp" getvcp 10 | awk '/current value/ {print $9}' | tr -d ',')
disp=$(ddcutil detect | grep "Display" | awk '{print $2}') 
current_brightness=0
checkState=true
exp=0

get_brightness() {
main_bth=$(dbus-send --session --dest=$dbus_service --print-reply=literal   $dbus_path org.freedesktop.DBus.Properties.Get string:"org.gnome.SettingsDaemon.Power.Screen"   string:"Brightness" | awk '{print $3}')
    if [ -z "$main_bth" ]; then
        echo "Error: Unable to retrieve brightness value via D-Bus. Trying using G-Bus"
	main_bth=$(gdbus call --session --dest $dbus_service --object-path "/org/gnome/SettingsDaemon/Power"   --method org.freedesktop.DBus.Properties.Get    "org.gnome.SettingsDaemon.Power.Screen" "Brightness" | awk -F'[<>]' '{print $2}')
    fi
    echo $main_bth
}

fetch_primary_brightness() {
    if [ $current_brightness != $(get_brightness) ]; then
        current_brightness=$(get_brightness)
        ddcutil -d "$disp" setvcp 10 "$current_brightness" > /dev/null 2>&1
    fi
}

main() {
while true; do
    connected=$(xrandr | awk '/ connected/ {count++} END {print count}')
    power=$(ddcutil getvcp d6 | awk '/DPM:/ {print $8}' | tr -d ',')
    if [ "$connected" -gt 1 ] ; then
        if [ "$power" == 'On' ] ; then
            if [ "$checkState" == true ] ; then
                xrandr --output HDMI-1-0 --auto --scale 1x1 --left-of eDP-1 
                checkState=false
            fi
            fetch_primary_brightness
        else
            if [ "$checkState" == false ] ; then
                xrandr --output HDMI-1-0 --mode 1600x900 --scale 1.2x1.2 --same-as eDP-1
                checkState=true
                exp=1
            elif [[ "$power" != 'On' && $exp -eq 0 ]]; then
            checkState=false
            else
                echo $checkState is huere
                checkState=true
            fi
            sleep 1
            echo $power
        fi
    fi

    # If the lid is closed, initiate sleep mode, comment this line if you don't want this feature
    if grep -q closed /proc/acpi/button/lid/*/state; then
        systemctl suspend
    fi
done

}

main


