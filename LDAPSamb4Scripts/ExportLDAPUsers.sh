#!/bin/bash
#######################################################################################
#
# Created to Export users from Univention LDAP
#
# Created by: J.Lickey
# 20210914
#
#######################################################################################
# Variables
base_dn="dc=example,dc=com"

# Set Internal Field Separator
IFS=$'\n'

# Check to see if output and temporary files already exists
if [[ -f /home/${USER}/ExportedLDAPUsers.txt ]];then
	> /home/${USER}/ExportedLDAPUsers.txt
else
	touch /home/${USER}/ExportedLDAPUsers.txt
fi
if [[ -f /home/${USER}/tmp_users.txt ]];then
	> /home/${USER}/tmp_users.txt
else
	touch /home/${USER}/tmp_users.txt
fi
if [[ -f /home/${USER}/users.txt ]];then
	> /home/${USER}/users.txt
else
	touch /home/${USER}/users.txt
fi

# Run LDAP Search
printf "Run ldapsearch (Y|N): "; read ans
if [[ $ans =~ [Y|y][E|e][S|s]|[Y|y] ]];then
	# Login to LDAP as current user, and prompt for LDAP password
	kinit ${USER}
	# Build user informtion
	ldapsearch -o ldif-wrap=no -b ${base_dn} -LLL uid gecos uidNumber gidNumber loginShell homeDirectory mailPrimaryAddress memberOf 2>/dev/null > /home/${USER}/users.txt
fi

IFS=$'\n'
printf "Please wait...\n"
for info in $(cat /home/${USER}/users.txt | tr '\n' ' ' | sed 's/dn:/\ndn:/g');do
	uid=$(u=${info#*uid: };printf "%s" "$u" | awk '{print $1}')
	gecos=$(g=${info#*gecos: };printf "%s" "$g" | awk '{print $1" "$2}')
	uidN=$(uN=${info#*uidNumber: };printf "%s" "$uN" | awk '{print $1}') 
	gidN=$(gN=${info#*gidNumber: };printf "%s" "$gN" | awk '{print $1}') 
	shell=$(sh=${info#*loginShell: };printf "%s" "$sh" | awk '{print $1}')
	home=$(h=${info#*homeDirectory: };printf "%s" "$h" | awk '{print $1}')
	email=$(mail=${info#*mailPrimaryAddress: };printf "%s" "$mail" | awk '{print $1}')
	grp=$(echo $info | grep -oP "(memberOf\:\ +\K\S+\ +U\S+)|(memberOf\:\ +\K\S+)" | sed 's/Domain\s\+Users/Domain Users/g' | tr '\n' ';';echo)
	groups=$(echo $grp | sed 's/\s\+/ /g' | sed 's/;$//g')
	echo -ne "${gecos} ${uid} ${uidN}:${gidN} ${home} ${shell} ${email} ${groups}\n" | egrep -v "deactivated|temporary" >> /home/${USER}/tmp_users.txt
done

IFS=$'\n'
# Build Admin User information
for admin in $(cat /home/${USER}/users.txt | egrep "\-admin" | tr '\n' ' ' | sed 's/dn:/\ndn:/g');do 
	auid=$(u=${admin#*uid: };printf "%s" "$u" | awk '{print $1}')
	agecos=$(echo "${auid} (Admin)")

	ahome=$(h=${admin#*homeDirectory: };printf "%s" "$h" | awk '{print $1}')
	agrp=$(echo $admin | grep -oP "(memberOf\:\ +\K\S+\ +U\S+)|(memberOf\:\ +\K\S+)" | sed 's/Domain\s\+Users/Domain Users/g' | tr '\n' ';';echo)
	agroups=$(echo $agrp | sed 's/\s\+/ /g' | sed 's/;$//g')
	echo -ne "${agecos}(Admin) ${auid} ${auidN}:${agidN} ${ahome} ${ashell} ${aemail} ${agroups}\n" | egrep -v "dn\:|group|default|deactivated|temporary|web-admin" >> /home/${USER}/tmp_users.txt
done

# Build output file and on-screen information
printf '%s\t\t%s\t\t\t%s\t\t%s\t\t%s\t\t%s\t\t%s\t\t%s\n' FName LName User_ID uid:gid Home_Dir Shell E-Mail Groups> /home/${USER}/ExportedLDAPUsers.txt
echo -ne "------------------------------------------------------------------------------------------------------------------------------\n" >> /home/${USER}/ExportedLDAPUsers.txt
cat /home/${USER}/tmp_users.txt | tr ' ' '|' | sed 's/Domain|Users/Domain Users/g' | column -t -s "|" | tee -a /home/${USER}/ExportedLDAPUsers.txt
cat /home/${USER}/ExportedLDAPUsers.txt | sed 's/\s\+/ /g' | tr ' ' ',' | sed 's/Domain\,Users/Domain Users/g' | sed 's/,,,,,,,,,,/,/g;s/,,,,,,/,/g;s/,,,,/,/g;s/,,,/,/g;s/,,/,/g' > /home/${USER}/ExportedLDAPUsers.csv
printf "\n\nOutput file can be found here: /home/${USER}/ExportedLDAPUsers.txt and /home/${USER}/ExportedLDAPUsers.csv\n"

# Clean-up temp files
#rm /home/${USER}/users.txt
#rm /home/${USER}/tmp_users.txt

exit 0
