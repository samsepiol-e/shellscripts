#!/bin/bash
#appName="Brave Browser"
#currIdx=1
appName=$(yabai -m query --windows --window | jq -r '.app')
currIdx=$(yabai -m query --windows --window | jq -r '."stack-index"')
maxIdx=$(yabai -m query --windows --space | jq -r '[.[] | select(.app==''"'"$appName"'"'')."stack-index"] | max')
nextIdx=$(($currIdx % $maxIdx+1))
nextId=$(yabai -m query --windows --space | jq -r '.[] | select((.app==''"'"$appName"'"'') and ."stack-index"=='${nextIdx}').id')
yabai -m window --focus ${nextId}
