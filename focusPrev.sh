#!/bin/bash
#appName="Brave Browser"
#currIdx=1
firstId=$(yabai -m query --windows --window stack.first | jq -r '.id')
currentId=$(yabai -m query --windows --window | jq -r '.id')
if [ $currentId == $firstId ]; then
    #echo $(yabai -m query --windows --window stack.first | jq -r '.id')
    yabai -m window --focus $(yabai -m query --windows --window stack.last | jq -r '.id')
else
    #echo $(yabai -m query --windows --window stack.next | jq -r '.id')
    yabai -m window --focus stack.prev
fi
