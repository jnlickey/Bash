#!/bin/bash
##########################################################################################
# Script created to export LDAP DNS entries from Univention, and format the output file
# so that DNSCMD can be used to import the DNS entries into Windows.
#
# https://www.windowstricks.in/2011/04/command-to-createdelete-bulk-dns-record.html
# Above website was used to get the format of the output file.
#
# Created by: Jon Lickey
# 20210810
##########################################################################################
# Colors
# https://www.shellhacks.com/bash-colors/
YEL="\e[1;33m"
GRN="\e[1;32m"
BLU="\e[1;34m"
CYN="\e[1;36m"
NC="\e[0;0m"

# Variables
base_dn="dc=example,dc=com"

printf "The following prompt is for ${YEL}${USER}${NC} AD/LDAP credentials (Needed for LDAPSEARCH):\n"
kinit ${USER}

# Pull information from LDAP
ldapsearch -o ldif-wrap=no -b ${base_dn} -LLL univentionObjectType zoneName relativeDomainName aRecord pTRRecord > /home/${USER}/ldap-output.txt

# Gather PNTR and HOST Records
#egrep -A5 "zoneName" /home/${USER}/ldap-output.txt | awk '{ ORS = (NR%8 ? FS : RS)} 1' | sed 's/dn\:/\ndn\:/g' | grep "relativeDomainName" | uniq | sort > /tmp/ldapoutput.txt

RESULTS=$(egrep -A3 -B2 "dns\/host" /home/${USER}/ldap-output.txt | tr '\n' ' ' | sed 's/--//g;s/dn\:/\ndn\:/g')
#RESULTS=$(cat /tmp/ldapoutput.txt | egrep "^dn\:" | grep -v "@" | egrep "aRecord" | awk '{print $4":"$6":"$8}' | sed 's/:://g' | sort | uniq | sed 's/:/ /g')

# Format the results into RECORD_2_ADD;ZONE_WHERE_ADD_RECORD;IP_ADDRESS
# Format taken from: https://www.windowstricks.in/2011/04/command-to-createdelete-bulk-dns-record.html
IFS=$'\n';for i in ${RESULTS};do IP=$(echo $i | egrep -o "[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}");SRVR=$(echo $i | egrep -o "relativeDomainName\:\s.+\s" | awk '{print $2}');ZONE=$(echo $i | egrep -o "zoneName\:\s.+" | awk '{print $2}');echo "${SRVR};${ZONE};${IP}";done | egrep -vi "^ns|^\;|^DomainDns|^ForestDns|^gc._msdcs" > /home/${USER}/Import2DNS.txt


printf "\n"
printf "FORWARD LOOKUP ZONES:\n";egrep -A2 "dns\/(forward|reverse|host)" ldap-output.txt | awk '{ ORS = (NR%4 ? FS : RS)} 1' | egrep "dns\/forward" | awk '{print $2" "$5" "$6}';echo
printf "REVERSE LOOKUP ZONES:\n";egrep -A2 "dns\/(forward|reverse|host)" ldap-output.txt | awk '{ ORS = (NR%4 ? FS : RS)} 1' | egrep "dns\/reverse" | awk '{print $2" "$5" "$6}';echo
# Notes about where to find output
printf "${BLU}The output file can be found here:${NC} ${CYN}/home/${USER}/Import2DNS.txt${NC}\n"

# Clean-up temp files
rm -f /home/${USER}/ldap-output.txt
#rm -f /tmp/ldapoutput.txt
exit 0
