#!/bin/bash
#
#  Created by: J.Lickey
#  20181004
#
if [[ $1 = "-h" || $1 = "--help" || $1 = "" ]];then
	echo "Usage: $0 [-a|-g] <userid>"
	echo "  -a - remove userid from ALL groups"
	echo "  -l - list groups userid is in"
	echo "  -g - groups to remove userid from (group1,group2,...)"
	echo "  -h - this help screen"
	echo
	exit
fi
flag=$1
if [[ $flag = "-a" ]];then
	userid=$2
	groups=`egrep $userid /etc/group | cut -d: -f1 | tr '\n' ' '`
	for grp in $groups;do
		gpasswd -d $userid $grp
	done
fi
if [[ $flag = "-g" ]];then
	userid=$3
	groups="$2"
	grps=`echo "$groups" | sed 's/,/|/g'`
	searchgroups=`egrep "$grps" /etc/group | cut -d: -f1 | tr '\n' ' '`
	for grp in $searchgroups;do
		gpasswd -d $userid $grp
	done
fi
if [[ $flag = "-l" ]];then
	userid=$2
	grep $userid /etc/group
fi
