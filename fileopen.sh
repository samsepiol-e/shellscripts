#!/bin/zsh
openimg(){
    echo "$1"
    kitty +kitten icat "$1"
}

openpdf(){
    nohup zathura "$1" &
}

openvideo(){
    nohup mpv "$1" &
}

for fullfile in "$@"
do
    filename=$(basename -- "$fullfile")
    extension=${${filename##*.}:l}
    case $extension in 
        "jpg"|"jpeg"|"gif"|"png"|"JPG"|"JPEG"|"PNG")openimg "${fullfile}";;
        "pdf")openpdf "${fullfile}";;
        "mp4"|"webm")openvideo "${fullfile}";;
        "csv")tv -a -t 1 -n 100 "${fullfile}" | bat;;
        *)open "${fullfile}";;
    esac
done
    
