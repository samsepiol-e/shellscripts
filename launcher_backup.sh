#!/bin/bash

userchoice=""
GDIR=~
CURCITY="Sapporo"

RED='\033[1;31m'
GREEN='\033[0;32m'
ORANGE='\033[0;33m'
BLUE='\033[1;34m'
PURPLE='\033[1;35m'
DARKP='\033[0;35m'
CYAN='\033[0;36m'
GREEN='\033[1;36m'
GRAY='\033[0;37m'
YELLOW='\033[1;33m'
NC='\033[0;0m' # No Color
show_prompt() {
    echo "$(
cat << EOF
${BLUE}
# APPS
################################################################################
${ORANGE}
== LAUNCHER ==                              == Web ==
${GREEN}
a : Application                             g : Google
<CR> : Terminal                            h : Browser History

n : System Info
${ORANGE}
== Utilities ==                               == Monitor ==
${GREEN}
b : Homebrew                                c : Crypto Market 
B : Homebrew Cask
i : System Info                             p : htop
t : Directory Tree                          P : vtop 
d : Disk Space                              w : weather
s : sc-im
k : insect Calculator
${BLUE}
# ADJUST
################################################################################
${ORANGE}
== Window Settings ==
${GRAY}
r : Resize WIndow Size
f : Toggle Window Float
# OTHERS
################################################################################
${RED}q/<Esc>:  Quit
${BLUE}
################################################################################
${NC}
EOF
)"
    read -n1 -p "                       Please choose your option : " userchoice
    clear >$(tty)
}

printvals() {
    echo "${PURPLE}Directory : $GDIR"
}
printfinished() {
    echo "${ORANGE}Done!${NC}"
    read -n 1 tempvar
}
fa() {
    find /System/Library/CoreServices /System/Applications /Applications /System/Applications/Utilities -maxdepth 1 -name "*.app" | fzf --tiebreak="begin,end,index" | xargs -I {} open "{}"
}

fwf() {
    searchdir=$GDIR
    searchdir=${searchdir:-~}
    read -p "File Name : " filename
    local file
    RG_PREFIX="ag -l"
	file="$(
        INITIAL_QUERY="."
		FZF_DEFAULT_COMMAND="$RG_PREFIX -G '$filename' $INITIAL_QUERY ${searchdir} 2>/dev/null" \
			fzf --multi --sort --preview="[[ ! -z {} ]] && rg -A 5 -N -p {q} {}" \
                --phony \
                -q $INITIAL_QUERY \
				--bind "change:reload:$RG_PREFIX -G '$filename' {q} ${searchdir} || true" \
				--preview-window="70%:wrap" \
                --ansi
	)" &&
	echo "opening $file" &&
	kitty -1 vim "$file" 2>/dev/null
}
getgridsize() {
    local gridsize
    gridsize=$(yabai -m rule --list | jq -r '.[] | select(.title | contains("applauncher")).grid' | sed -E 's/([[:digit:]]+).+/\1/')
    echo ${gridsize}
}
focusnext() {
    local window_no_focus=($(
    yabai -m query --windows --space | \
        jq -r '.[] | select((."has-focus"==false) and (."is-floating"==false)).id' \
        )) && yabai -m window --focus ${window_no_focus[0]}
}
toggle_fs() {
    local isfloat=$(getwindowstatus)
    if [ "$isfloat" = true ]; then
        toggle_window_float
    fi
    yabai -m window --toggle $1
}
adjustgridsize() {
    echo "$(
cat << EOF
${BLUE}
# ADJUST WINDOW SIZE
################################################################################
${ORANGE}
== Command List ==
${GREEN}
+/k     : Increase Window Size
-/j     : Decrease Window Size
f       : Full Screen
z       : Zoom Parent
q/<Esc> : Exit
${BLUE}
################################################################################
${NC}
EOF
)"
    gridsize=$(getgridsize)
    local gridparams
    while true; do
        read -n 1 userchoice
        case "$userchoice" in
            "+"|k) newgridsize="$((gridsize+1))";;
            "-"|j) newgridsize="$((gridsize-1))";;
            f) toggle_fs "zoom-fullscreen";break;;
            z) toggle_fs "zoom-parent";break;;
            q|$'\e'|"") break;;
            *) ;;
        esac
        gridsize="$((newgridsize > 2 ? newgridsize : gridsize))" 
        windowgrid="$((gridsize-2))" 
        gridparams="$gridsize:$gridsize:1:1:$windowgrid:$windowgrid"
        yabai -m window --grid $gridparams
    done
    clear >$(tty)
    #yabai -m rule --remove $(yabai -m rule --list | jq -r '.[] | select(.title | contains("applauncher")).id') && echo $gridparams && \
        #yabai -m rule --add title='^applauncher$' manage=off sticky=on layer=above grid=$gridparams
}
fff() {
    filename=$(findfiles)
    local file
    RG_PREFIX="ag -l"
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
    $FD_PREFIX . "$GDIR" | fzf --preview="bat {}"|| echo "$GFILE" \
        --preview-window="70%:wrap" \
        --ansi
	)" && echo $file
}
findfiles() {
    local file
    local searchdir=$GDIR
    INITIAL_QUERY="."
    FD_PREFIX="fd -H -t f -a"
    file="$(
        INITIAL_QUERY="."
        FZF_DEFAULT_COMMAND="$FD_PREFIX $INITIAL_QUERY ${searchdir} 2>/dev/null" \
            fzf --multi --preview="bat {}" \
            --phony \
            -q '' \
            --bind "change:reload:$FD_PREFIX {q} ${searchdir} || true" \
            --bind "enter:select-all+accept" \
            --preview-window="70%:wrap" \
            --ansi \
            --header="Searching by Filename"
        )" && echo ${file}
}

runcmd() {
    local cmdname
    HISTFILE=~/.zsh_history
    set -o history
    cmdname="$(history | sed -E 's/([[:digit:]]+).+;(.+)/\1 :\2/' | \
        fzf --tiebreak=begin,index --tac)" && \
        kitty -1 -d ~ zsh -c $(which $(echo "${cmdname}" | sed -E 's/.+:(.+)/\1/')) 
        read -n 1 -p "press any key to continue" waitusr
        #zsh -i -c "$(which $(echo "${cmdname}" | sed -E 's/.+:(.+)/\1/'))";
        #zsh -c $(which $(echo "${cmdname}" | sed -E 's/.+:(.+)/\1/')); \
        #kitty -1 -d ~ zsh -c $(which $(echo "${cmdname}" | sed -E 's/.+:(.+)/\1/')) 
        #kitty -1 -d ~ $(which $(echo "${cmdname}" | sed -E 's/.+:(.+)/\1/')) 

        #if [[ $cmdname == *.py ]] 
        #then
        #    kitty -1 -d ~ python $(which $(echo "${cmdname}" | sed -E 's/.+:(.+)/\1/')) 
        #else
        #    kitty -1 -d ~ sh -c $(which $(echo "${cmdname}" | sed -E 's/.+:(.+)/\1/')) 
        #fi

        #kitty -1 -d ~ 'export PATH='"$PATH";"$(echo "${cmdname}" | sed -E 's/.+:(.+)/\1/')" 

#72 : 1642221304:0;addintake.py
    #cmdname=$(history | fzf --tiebreak=begin,index --tac| sed -E 's/([[:digit:]]+).+;(.+)/\1 \2/') && echo $cmdname
    }

changedir() {
    read -n 1 -p "Please Enter new Dir (? for search) : " inputdir
    clear >$(tty)
    case "$inputdir" in
        "?") inputdir=$(finddir);;
        "/"|r) inputdir=/;;
        h|""|"~") inputdir=~;;
        p) inputdir=~/Programming;;
        d) inputdir=~/Downloads;;
        *) inputdir=$GDIR;;
    esac
    echo $inputdir
}
finddir() {
    local file
    INITIAL_QUERY=""
    FD_PREFIX="fd -H -t d -a"
    file="$(
    $FD_PREFIX . "$GDIR" | fzf --header="Searching for Dir..."|| echo "$GDIR"
	)" && echo $file
}
opendir() {
    local file
    FD_PREFIX="fd -H -t d -a"
    file="$(
    $FD_PREFIX . "$GDIR" | fzf --header="Searching Directory Name..."
	)" && kitty -1 -d $file
}
ch() {
  local cols sep
  cols=$(( COLUMNS / 3 ))
  sep='{::}'

  cp -f ~/Library/Application\ Support/BraveSoftware/Brave-Browser/Default/History /tmp/h

  sqlite3 -separator $sep /tmp/h \
    "select substr(title, 1, $cols), url
     from urls order by last_visit_time desc" |
  awk -F $sep '{printf "%-'$cols's  \x1b[36m%s\x1b[m\n", $1, $2}' |
  fzf --ansi --multi | sed 's#.*\(https*://\)#\1#' | xargs open
}
google() {
    read -n 1 -p "Region Settings : (e/j) : " reg
    case "$reg" in
        "") lang=en;tld=us;;
        e) lang=en;tld=us;;
        j) lang=jp;tld=jp;;
    esac
    googler -l $lang -g $tld -c $tld
}
brewinstall() {
    read -p "Homebrew Formula : " hbfml
    brew install ${hbfml}
}
brewinstallcask() {
    read -p "Homebrew Formula : " hbfml
    brew install --cask ${hbfml}
}
manual() {
    read -p "Open Manual For Command : " cmdname
    man ${cmdname}
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
while true; do
    show_prompt
    case "$userchoice" in
        #a) fa;exit;; #Open App
        #A)
        b) brewinstall;printfinished;; #Homebrew
        B) brewinstallcask;printfinished;; #Homebrew
        c) ssh cointop.sh;; #Crypto
        #C) GDIR=$(changedir);printvals;; #change dir
        d) broot -w $GDIR;; #Disk Space
        D) $HOME/Programming/c/donut;; 
        #e
        #E
        f) toggle_window_float;; #Toggle window status
        #F)
        g) google;; # Google
        #G
        #h) ch;break;; #Get history
        #H
        i) neofetch;read -n 1 tmpvar;;
        #I
        #j
        #J
        k) insect; printfinished;;
        #K
        #l
        #L
        #m) manual;; #Open man page
        #M
        #N
        #o)
        #O
        #l) runcmd;;
        p) vtop;; #show htop process
        P) htop;; #show vtop process
        q|$'\e') break;;
        #Q
        r) adjustgridsize;; #Resize window size
        #R) ranger $GDIR;break;; #ranger FM
        s) sc-im;;
        #S
        t) broot -s $GDIR;;
        #T
        #u
        #U
        #v) printvals;; #Show current Dir
        #v) vim $(findfile);\ #find file and open with vim break;;
        w) curl wttr.in/$CURCITY;read -n 1 tmpvar;;
        #x
        #X
        #y
        #Y
        #z
        Z) ;;
        "") /bin/zsh;;
    esac
    clear >$(tty)
done 
#yabai -m query --windows --space | jq -r '.[] | select((."has-focus"==false) and (."is-floating"==false)).id'
focusnext
