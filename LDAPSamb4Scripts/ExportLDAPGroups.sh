#!/bin/bash
#######################################################################################
#
# Created to Export groups from Univention LDAP
#
# Created by: J.Lickey
# 20210914
#
#######################################################################################
# Variables
base_dn="dc=example,dc=com"

function rm_tmp_files (){
	# Remove temp files and exit
	rm /home/${USER}/tmp_groups.txt
	rm /home/${USER}/temp_groups.txt
	rm /home/${USER}/groups.txt
}

function files_check (){
	# Check to see if temp/output files exist
	if [[ -f /home/${USER}/ExportedLDAPGroups.txt ]];then
		>/home/${USER}/ExportedLDAPGroups.txt
		>/home/${USER}/ExportedLDAPGroups.csv
	else
		touch /home/${USER}/ExportedLDAPGroups.txt
		touch /home/${USER}/ExportedLDAPGroups.csv
	fi
	if [[ -f /home/${USER}/temp_groups.txt ]];then
		>/home/${USER}/temp_groups.txt
	else
		touch /home/${USER}/temp_groups.txt
	fi
	if [[ -f /home/${USER}/tmp_groups.txt ]];then
		>/home/${USER}/tmp_groups.txt
	else
		touch /home/${USER}/tmp_groups.txt
	fi
}

files_check

# Run LDAP Search query
printf "Run ldapsearch to export LDAP groups (Y|N): ";read ans
if [[ $ans =~ [Y|y][E|e][S|s]|[Y|y] ]];then
	kinit ${USER}
	ldapsearch -o ldif-wrap=no -b ${base_dn} -LLL groups gidNumber 2>/dev/null > /home/${USER}/groups.txt
else
	exit 0
fi

# Format output to file and screen
cat /home/${USER}/groups.txt | grep -A1 "groups" | tr '\n' ' ' | sed 's/dn:/\ndn:/g' > /home/${USER}/tmp_groups.txt
IFS=$'\n'
for info in $(cat /home/${USER}/tmp_groups.txt);do
	gname=$(echo ${info} | cut -d"=" -f2,5,6 | cut -d"," -f1)
	gidN=$(gidn=${info#*gidNumber: };printf "%s" "$gidn" | awk '{print $1}')
	echo -ne "${gname}||${gidN}\n" >> /home/${USER}/temp_groups.txt
done

# Create Exported Files in column and csv format
cat /home/${USER}/temp_groups.txt | column -s '||' -t | grep -v "dn:" | tee /home/${USER}/ExportedLDAPGroups.txt
cat /home/${USER}/temp_groups.txt | cut -d"|" -f1,3 | tr '|' ',' | grep -v "dn:" > /home/${USER}/ExportedLDAPGroups.csv

echo -ne "\n\nOutput files can be found here: /home/${USER}/ExportedLDAPGroups.txt and /home/${USER}/ExportedLDAPGroups.csv\n"

rm_tmp_files
exit 0
