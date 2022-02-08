#!/bin/bash
distpmst(){
    local tmwindows
    tmwindows=($(yabai -m query --windows --space | jq -r '.[] | select((."is-topmost"==true) and (.app=="Brave Browser")).id')) 

    for wid in "${tmwindows[@]}"
    do 
         yabai -m window $wid --toggle topmost
    done

}
distpmst
