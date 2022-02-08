#!/bin/bash
get_cur_window_split(){

    local spl_dir
    spl_dir=$(yabai -m query --windows --window $1 | jq -r '."split-type"') && \
        echo $spl_dir

}

find_split_type() {
    local window_ids
    window_ids=($(yabai -m query --windows --space | jq -r '.[]|select(."split-type" != "none").id')) 
        for wid in "${window_ids[@]}"
        do
            spl_dir=$(get_cur_window_split $wid) && \
                if [[ $spl_dir == $1 ]]; then
                    echo $wid;
                    break
                fi

        done
        
        
}
adj_border() {
    if [[ "$1" == "north" || "$1" == "south" ]]; then

        local spl_dir="horizontal"
        local wid
        wid=$(find_split_type $spl_dir)
        if [[ "$1" == "north" ]]; then
            yabai -m window $wid --ratio rel:-0.05
        else
            yabai -m window $wid --ratio rel:0.05
        fi
    else
        local spl_dir="vertical"
        local wid
        wid=$(find_split_type $spl_dir)
        if [[ "$1" == "west" ]]; then
            yabai -m window $wid --ratio rel:-0.05
        else
            yabai -m window $wid --ratio rel:0.05
        fi

    fi
}
adj_border "$1"
