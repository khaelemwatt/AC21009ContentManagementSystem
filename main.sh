#! /bin/bash

#--------------DOCUMENTATION--------------
#This script is the starting point and displays the main menu for the repository 
#either prompting the user to create a new repository or load a pre existing one in

#--------------CONSTANTS--------------

source constants.sh

#--------------START UP--------------

#Initialise the current variable to track the current users option
current=1

#clear terminal
clear

#print the menu
./printMenu.sh $current "Create New Repository" "Load Repository" Exit

#--------------MAIN LOOP--------------

while true; do

	#Get input from user and read it from a temp file
	./getKey.sh; key=$(cat $keyFile)

	#checks to see what key was pressed by user and will eiher update the users current menu
	#position, exits the program or executes a script
	case $key in
		#Go up in the menu or back to the bottom if you were at the top
		$UP) if [ $current -gt 1 ]; then current="$((current-1))"; else current=3; fi;;

		#Go down in the menu or back to the top if you were at the bottom
		$DOWN) if [ $current -lt 3 ]; then current="$((current+1))";else current=1; fi;;

		#Depending on the current selection, execute the corresponding script
		$ENTER) case $current in
					1) ./select.sh new.sh;;
					2) ./select.sh load.sh;;
					3) setterm -cursor on	
					   exit 0;;
					   
				esac;;

		#Handles all unknown inputs
		*) printf "${RED}Unknown input${END}\n";;
	esac

	#redisplays menu with updated information
	./printMenu.sh $current "Create New Repository" "Load Repository" Exit

done