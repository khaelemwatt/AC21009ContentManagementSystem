#! /bin/bash

#--------------DOCUMENTATION--------------
#This is the main menu for the user when they have loaded a valid repository
#
#INPUT PARAMETERS
#$1 - Current filepath - Repository

#--------------CONSTANTS--------------

source constants.sh

#--------------START UP--------------

#get the current path (i.e repository)
path=$1

dirName="$(basename "$path")"

#Initialise the current variable to track the current users option
current=1

#clear terminal
clear

#Print Repository name and options menu
printf "${GREEN}REPOSITORY - $dirName${END}\n"
./printMenu.sh $current "Add file" "Create File" "Checkout file" "Zip Repository" "Exit Repository"

#--------------MAIN LOOP--------------

while true; do

	#Get input from user and read it from a temp file
	./getKey.sh; key=$(cat $keyFile)

	#Checks to see what key was pressed by user and will eiher update the users current menu
	#position, perform the next task or exit the script
	case $key in
		#Go up in the menu or back to the bottom if you were at the top
		$UP) if [ $current -gt 1 ]; then current="$((current-1))"; else current=5; fi;;

		#Go down in the menu or back to the top if you were at the bottom
		$DOWN) if [ $current -lt 5 ]; then current="$((current+1))";else current=1; fi;;

		#Depending on the current selection, perform the corresponding task
		$ENTER) case $current in
					1) ./select.sh add.sh;;
					2) read -p "File name: " fileName; touch "$path/latest/$fileName"; touch "$path/working/$fileName"; touch "$path/logs/$fileName"; touch "$path/patches/$fileName"; touch "$path/.users/.$fileName";clear ;;
					3) ./select.sh checkout.sh $path/latest;;
					4) ./select.sh zip.sh;;
					5) exit 0;;	
					*) printf "${RED}Unknown input${END}\n";;			   
				esac;;

		#Handles all unknown inputs
		*) printf "${RED}Unknown input${END}\n";;
	esac


	#Redisplays menu with updated information
	printf "${GREEN}REPOSITORY - $dirName${END}\n"
	./printMenu.sh $current "Add file" "Create File" "Checkout file" "Zip Repository" "Exit Repository"

done