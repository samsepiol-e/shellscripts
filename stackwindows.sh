#!/bin/bash

appName=$(yabai -m query --windows --window | jq -r '.app')
echo '"'"$appName"'"'
for wid in $(yabai -m query --windows --space | jq -r '.[] | select((."has-focus"==false) and (.app==''"'"$appName"'"'')).id'); do 
    yabai -m window --stack $wid
done
