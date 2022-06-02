#! /bin/bash

#--------------DOCUMENTATION--------------
#This script is used to remove a file from the repository
#JAssumes that the file is no longer needed so will completely remove ALL 
#associated files
#Doesnt require any validation besides if it is checked out because the select
#will always return a valid file in the repository
#INPUT PARAMETERS
#$1 - file to remove from reposiotry

#--------------CONSTANTS--------------

source constants.sh

#--------------MAIN PROGRAM--------------

file=$1
filename="$(basename $file)"
repo="$(cat .tmp)"
fileUser=$(cat $repo/.users/.$filename)

printf "${RED}WARNING:${END} Removing the file permanently removes all files from the repoisotry\n"
printf "Do you still wish to continue?\n"
smallCur=1; ./printMenu.sh $smallCur Yes No
while true; do
    ./getKey.sh; smallKey=$(cat $keyFile)
    case $smallKey in
        $UP) if [[ $smallCur -gt 1 ]];then smallCur="$((smallCur-1))"; else smallCur=2; fi;;
        $DOWN) if [[ $smallCur -lt 2 ]]; then smallCur="$((smallCur+1))"; else smallCur=1; fi;;
        $ENTER) case $smallCur in
                    1)break;;
                    2)exit 0;;
                    *)printf "${RED}Unknown input${END}\n";;
                esac;;
        *) printf "${RED}Unknown input${END}\n";;
    esac
    printf "${RED}WARNING:${END} Removing the file permanently removes all files from the repoisotry\n"
	printf "Do you still wish to continue?\n"
    ./printMenu.sh $smallCur Yes No
done

#fix file permissions
if [[ $UID -eq $fileUser ]] || [[ $fileUser = "" ]]; then
	chmod ugo+w $repo/latest/$filename
	rm $repo/latest/$filename
	rm $repo/working/$filename
	rm $repo/logs/$filename
	rm $repo/patches/$filename
	rm $repo/.users/.$filename
else
	printf "${RED}Cannot Delete File${END}\n"
	printf "File is currently checked out by another user\n"
	printf "Press any key to continue..."
	read
	clear
	exit 0
fi

printf "File ${CYAN}${filename}${END} deleted from reposiotry\n"
printf "Press any key to continue..."
read
clear