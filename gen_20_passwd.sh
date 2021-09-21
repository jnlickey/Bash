#!/bin/bash
####################################################################
#
# Script created to randomly generate a 20 character password string
#
# Created by: J.Lickey
# 20210819
#
####################################################################
function RNUM (){
	count=${1}
	echo $RANDOM % ${count}| bc
	return
}

# Change the following line number to change
# the length of the desired password.
PASS_LENGTH=20

# Character sets used
# LCHAR - Lower Case Characters
# UCHAR - Upper Case Characters
LCHAR="abcdefghijklmnopqrstuvwxyz"
UCHAR="ABCDEFGHIJKLMNOPQRSTUVWXYZ"

# NUM - Numbers
NUM="0123456789"

# SCHAR - Special Characters
#  -- You can add or subtract special characters to the list
#     by adding them between the double quotes
SCHAR=")(@#%.-_,?=+|\""
SCHAR_LENGTH=$(expr length ${SCHAR})

# Determines the length of the password and how many times
# to run through the while loop
LENGTH=$(echo ${PASS_LENGTH} / 4 | bc)

# Builds character string (password)
counter=0
while [ $counter -lt ${PASS_LENGTH} ];do
	# Randomly chooses character from each array
	array[0]="${UCHAR:$(RNUM 26):1}"
	array[1]="${LCHAR:$(RNUM 26):1}"
	array[2]="${NUM:$(RNUM 10):1}"
	array[3]="${SCHAR:$(RNUM ${SCHAR_LENGTH}):1}"
	# Determines size of array chosen
	asize=${#array[@]}
	# Each array is chosen at random
	aindex=$(($RANDOM % ${asize}))
	# Builds string of given characters from the array
	PASS=${PASS}
	# Adds character to each existing character in string
	PASS+=$(echo ${array[$aindex]})
	counter=$(( $counter + 1 ))
done

# Prints random character set of desired length
echo ${PASS}
