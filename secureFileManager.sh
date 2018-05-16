#!/bin/bash
###############################################################
#	                                                      |
#                                                             |
#	          Secure File Manager                         |
#                                                             |
#	                                                      |
###############################################################
	
       ## If gpg is not installed, exit and let user know it is required
	#
gpg --version >/dev/null || { echo "This program requires gpg"; exit 1; }
createDir() {
       ## Check if the SFS-GPG dir exists, if not, create it
	#
	if [ ! -d ~/Documents/SFS-GPG ]; then
		mkdir ~/Documents/SFS-GPG
		echo "Created ~/Documents/SFS-GPG"
		sleep 2
	fi
       ## After checking/creating, run the intro function
        #
	intro
}
createFile(){
       ## User creates filename that will be encrypted
	#
	echo "Enter a filename"
	read temp
       ## If entry is null, return to main menu
	#
 	if [ -z $temp ]; then
		echo -e "\nEntry was null, Returning to main menu"
		sleep 2
		intro
	fi	
       ## If filename has a space, replpace it with an underscore
	#
	file=$(echo $temp | tr ' ' '_')
       ## Ask user to input a phrase twice
	#
	while [ -z "$data" ]; do 
		echo "Enter a string"
		read data
	done
	echo "Repeat the string"
	read repeatData
       ## Check both entries match
	#
	while [ $data != $repeatData ]; do 
		echo "Strings did not match. Enter again"
		read repeatData
	done
       ## Create file with filename and push the data to the file, then move to right dir
	#
	touch $file.txt; echo $data > $file.txt
	mv $file.txt ~/Documents/SFS-GPG
       ## Have user enter a master password to secure the file
	#
	clear
	echo -e "Enter a Master Password to secure\n"
	gpg -c ~/Documents/SFS-GPG/"$file.txt"
	rm ~/Documents/SFS-GPG/"$file.txt"
	echo "Done!"
	sleep 2
       ## Clear gpg-agent cache and run the intro() again when finished
        #
	pkill -SIGHUP gpg-agent
	intro
}
viewFile(){
       ## List all files in the SFS-GPG dir so the user can choose which one to view
        #
	ls ~/Documents/SFS-GPG
       ## Make sure the user makes a valid coice
        #
	echo -e "\nChoose a file"
	read file
        while [ ! -e ~/Documents/SFS-GPG/$file* ]; do	
		echo -e "\nPlease choose an existing file"
		read file
	done
       
       ## Ensure $file isnt empty then decrypt the file. This will print the contents
      	# to the terminal, then wait for the user to exit. 
	#
	if [ ! -z "$file" ]; then
		gpg --decrypt ~/Documents/SFS-GPG/$file*
		echo -e "\nPress any key to continue"; read ;
	else 
		echo -e "\nEntry was null. Returning to main menu"
		sleep 2
	fi
	clear; clear;
       ## Clear gpg-agent cache and run intro() after finishing
        #
	pkill -SIGHUP gpg-agent
	intro
}
removeFile(){
       ## List files that can be deleted
        #
	ls ~/Documents/SFS-GPG/
       ## Make sure it is a valid filename
        #
	echo -e "\nEnter a filename"
	read file
	while [ ! -e ~/Documents/SFS-GPG/$file* ]; do
		echo -e "\nPlease choose an existing file"
		read file
	done
       ## Ensure choice isnt null or else all files will be removed
        #
	if [ ! -z $file ]; then
		rm ~/Documents/SFS-GPG/$file*
        	echo -e "\nRemoved!"
        	sleep 2
	else 
		echo -e "\nEntry was null. Returning to main menu"
		sleep 2
	fi
	intro
}

intro(){
       ## Main screen for the user to interact with
	#
	clear
	echo "##########################################################################
#                       Secure File Storage                              #
#                                                                        #
#                     Create a unique filename                           #
#                       Add some information                             # 
#                     And encrypt it with GPG!                           #
#                                                                        #
##########################################################################"

       ## Choices for user
        # 
	echo -e "\n(1) View file"
	echo "(2) Create a new file"
	echo "(3) Remove a file"
	echo "(4) Exit"
	read choice

	case $choice in	
		1) clear; viewFile ;;
		2) clear; createFile ;;
		3) clear; removeFile ;;
		# exit and clear gpg cache if passwords are cached
		4) pkill -SIGHUP gpg-agent; clear; exit 1 ;;
		*) clear; intro ;;
	esac
}
createDir

