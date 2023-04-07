#!/bin/bash
#---------------------------------------------------------------------------
# Hash Compare (hashcomp.sh)                                               |
# Author: Rafael (rlim0x61)                                                |
# Date: 04/05/2023 (mm/dd/yyyy)                                            |
# Description: Analyze and compare two directories to detect file changes. |
# Usage: ./hashcomp.sh [dir1] [dir2] [hashing algorithm]			   	   |
# Version: 1.0                                                             |
#---------------------------------------------------------------------------

#BASH COLLORS
RED="\e[91m"
GREEN="\e[92m"
YELLOW="\e[93m"   
BLUE="\e[94m"
BOLDRED="\e[1;${RED}"
BOLDGREEN="\e[1;${GREEN}"
BOLDYELLOW="\e[1;${YELLOW}"
BOLDBLUE="\e[1;${BLUE}"
ENDCOLLOR="\e[0m"

#VARIABLES
RANDOM_NUMBER=`echo $[ $RANDOM % 1000 + 0 ]`
RESULTS=results-$RANDOM_NUMBER

#Start
mkdir $RESULTS
touch $RESULTS/diff.txt

#System Requirements
REQSARRAY=("coreutils" "libpopt0") #requirements array
for REQ in `echo ${REQSARRAY[@]}`;
do
	if ! dpkg -l |grep "$REQ" > /dev/null
	then
		echo ""
		echo -e "${RED} ERROR:${ENDCOLLOR} $REQ is missing: run sudo apt update && sudo apt install $REQ -y"
		echo ""
		exit 1
	fi
done

#Validade script arguments
if [ $# -ne 3 ]
then
	echo ""
	echo -e "${RED} ERROR:${ENDCOLLOR} Wrong number of arguments."
	echo ""
	echo -e "${GREEN} RUN:${ENDCOLLOR} $0 [absolute/path/dir1] [absolute/path/dir2] [md5sum|sha1sum|sha256sum|sha512sum]"
	echo ""
	exit 1
else
	# Validate algorithm input
	ALGLOWERCASE=`echo "$3" |tr A-Z a-z` # convert all A-Z chars to lowercase a-z arguments
	if [ "$ALGLOWERCASE" != "md5sum" -a "$ALGLOWERCASE" != "sha1sum" -a "$ALGLOWERCASE" != "sha256sum" -a "$ALGLOWERCASE" != "sha512sum" ];
	then
		echo ""
		echo -e "${RED} Hash type error.${ENDCOLLOR}"
		echo ""
		echo -e "${GREEN} Choose one of these hashing algorithms:${ENDCOLLOR} md5sum|sha1sum|sha256sum|sha512sum"
		echo ""
		exit 1
	fi

	# Calculate hash values recursively inside each directory
	find "$1" \( -type b -o -type c -o -type d -o -type p -o -type f -o -type l -o -type s \) -iname "*" -exec $ALGLOWERCASE 2>/dev/null {} + > $RESULTS/checksum1
	find "$2" \( -type b -o -type c -o -type d -o -type p -o -type f -o -type l -o -type s \) -iname "*" -exec $ALGLOWERCASE 2>/dev/null {} + > $RESULTS/checksum2
	# Makes temp files only to compare checksum file lists
	cat $RESULTS/checksum1 |awk '{print $1}' > $RESULTS/temp-checksum1
	cat $RESULTS/checksum2 |awk '{print $1}' > $RESULTS/temp-checksum2

	#Stores total number of hash values on each temporary list
	touch $RESULTS/temp-checksum1 && touch $RESULTS/temp-checksum2
	TotalHashesDir1=`cat $RESULTS/temp-checksum1 |wc -l`
	TotalHashesDir2=`cat $RESULTS/temp-checksum2 |wc -l`

	#Evaluates if directories have the same number of objects
	if [ $TotalHashesDir1 -eq $TotalHashesDir2 ]
	then
		echo ""
		echo -e "${GREEN} [+] ${ENDCOLLOR}Directories have the same number of objects [$TotalHashesDir1 / $TotalHashesDir2]"
		sleep 2
		echo ""
		echo -e "${GREEN} Comparing hashes between directories ...${ENDCOLLOR}"
		echo ""
		sleep 2
		#spots what hashes from dir2 are different than dir1 two considing both with the same number of objects (hashes)
		DIFF=""
		DIFF=`diff $RESULTS/temp-checksum1 $RESULTS/temp-checksum2 | grep ">" |cut -d ">" -f2`
		
		if [[ `echo -n "$DIFF"` != "" ]]; #test -n => tests if $DIFF is not null which means exit code -eq 0 for `test -n $DIFF`
		then
 			echo -e "${RED} [NOT EQUAL HASHES ON $2]${ENDCOLLOR}"
 			echo ""
			for HASH in `echo $DIFF`;
			do
				grep -i "$HASH" $RESULTS/checksum2
			done
		else
			echo ""
			echo -e "${GREEN} [ALL HASHES ARE EQUAL]${ENDCOLLOR}"
			echo ""
		fi
	#when dir1 has less objects than dir2
	elif [ `cat $RESULTS/checksum1 |wc -l` -lt `cat $RESULTS/checksum2 |wc -l` ]
 	then
 		#spots what hashes from dir2 are different than dir1 two considing both with the same number of objects (hashes)
		DIFF=""
		DIFF=`diff $RESULTS/temp-checksum1 $RESULTS/temp-checksum2 | grep ">" |cut -d ">" -f2`
		
 		echo ""
		echo -e "${RED}[FILES MISSING ON $1]${ENDCOLLOR}"
 		echo ""

		if [[ `echo -n "$DIFF"` != "" ]]; #test -n => tests if $DIFF is not null which means exit code -eq 0 for `test -n $DIFF`
		then
			for HASH in `echo $DIFF`;
			do
				grep -i "$HASH" $RESULTS/checksum2 #reports what files are missing on dir1 when compared to dir2
			done
		fi
 	elif [ `cat $RESULTS/temp-checksum1 |wc -l` -gt `cat $RESULTS/temp-checksum2 |wc -l` ]
 	then
 		#spots what hashes from dir2 are different than dir1 two considing both with the same number of objects (hashes)
		DIFF=""
		DIFF=`diff $RESULTS/temp-checksum1 $RESULTS/temp-checksum2 | grep "<" |cut -d "<" -f2`
		
		echo ""
		echo -e "${RED}[FILES MISSING ON $2]${ENDCOLLOR}"
 		echo ""

		if [[ `echo -n "$DIFF"` != "" ]]; #test -n => tests if $DIFF is not null which means exit code -eq 0 for `test -n $DIFF`
		then
			for HASH in `echo $DIFF`;
			do
				grep -i "$HASH" $RESULTS/checksum1 #reports what files are missing on dir1 when compared to dir2
			done
		fi
	fi
fi

#Delete temp files
rm -rf $RESULTS/temp-checksum1 && rm -rf $RESULTS/temp-checksum2
