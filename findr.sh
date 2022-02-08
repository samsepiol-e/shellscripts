#!/bin/bash

GDIR=~
findapp() {
    local appfile
    appfile=$(fd --search-path /System/Library/CoreServices --search-path /System/Applications --search-path /Applications --search-path /System/Applications/Utilities -d 1 "\.app$" | fzf --tiebreak="begin,end,index") && \
        open ${appfile}
}
getwindowstatus() {
    cur_status=$(yabai -m query --windows --window | jq -r '."is-floating"')
    echo $cur_status
}
toggle_window_float() {
    yabai -m window --toggle float && \
        yabai -m window --toggle sticky && \
        if [ "$(getwindowstatus)" = true ]; then
            yabai -m window --grid 6:6:1:1:4:4
        fi
}

focusprev() {
    local window_no_focus=($(
    yabai -m query --windows --space | \
        jq -r '.[] | select((."has-focus"==false) and (."is-floating"==false)).id' \
        )) && yabai -m window --focus ${window_no_focus[0]}
}

man_find() {
    local mpage
    mpage=$(
    fd --search-path $(man -w | sed -E 's/:/ --search-path /g') | sed -E 's/.+\/(.+)\..+/\1/g' | fzf
    ) && toggle_window_float && man ${mpage}
}
fif() {
    local file
    RG_PREFIX="ag -l"
    read -p "Please Enter File Name Pattern  in Regex : " filename
	file=($(
        INITIAL_QUERY="."
		FZF_DEFAULT_COMMAND="$RG_PREFIX -G "$filename" "$INITIAL_QUERY" "$GDIR"/ 2>/dev/null" \
			fzf --sort --preview="[[ ! -z {} ]] && rg -A 5 -N -p {q} {}" \
                --phony \
                -q '' \
				--bind "change:reload:$RG_PREFIX -G "$filename" {q} "$GDIR" || true" \
				--preview-window="70%:wrap" \
                --ansi \
                --print-query \
                )) && kitty -1 vim "$(ag ${file[0]} ${file[1]} | sed -E 's/([[:digit:]]+).+/\+\1/')" "${file[1]}"
                #kitty -1 vim "$(rg ${file} | sed -E 's/([[:digit:]]+).+/\+\1/')" "$(echo ${file} | gcut -d' ' -f2)"
}
findfile() {
    local file
    INITIAL_QUERY=""
    FD_PREFIX="fd -H -t f -a"
    file="$(
    $FD_PREFIX . $GDIR | fzf --preview="bat {}" \
        --preview-window="70%:wrap" \
        --ansi \
        --tiebreak=end,begin
	)" && echo $file
}
viewfile() {
    local file
    file=$(findfile) && kitty -1 bat "${file}"
}
openfile() {
    local file
    file=$(findfile) && toggle_window_float && vim "${file}"
}
openfilebytype() {
    local file
    file=$(findfile) && filetype=$(echo ${file} | sed -E 's/.+\.(.+)/\1/g') && \
        case "$filetype" in 
            pdf) nohup zathura "${file}" &;;
            #pdf) exec nohup zathura "${file}" & exit;;
            ""|sh|py|cc|c) vim "${file}";;
        esac
}


findfiles() {
    local file
    local searchdir=$GDIR
    INITIAL_QUERY="."
    FD_PREFIX="fd -H -t f -a"
    file="$(
        $FD_PREFIX . $GDIR | \
            fzf --preview="bat {}" \
            --multi \
            -q '' \
            --bind "change:reload:$FD_PREFIX {q} $GDIR || true" \
            --bind "enter:select-all+accept" \
            --preview-window="70%:wrap" \
            --ansi \
            --header="Searching by Filename"
        )" && echo ${file}
}
fff() {
    local file
    RG_PREFIX="ag -l"
    filename=$(findfiles)&& \
	file=($(
        INITIAL_QUERY="."
		FZF_DEFAULT_COMMAND="$RG_PREFIX $INITIAL_QUERY ${filename} 2>/dev/null" \
			fzf --multi --sort --preview="[[ ! -z {} ]] && rg -A 5 -N -p {q} {}" \
                --phony \
                -q '' \
				--bind "change:reload:$RG_PREFIX {q} ${filename} || true" \
				--preview-window="70%:wrap" \
                --ansi \
                --print-query \
                )) && kitty -1 vim "$(ag ${file[0]} ${file[1]} | sed -E 's/([[:digit:]]+).+/\+\1/')" "${file[1]}"

}
#find by glob
fbg() {
    local file
    local glob
    RG_PREFIX="rg -l"
    read -p "Please enter glob : " glob && \
	file=($(
        INITIAL_QUERY="."
		FZF_DEFAULT_COMMAND="$RG_PREFIX -g '$glob' $INITIAL_QUERY $GDIR 2>/dev/null" \
			fzf --sort --preview="[[ ! -z {} ]] && rg -A 5 -N -p {q} {}" \
                --phony \
                -q '' \
				--bind "change:reload:$RG_PREFIX -g '$glob' {q} $GDIR || true" \
				--preview-window="70%:wrap" \
                --ansi \
                --print-query \
                )) && \
                matchline=($(rg -n ${file[0]} ${file[1]})) && \
                    linenum=$(echo ${matchline[0]} | sed -E 's/([[:digit:]]+).+/\+\1/') && \
                    kitty -1 vim ${linenum} ${file[1]}
                #kitty -1 vim "$(ag ${file[0]} ${file[1]} | sed -E 's/([[:digit:]]+).+/\+\1/')" "${file[1]}"

}
case "$1" in 
    man_find) "$@";;
    fff) "$@";;
    viewfile) "$@";;
    openfile) "$@";;
    openfilebytype) "$@";;
    findapp) "$@";;
    fbg) "$@";;
    *) ;;
esac 
yabai -m window --focus recent
