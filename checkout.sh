#! /bin/bash

#--------------DOCUMENTATION--------------
#This is the main menu the user will use once they have checked out a file
#This handles all the permissions and filehandling associated with checking out a file
#making it unwritable to any other user besides the one who has checked it out
#It will allow the user to open the file in vim to edit the file, save it, patch it
#to the current working folder (master branch equivalent) or exit and check the file
#back in
#
#INPUT PARAMETERS
#$1 - File path to the file currently checked out by the user

#--------------CONSTANTS--------------

source constants.sh

#--------------FUNCTIONS--------------

#Compares a new file to its previous versions and saves the changes to a patch file and makes a log entry
saveChange () {
    file="$1"
    oldFile="$2"
    logFile="$3"
    patchFile="$4"
    diff -u $oldFile $file > $patchFile # finds differences between original file and new file since last patch and sends to patch file
    printf "What changes did you make to the file?\n" # takes in users change summary
    read changes
    echo "--------------------------------------------------" >> $logFile
    echo "Edited by: UID-$UID USERNAME-$USER" >> $logFile # takes users name and sends to log file
    echo "Changes made: $changes" >> $logFile # takes users change summary and sends to log file
    echo "Date of edit: $(date)" >> $logFile # takes date of edit and sends to log file
    cat $patchFile >> $logFile # takes differences between files and sends to log file
    clear;
}

#Will  add a log entry when the file is checked in and out
logCheck () {

    mode=$1
    logFile=$2

    if [[ $mode = in ]]; then
        echo "--------------------------------------------------" >> $logFile
        echo "Checked back in by: UID-$UID USERNAME-$USER" >> $logFile
        echo "Date checked back in:" $(date) >> $logFile
    else
        echo "--------------------------------------------------" >> $logFile
        echo "Checked out by: UID-$UID USERNAME-$USER" >> $logFile
        echo "Date of checkout:" $(date) >> $logFile
    fi

}

#--------------MAIN PROGRAM--------------

#Initialise the current variable to track the current users option
current=1

#turn cursor blink off
printf "\033[?25l"

path=$1
rootPath="$(dirname ${path%/*})"
name="$(basename $path)"

file="${rootPath}/latest/$name"
oldFile="${rootPath}/working/$name"
logFile="${rootPath}/logs/$name"
patchFile="${rootPath}/patches/$name"
fileUser=$(cat $rootPath/.users/.$name)

#if the file is already checked out and its not the current user that checked it out, display error and exit
if [[ $UID -ne $fileUser ]]; then if [[ -w $file ]]; then echo $UID > "$rootPath/.users/.$name"; chmod ugo-w $file; logCheck out $logFile; else printf "${RED}This file has already been checked out by another user${END}\n"; printf "Press any key to continue...\n"; read; clear; exit 0;fi ; fi

#clear terminal
clear

#Print the menu to the user
./printMenu.sh $current Edit Save Patch "Remove File" "Exit (Check file back in)
"
while true; do

    #Get input from user and read it from a temp file
    ./getKey.sh; key=$(cat $keyFile)

    #checks to see what key was pressed by user and will eiher update the users current menu
    #position, exits the program or enters into a new menu choice
    case $key in
        #Go up in the menu or back to the bottom if you were at the top
        $UP) if [ $current -gt 1 ]; then current="$((current-1))"; else current=5; fi;;

        #Go down in the menu or back to the top if you were at the bottom
        $DOWN) if [ $current -lt 5 ]; then current="$((current+1))";else current=1; fi;;

        #Depending on the current selection, perform the corresponding task
        $ENTER) case $current in
                    1) chmod u+w $file; nano $file; chmod u-w $file;;
                    2) saveChange $file $oldFile $logFile $patchFile;;
                    3) printf "${RED}Warning:${END} Once you patch this file, the working file will be updated with the latest file\n"
                    echo "Do you still wish to continue?"

                    #Mini menu for confirmation of patch
                    smallCur=1; ./printMenu.sh $smallCur Yes No
                    while true; do
                        ./getKey.sh; smallKey=$(cat $keyFile)
                        case $smallKey in
                            $UP) if [[ $smallCur -gt 1 ]];then smallCur="$((smallCur-1))"; else smallCur=2; fi;;
                            $DOWN) if [[ $smallCur -lt 2 ]]; then smallCur="$((smallCur+1))"; else smallCur=1; fi;;
                            $ENTER) case $smallCur in
                                        1)patch -ruN $oldFile < $patchFile;clear; echo "--------------------------------------------------" >> $logFile;
																				  echo "Patched to working By: UID-$UID USERNAME-$USER" >> $logFile
																				  echo "Date Patched:" $(date) >> $logFile; break;;
                                        2)break;;
                                        *)printf "${RED}Unknown input${END}\n";;
                                    esac;;
                            *) printf "${RED}Unknown input${END}\n";;
                        esac
                        printf "${RED}Warning${END}: Once you patch this file, the working file will be updated with the latest file\n"
                        echo "Do you still wish to continue?"
                        ./printMenu.sh $smallCur Yes No;done ;;
                        
                    4) ./removeFile.sh $file;exit 0;;
					5) chmod ugo+w $file; logCheck in $logFile; echo "" > "$rootPath/.users/.$name"; exit 0;;
                    *) printf "${RED}Unknown input${END}\n";;
                       
                esac;;

        #Handles all unknown inputs
        *) printf "${RED}Unknown input${END}\n";;
    esac


    #redisplays menu with updated information
    ./printMenu.sh $current Edit Save Patch "Remove File" "Exit (Check file back in)"

done