#!/bin/bash
####################################################################
# Script created to point out where a server is located
# (AWS, vCenter, or On-Prem)
#
# Created by: J.Lickey
# 02/02/2021
# Version: 1.1.0
####################################################################

# Colors
RED='\033[1;31m'
GRN='\033[0;32m'
BGRN='\033[1;32m'
YEL='\033[0;33m'
BYEL='\033[1;33m'
BLU='\033[1;96m'
GRY='\033[1;90m'
NC='\033[0m' # No Color

printf "\n\n"
echo -ne "${GRY} ________  __                  __        __    __                        __   \n"
echo -ne "/        |/  |                /  |      /  |  /  |                      /  |  \\n"
echo -ne "\$\$\$\$\$\$\$\$/ \$\$/  _______    ____\$\$ |      \$\$ |  \$\$ |  ______    _______  _\$\$ |_ \n"
echo -ne "\$\$ |__    /  |/       \\  /    \$\$ |      \$\$ |__\$\$ | /      \\  /       |/ \$\$   |\n"
echo -ne "\$\$    |   \$\$ |\$\$\$\$\$\$\$  |/\$\$\$\$\$\$\$ |      \$\$    \$\$ |/\$\$\$\$\$\$  |/\$\$\$\$\$\$\$/ \$\$\$\$\$\$/ \n"
echo -ne "\$\$\$\$\$/    \$\$ |\$\$ |  \$\$ |\$\$ |  \$\$ |      \$\$\$\$\$\$\$\$ |\$\$ |  \$\$ |\$\$      \   \$\$ | __\n"
echo -ne "\$\$ |      \$\$ |\$\$ |  \$\$ |\$\$ \\__\$\$ |      \$\$ |  \$\$ |\$\$ \\__\$\$ | \$\$\$\$\$\$  |  \$\$ |/  |\n"
echo -ne "\$\$ |      \$\$ |\$\$ |  \$\$ |\$\$    \$\$ |      \$\$ |  \$\$ |\$\$    \$\$/ /     \$\$/   \$\$  \$\$/ \n"
echo -ne "\$\$/       \$\$/ \$\$/   \$\$/  \$\$\$\$\$\$\$/       \$\$/   \$\$/  \$\$\$\$\$\$/  \$\$\$\$\$\$\$/     \$\$\$\$/  \n${NC}"
printf "\n\n"
                                                                                
if [[ $1 = "" || $1 = "-h" || $1 = "--help" ]];then
        echo -ne "${BLU}Usage: $0 <server> or <server,<server>,...\n\n\n${NC}"
        exit
fi

SRVRS=$1

#
# This function prints out the location of a given server
# IP addresses below need to be changed to meet your environment
#
function FindLocation () {
        LookUpIP=${1}
        Host=${2}

        case ${LookUpIP} in
                10.X.*) printf "${YEL}%-20s\t\t${BYEL}%-20s${NC}\n" "${Host}" "DEV AWS"
                        ;;
                10.Y.*) printf "${YEL}%-20s\t\t${BYEL}%-20s${NC}\n" "${Host}" "PROD AWS"
                        ;;
                10.Z.*) printf "${GRN}%-20s\t\t${BGRN}%-20s${NC}\n" "${Host}" "On-Prem (Physical)"
                        ;;
                10.X.Y) printf "${GRN}%-20s\t\t${BGRN}%-20s${NC}\n" "${Host}" "vCenter"
                        ;;
                *) printf "${RED}%-20s\t\t%-20s${NC}\n" "${Host}" "UNKNOWN LOCATION"
                        ;;
        esac
}

#
# This functions look to see if the server is found in DNS
#
function DNSCheck () {
        SRV=${1}
        DNSLookUp=$(host ${SRV} | awk '{print $4}')
        if [[ ${DNSLookUp} = "found:" ]];then
                printf "${RED}%-20s\t\t%-20s${NC}\n" "${SRV}" "Not in DNS"
        fi

}

#
# This is the main bash script, the input can be a single server name or a comma
# seperated list of servers. This main section also calls the other two functions
# noted above.
#
if [[ ${SRVRS} =~ \, ]];then
        SRVLST=$(echo ${SRVRS} | tr ',' ' ')
        for h in ${SRVLST};do

                if [[ $(DNSCheck ${h}) =~ [n|N]ot ]];then
                        DNSCheck ${h}
                else
                        IP=$(host ${h} | awk '{print $4}' | grep -oP "[0-9]{2,3}\.[0-9]{1,3}\.[0-9]{1,3}\." | sed 's/.$//g')
                        FindLocation ${IP} ${h}
                fi
        done
else
        if [[ $(DNSCheck ${SRVRS}) =~ not ]]; then
                exit
        else
                IP=$(host ${SRVRS} | awk '{print $4}' | grep -oP "[0-9]{2,3}\.[0-9]{1,3}\.[0-9]{1,3}\." | sed 's/.$//g')
                FindLocation ${IP} ${SRVRS}
        fi
fi


printf "\n\n"
exit 0
