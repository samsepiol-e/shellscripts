#!/bin/zsh

runcmd() {
    HISTSIZE=10000
    fc -R ~/.zsh_history
    fc -l -10000 | fzf --tiebreak=begin,index --tac | awk '{$1=""; print $0}' | zsh -i
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

# =======================================================================
# == FZF Search Epub
# =======================================================================
fif() {
	RG_PREFIX="rga --files-with-matches"
	local file
	file="$(
		FZF_DEFAULT_COMMAND="$RG_PREFIX '$1'" \
			fzf --sort --preview="[[ ! -z {} ]] && rga --pretty --context 5 {q} {}" \
				--phony -q "$1" \
				--bind "change:reload:$RG_PREFIX {q}" \
				--preview-window="70%:wrap"
	)" &&
	echo "opening $file" &&
	open "$file"
}
ff() {
    local file
    FD_PREFIX="fd -H -t file"
	file="$(
		FZF_DEFAULT_COMMAND="$FD_PREFIX '$1' ." \
			fzf --sort --preview="bat {}" \
                --phony -q "$1" \
				--bind "change:reload:$FD_PREFIX {q} ." \
				--preview-window="70%:wrap"
	)" &&
	echo "opening $file" &&
	open "$file"
}
fwf() {
    local file
    FD_PREFIX="fd -H -t file"
    RG_PREFIX="rg --files-with-matches"
	file="$(
		FZF_DEFAULT_COMMAND="$FD_PREFIX '$1' ." \
			fzf --sort --preview="[[ ! -z {} ]] && rg --pretty --context 5 {q} {}" \
				--bind "change:reload:$FD_PREFIX '$1' -x $RG_PREFIX {q} {}" \
				--preview-window="70%:wrap"
	)" &&
	echo "opening $file" &&
	open "$file"
}

case "$1" in
    "") ;;
    runcmd) "$@"; exit;;
    fif) "$@"; exit;;
    ff) "$@"; exit;;
    ch) "$@"; exit;;
esac
