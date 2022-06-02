#! /bin/bash

#--------------DOCUMENTATION--------------
#This function is used to zip the repository to a
#specified location

#--------------CONSTANTS--------------

source constants.sh

#--------------MAIN PROGRAM--------------

clear

path=$1

repository=$(cat $tempFile)
repositoryName=$(basename $repository)

cd $repository/..

zip -r $path/$repositoryName.zip $repositoryName

echo "Repository archived successfully at $path"
echo "Press any key to continue..."
read
clear