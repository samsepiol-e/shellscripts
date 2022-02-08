#!/bin/zsh

find /System/Library/CoreServices /System/Applications /Applications /System/Applications/Utilities -maxdepth 1 -name "*.app" | fzf --tiebreak="begin,end,index" | xargs -I {} open "{}"
