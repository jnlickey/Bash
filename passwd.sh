#!/bin/bash
####################################################################
#
# Random Password Generator
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

printf "How long of a password to make (8,10,...): ";read ans
PASS_LENGTH=${ans}
LCHAR="abcdefghijklmnopqrstuvwxyz"
UCHAR="ABCDEFGHIJKLMNOPQRSTUVWXYZ"
#UCHAR="$(echo ${LCHAR} | tr '[a-z]' '[A-Z]')"
NUM="0123456789"
SCHAR=")(@#%.-_,<>?=+"
SCHAR_LENGTH=$(expr length ${SCHAR})

LENGTH=$(echo ${PASS_LENGTH} / 4 | bc)
function generator() {
	counter=0
	while [ $counter -lt ${PASS_LENGTH} ];do
		array[0]="${UCHAR:$(RNUM 26):1}"
		array[1]="${LCHAR:$(RNUM 26):1}"
		array[2]="${NUM:$(RNUM 10):1}"
		array[3]="${SCHAR:$(RNUM ${SCHAR_LENGTH}):1}"
		asize=${#array[@]}
		aindex=$(($RANDOM % ${asize}))
		PASS=${PASS}
		PASS+=$(echo ${array[$aindex]})
		counter=$(( $counter + 1 ))
	done
}

for i in {1..3};do
	PASS=""
	generator $PASS_LENGTH $LCHAR $UCHAR $NUM $SCHAR $SCHAR_LENGTH
done
echo -ne "${PASS}\n" | sed 's/ $//g;s/^ //g'
exit 0
