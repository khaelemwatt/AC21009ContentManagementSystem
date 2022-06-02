#! /bin/bash

#--------------DOCUMENTATION--------------
#This script handles adding an external file into the repository
#It will make sure there are no files of the same name and it will
#also add the required files and hidden files in the repository
#
#INPUT PARAMETERS
#$1 - Filepath to the file to add

#--------------CONSTANTS--------------

source constants.sh

#--------------FUNCTIONS--------------

#Rename and save a file 
function rename {
	while true; do
		clear

		echo "Please enter a new name for the file: "
		read new
		clear

		if [ -e $repository/latest/$new ]; then
			echo -e "A file of the name ${CYAN}$file${END} already exists in the repository"
			echo "Press any key to continue..."
			read
			clear
		else
			file=$new
			break
		fi
	done

	cp "$path" $repository/latest/$file

	clear
}

#If a file of the same name already exits in the current repository, gives the user
#the choice to rename, replace or cancel.
function choiceMenu {

	current=1


	./printMenu.sh $current Rename Replace Cancel

	while true; do
		
		#Get input from user and read it from a temp file
		./getKey.sh; key=$(cat $keyFile)

		#checks to see what key was pressed by user and will eiher update the users current menu
		#position, exits the program or enters into a new menu choice
		case $key in
			#Go up in the menu or back to the bottom if you were at the top
			$UP) if [ $current -gt 1 ]; then current="$((current-1))"; else current=3; fi;;

			#Go down in the menu or back to the top if you were at the bottom
			$DOWN) if [ $current -lt 3 ]; then current="$((current+1))";else current=1; fi;;

			#Depending on the current selection, perform the corresponding task
			$ENTER) case $current in
						1) rename
						   break;;
						2) cp -f "$path" $repository/latest
						   break;;
						3) exit 0;;
					esac;;

			#Handles all unknown inputs
			*) printf "${RED}Unknown Input${END}\n";;
		esac
		
		#redisplays menu with updated information
		echo -e "A file of the name ${CYAN}$file${END} already exists in this repository"
		./printMenu.sh $current Rename Replace Cancel
		done
	
}

#--------------MAIN PROGRAM--------------
path=$1 #get path selected in select script

file=$(basename "$path")

repository=$(cat $tempFile)

#Detects if the file already exists in the repository
if [ -e $repository/latest/$file ]; then
	echo -e "A file of the name ${CYAN}$file${END} already exists in this repository"
	choiceMenu
else
	cp "$path" $repository/latest
fi

#Creates additioal files required for the repository to work
touch $repository/logs/$file
touch $repository/patches/$file
touch $repository/working/$file
touch $repository/.users/.$file

logFile="$repository/logs/$file"

#Updates the files newly created log file to say it has been created
echo "--------------------------------------------------" >> $logFile
echo "Added By: UID-$UID USERNAME-$USER" >> $logFile
echo "Date Added:" $(date) >> $logFile

#Opens the checkout menu for the current file
./checkout.sh $repository/latest/$file

clear

exit 0