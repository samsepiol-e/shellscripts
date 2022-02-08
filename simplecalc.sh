#!/bin/bash

#check if terminal window with the name exists. if not, start a new instance, else deminimize
#name the terminal calcterm
#location at top right corner
#WTITLE="CALC_TERM_WINDOW"
check_window_exists() {
    local windowid
    windowid=$(yabai -m query --windows --space | \
        jq -r '.[] | select(.title=="term_calc").id') && \
        echo $windowid
}
#if doesn't exist, start new
toggle_window_show() {
    local windowid=$(check_window_exists) &&\
    if [[ -z "$windowid" ]]; then
        kitty -1 --instance-group="utilapps" -T="term_calc" -d ~ insect
    else
        window_minimized_tf=$(yabai -m query --windows --window $windowid | \
            jq -r '."is-minimized"')
        if [ $window_minimized_tf == true ]; then
            yabai -m window --deminimize $windowid &&\
                yabai -m window --focus $windowid
        else
            yabai -m window --focus $windowid && \
                yabai -m window --minimize $windowid && \
                yabai -m window --focus recent
        fi
    fi
}
toggle_window_show
