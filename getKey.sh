#! /bin/bash

#--------------DOCUMENTATION--------------
#This script is used to get an input key from the user
#It will get an input and then write that input to a hidden file
#in the main scripts location so that the script that needs the input
#can read the input in from the hidden file. 
#This script is used to reduce clutter and centralise input getting (especially
#in the checkout.sh function where there is a menu inside a  menu in the "patch" option)

#--------------CONSTANTS--------------

source constants.sh

#--------------MAIN PROGRAM--------------

#trap 'echo resize; read' SIGWINCH

#Turn cursor blink off
printf "\033[?25l"

#Clear input buffer
while read -r -t 0; do read -r; done 

#Read in 3 characters from the users input

read -sn 3 key

#Will check if the key is 3 characters long (i.e up or down arrow)
#and will strip the first two characters "\[A" --> "A" if so
#if not, it is the enter key
if [ "${#key}" -eq 3 ]; then key=${key:2}; fi

#Clear terminal
clear

#Send the users input to a hidden file to be read from 
echo $key > $keyFile

exit 0;