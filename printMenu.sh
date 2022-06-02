#! /bin/bash

#--------------DOCUMENTATION--------------
#This script displays a menu of choices to the user and highlights
#their currnt choice
#
#INPUT PARAMETERS
#$1 - Current option selected. This is so that the menu knows
#which item to highlight
#$2 and onward - Options to be displayed to the user

#--------------CONSTANTS--------------

source constants.sh

#--------------MAIN PROGRAM--------------

#Variable used in the loop to detect what option the user has selected
counter=1

#Users current selection
current=$1

#Loops through all the provided menu choices and displays formatting on the one the
#used is currently on
for i in "${@:2}"
do
	if [ "$counter" -eq "$current" ]; then printf "${CYAN}$i <${END}\n"; else printf "${CYAN}$i${END}\n"; fi
	counter="$((counter+1))"
done

echo -ne "\033[6n"            
read -s -d \[ escape
read -s -d "R" cursorPos

cursorPos=${cursorPos:0:1}

rows=$(tput lines)
bottom=$(($rows-$cursorPos))

printf "\033[${bottom}B\033[7mArrow Keys${END} Navigate Menu  \033[7mEnter${END} Select Choice"

exit 0;