#!/usr/bin/env zsh
TITLE=mylauncher

DISP_WIDTH=`yabai -m query --displays --display | jq .frame.w`
DISP_HEIGHT=`yabai -m query --displays --display | jq .frame.h`

#initial_window_width
let "WINDOW_WIDTH=DISP_WIDTH/2"
let "WINDOW_HEIGHT=DISP_HEIGHT/2"
let "W_H_MARGIN=DISP_WIDTH/4*3/4"
let "W_V_MARGIN=DISP_HEIGHT/4*3/4"
kitty --title ${TITLE} -o window_margin_width=${W_V_MARGIN},${W_H_MARGIN} --single-instance -d ~ $1
