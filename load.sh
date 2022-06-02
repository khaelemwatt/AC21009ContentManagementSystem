#! /bin/bash

#--------------DOCUMENTATION--------------
#This script will check if the current filepath is a valid repository
#by checking for 4 folders that are made upon repository creating and
#if these folders exist (i.e filepath is a valid repository) it will
#load the repository menu for the users
#
#INPUT PARAMETERS
#$1 - Current filepath

#--------------CONSTANTS--------------

source constants.sh

#--------------MAIN PROGRAM--------------

#get path selected in select script 
path=$1 

#Make sure directory contains the directories necessary for a valid repository
if [ -d "$path/latest" ] && [ -d "$path/logs" ] && [ -d "$path/patches" ] && [ -d "$path/working" ]; then
	#Print the directory to an external temp file. This is only needed when adding an existing file
	#or zipping the archive. This is because the select.sh function already sends in a path (path to file to add
	#or path to zip the directory to)
	echo "$path" > $tempFile
	./repoMenu.sh "$path"
else
	printf "${RED}The directory you selected is not a valid repository${END}\n"
	echo "Press any key to continue..."
	read
	clear
fi