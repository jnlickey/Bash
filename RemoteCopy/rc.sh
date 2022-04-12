#!/bin/bash
##################################################################################
#
# This script is for copying files between two servers utilizing ansible, from a
# third party host. So you don't have to ssh into one of the systems, in order to
# copy the file. Rather you can copy the file between the two systems remotely. 
# 
# Created by: J.Lickey
# 20220322
#
###################################################################################
if [[ $1 =~ \-h|\-\-help || $1 = "" ]];then
	printf "Usage: $0 <FromServer> </source/path/filename> <ToServer> </dest/path>\n"
	printf "\n"
	exit
fi
ServerFROM=$1
ServerPathFROM=$2
ServerTO=$3
ServerPathTO=$4

ansible-playbook RemoteCopy.yml -e "PathCopyFROM=${ServerPathFROM} PathCopyTO=${ServerPathTO} HOST=${ServerTO}" ${ServerFROM}
