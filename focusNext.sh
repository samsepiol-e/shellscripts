#!/bin/bash
#appName="Brave Browser"
#currIdx=1
lastId=$(yabai -m query --windows --window stack.last | jq -r '.id')
currentId=$(yabai -m query --windows --window | jq -r '.id')
if [ $currentId == $lastId ]; then
    #echo $(yabai -m query --windows --window stack.first | jq -r '.id')
    yabai -m window --focus $(yabai -m query --windows --window stack.first | jq -r '.id')
else
    #echo $(yabai -m query --windows --window stack.next | jq -r '.id')
    yabai -m window --focus stack.next
fi
