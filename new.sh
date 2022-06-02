#! /bin/bash

#--------------DOCUMENTATION--------------
#This script will reate a new repository in the current filepath
#Will not let the user create a repository if a directory/repoistory
#of the same name exists in the current filepath. Will keep asking for a 
#valid rrepository name
#
#INPUT PARAMETERS
#$1 -Current filepath

#--------------CONSTANTS--------------

source constants.sh

#--------------FUNCTIONS--------------

#If the repository name is already taken it will prompt the user to either rename their
#repository or will exit the creation of a repository
function choiceMenu {

	#Initialise the current variable to track the current users option
	current=1

	#print the menu
	./printMenu.sh $current Rename Exit

	while true; do

		#Get input from user and read it from a temp file
		./getKey.sh; key=$(cat $keyFile)

		#Checks to see what key was pressed by user and will eiher update the users current menu
		#position, perform the next task or exit the script
		case $key in
			#Go up in the menu or back to the bottom if you were at the top
			$UP) if [ $current -gt 1 ]; then current="$((current-1))"; else current=2; fi;;

			#Go down in the menu or back to the top if you were at the bottom
			$DOWN) if [ $current -lt 2 ]; then current="$((current+1))";else current=1; fi;;

			#Depending on the current selection, perform the corresponding task
			$ENTER) case $current in
						1) path="${path%/*}";
						   break;;
						2) exit 0;;
					esac;;

			#Handles all unknown inputs
			*) printf "${RED}Unknown Input${END}\n";;
		esac
		
		#redisplays menu with updated information
		echo $path
		echo -e "${RED}A repository of the name ${END}${CYAN}$repository${END}${RED} already exists in this directory${END}"
		./printMenu.sh $current Rename Rxit
		done	
}


#--------------START UP--------------
path=$1 #get path selected in select script 

#--------------MAIN LOOP-------------

while true; do

	#clear input buffer
	while read -r -t 0; do read -r; done 

	clear
	echo $path

	echo Please enter a name for the new repository: 
	read repository

	path+=/$repository
	echo $path

	#if direcrory is not successfully created 
	#error message redirected to null
	if ! mkdir $path 2>/dev/null
	then
		clear
		echo $path
		echo -e "${RED}A repository of the name ${END}${CYAN}$repository${END}${RED} already exists in this directory${END}"
		choiceMenu
	else
		break
	fi	

done

#make repository readable to other 
chmod ugo=rwx $path

mkdir $path/logs
mkdir $path/working
mkdir $path/latest
mkdir $path/patches

#hidden folder used to store files that tell the sysetm which user has checked out a file
mkdir $path/.users


#prompt user that directory was successfuly created 
clear
echo -e "Repository ${CYAN}$repository${END} created successfully"
echo "Press any key to continue..."
read
clear

#return to main menu
exit 0