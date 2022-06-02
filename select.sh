#! /bin/bash

#--------------DOCUMENTATION--------------
#This script will be used whenever a user needs to select a file
#or directory by navigating through their file system.
#This function can handle all situations and is used by most other scripts
#to navigate through their file system and select directories or files for
#creating and loading repositories, creating new files in the repositories and
#loading in external files into the repository to name a few.
#
#INPUT PARAMETERS
#$1 - A script to call after the user has found the file/directory they want#
#This is used to call the next script in line and pass on the filepath to it
#It is also used to determine whether to show files and directories or just files
#$2 (OPTIONAL) - Filepath to start navigation from. This is used when inside the 
#repository as it prevents the user from navigating too far back and outside of
# the current repository otherwise the default path is just /home/$USER/ and the
#user won't be able to navigate further back than /home/$USER as well

#--------------CONSTANTS--------------

source constants.sh

#--------------PRE PROGRAM--------------

#Get the directory to start from
if [[ $2 = "" ]]; then path="/home/$(whoami)"; else path=$2; fi

#--------------FUNCTIONS--------------

#Used to display a formatted list of all the current files and/or directories in the 
#current filepath. Takes into account a number of factors including what script it is
#passing the file or directory to so it knows what formatting to do (colour directories
#dirrefernt from files, whether to display files at all, colour checked out files as red ect.)
function printDir {

	#Set up the current option and counetr
	counter=1
	current=$1
	repository=$(cat $tempFile)

	#Print out the name of the operation being carried out along with the current filepath
	case $operation in 
		add.sh) printf "${CYAN}ADD FILE${END} - ${path}\n";;
		new.sh) printf "${CYAN}CREATE REPOSITORY${END} - ${path}\n";;
		load.sh) printf "${CYAN}LOAD REPOSITORY${END} - ${path}\n";;
		zip.sh) printf "${CYAN}ZIP REPOSITORY${END} - ${path}\n";;
		checkout.sh) printf "${CYAN}CHECKOUT FILE${END}  - ${path}\n";;
		removeFile.sh) printf "${CYAN}REMOVE FILE${END} - ${path}\n";;
		*) echo "$path\n";;
	esac

	#Check which operation the user want to carry out
	if [[ $operation = add.sh ]] || [[ $operation = checkout.sh ]] || [[ $operation = removeFile.sh ]]
	then
		#Get a list of all files and directories inside the current filepath
		dirs=$(ls -l "$path" | tail -n +2 | awk '{$1=$2=$3=$4=$5=$6=$7=$8="";print $0}' | sed 's/^........//')
	else
		#Get a list of all directories in the current filepath
		dirs=$(ls -l "$path" | tail -n +2 | grep '^d' | awk '{$1=$2=$3=$4=$5=$6=$7=$8="";print $0}' | sed 's/^........//')
	fi

	if [[ $operation = checkout.sh ]] && [[ $dirNum -eq 0 ]]; then printf "${RED}No files in the repository${END}\nPress any key to continue...";read;clear;exit 0;fi

	#Checks to see whether the next script will be the checkout.sh script or not. This is because the checkout.sh will colour files currently checked out as red
	#So the user can see which files are checked out or not. The other times the files and/or directories are shown wont need these additional checks and formatting
	if [[ $operation = checkout.sh ]]
	then
		#If the user is trying to checkout a file, display all files in this list and check if they are checked out. If they are, display them as red
		while IFS= read -r i; do
	    	if [ $counter -eq $current ]
	    		#Show the user the option they are currently on. Make it red if it is checked out
	    		then if [[ "$(cat $repository/.users/.${i})" != "" ]] && [[ "$(cat $repository/.users/.${i})" -ne $UID ]]; then printf "${RED}$i ${CYAN}<${END}\n"; else printf "$i ${CYAN}<${END}\n"; fi; selection="$i"
	    	else 
	    		#Displays directories as green
	    		if [ -d "${path}/${i}" ]
	    			then printf "${GREEN}$i${END}\n"
	    		else
	    			#displays the other files as red, if they are checked out 
	    			if [[ "$(cat $repository/.users/.${i})" != "" ]] && [[ "$(cat $repository/.users/.${i})" -ne $UID ]]; then printf "${RED}$i${END}\n"; else printf "$i\n";fi
	    		fi
	    	fi
			counter="$((counter+1))"
		done <<< "$dirs"
	else
		while IFS= read -r i; do
			#Display the files and/or directories and highlight the users current option
	    	if [ $counter -eq $current ]; then if [[ -d "${path}/${i}" ]];then printf "${GREEN}$i ${CYAN}<${END}\n"; selection="$i";else printf "$i ${CYAN}<${END}\n"; selection="$i";fi ; else if [ -d "${path}/${i}" ]; then printf "${GREEN}$i${END}\n"; else printf "$i\n"; fi; fi
			counter="$((counter+1))"
		done <<< "$dirs"
	fi

	echo -ne "\033[6n"            
	read -s -d \[ escape
	read -s -d "R" cursorPos

	cursorPos=${cursorPos:0:1}

	rows=$(tput lines)
	bottom=$(($rows-$cursorPos))

	printf "\033[${bottom}B\033[7mArrow Keys${END} Navigate Menu / Navigate Through Directories  \033[7mEnter${END} Select Choice"

}

#--------------MAIN PROGRAM--------------

#Variable to store the next script to call (new.sh, load.sh ect)
operation=$1
#Initialise the current variable to track the current users option
current=1

#Variable to stop navigating back too many directories
dirNav=0;

#clear terminal
clear

#Update number of files and/or directories depending on next operation
if [[ $operation = add.sh ]] || [[ $operation = checkout.sh ]] || [[ $operation = removeFile.sh ]]
then
	#Gets number of files and directories in current filepath
	dirNum=$(ls -l "$path" | tail -n +2 | wc -l)
else
	#Gets number of directories in current filepath
	dirNum=$(ls -l "$path" | tail -n +2 | grep '^d' | wc -l)
fi

#Print out all files and/or directories in current fiepath
printDir $current $dirNum

while true; do

	#Get input from user and read it from a temp file
	./getKey.sh; key=$(cat $keyFile)

	#checks the users input and performs the corresponding task. Either navigates through the
	#list, goes forward or backwards in the file path or chooses the current selection
	case $key in
		#Go up in the menu or back to the bottom if you were at the top
		$UP) if [ $current -gt 1 ]; then current="$((current-1))"; else current=$dirNum; fi;;
		
		#Go down in the menu or back to the top if you were at the bottom
		$DOWN) if [ $current -lt $dirNum ]; then current="$((current+1))"; else current=1; fi;;
		
		#Navigate forward one directory
		$RIGHT) path="${path}/${selection}"; current=1; dirNav="$((dirNav+1))";;
		
		#Go back one directory but if the user tries to go back further than the initial directory, exit the file selection
		$LEFT) if [ $dirNav -gt 0 ]; then path="${path%/*}"; dirNav="$((dirNav-1))"; else exit 0; fi;;

		#Depending on whether or not we need a file or a directory, it will either select the current option or go forward
		#If we need to select a file (checking out for example), if you try to select a directory, it will just navigate
		#into it instead. Makes sure you select the right filetype
		$ENTER) path="${path}/${selection}"; if [[ $operation = checkout.sh ]]
											 then
											 	if [[ -f "$path" ]]; then ./"$operation" "$path"; exit 0; else current=1; fi
											 elif [[ $operation = add.sh ]]
											 	then
											 		if [[ -f "$path" ]]; then ./"$operation" "$path"; exit 0; else current=1; fi
											 else
											 	./"$operation" "$path"; exit 0
											 fi;;
		#Handles all unknown inputs
		*) printf "{RED}Unknown Input${END}";;
	esac

	#Update number of files and/or directories in new filepath depending on next operation
	if [[ $operation = checkout.sh ]] || [[ $operation = add.sh ]] || [[ $operation = removeFile.sh ]]
	then
		#Gets number of files and directories in currnt filepath
		dirNum=$(ls -l "$path" | tail -n +2 | wc -l)
	else
		#Gets number of directories in current filepath
		dirNum=$(ls -l "$path" | tail -n +2 | grep '^d' | wc -l)
	fi

	#Print out the files and/or directories in the new filepath
	printDir $current $dirNum

done