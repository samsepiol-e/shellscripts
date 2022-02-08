#!/bin/bash
deminimize() {
    local miniwindow
    miniwindow=($(yabai -m query --windows \
        --space | \
        jq -r '.[] | select(."is-minimized"==true).id')) && \

    for wid in "${miniwindow[@]}"
    do
        yabai -m window --deminimize $wid
    done
}

minimizewindow() {
    yabai -m window --minimize
    yabai -m window --focus recent
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
toggle_zoom() {
    local wstatus
    wstatus=$(yabai -m query --windows --window | jq -r '."has-parent-zoom"')
    #if the current window has parent zoom, zoom out and focus recent
    if [[ $wstatus == true ]] 
    then
        yabai -m window --toggle zoom-parent && \
            yabai -m window --focus recent
    else
        echo $wstatus
    #else, focus recent and zoom parent
        yabai -m window --focus recent && \
            yabai -m window --toggle zoom-parent
    fi
}

case "$1" in
    minimizewindow) "$@";;
    deminimize) "$@";;
    toggle_window_float) "$@";;
    toggle_zoom) "$@";;
    *) ;;
esac
