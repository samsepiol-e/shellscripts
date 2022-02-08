#!/bin/bash
deminimize() {
    local miniwindow
    miniwindow=($(yabai -m query --windows --space | jq -r '.[] | select(."is-minimized"==true).id')) && \
        for wid in "${miniwindow[@]}"
        do
            yabai -m window --deminimize "$wid"
        done
}

minimizewindow() {
    yabai -m window --minimize
}
getwindowstatus() {
    cur_status=$(yabai -m query --windows --window | jq -r '."is-floating"')
    echo $cur_status
}
toggle_window_float() {
    yabai -m window --toggle float && \
        yabai -m window --toggle sticky && \
        if [ "$(getwindowstatus)" = true ]; then
            yabai -m window --grid 4:4:1:1:2:2
        fi
}

case "$1" in
    minimizewindow) "$@";;
    deminimize) "$@";;
    toggle_window_float) "$@";;
    *) ;;
esac
