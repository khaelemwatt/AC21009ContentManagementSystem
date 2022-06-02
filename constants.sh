#! /bin/bash

#--------------DOCUMENTATION--------------
#This script contains a list of all constants used throughout the project
#This is just to help cleanup the code so there isnt a massive section at
#the top of each script containing these constants

#--------------CONSTANTS--------------

#Constants used throughout the menu for keys, text formatting or hidden files
readonly CYAN=$"\e[1;36m"
readonly GREEN=$"\e[1;32m"
readonly RED=$"\e[1;91m"
readonly INVERT="$\e[7m"
readonly END=$"\033[0m"
readonly UP="A"
readonly DOWN="B"
readonly RIGHT="C"
readonly LEFT="D"
readonly ENTER=""
readonly keyFile=".keyFile"
readonly tempFile=".tmp"