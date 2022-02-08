#!/bin/bash
clear>$(tty)
for file in "$@"
do
    echo "$file" && \
        kitty +kitten icat "$file"
done

#echo -e "\033[6A" 

