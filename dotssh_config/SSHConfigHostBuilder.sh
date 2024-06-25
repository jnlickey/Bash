#!/bin/bash
##############################################################
#
# Created to aid in adding hosts to the .ssh/config file
#
# Created by: jnlickey
# 20240625
##############################################################
if [[ $1 =~ \-h|\-\-help || $1 = '' ]];then
	echo -ne "Usage: $0 <servername>\n"
	echo -ne "       -h|--help   -   shows this help screen\n\n"
	exit
fi
server=${1}

HOST=$(nslookup ${server} | grep -A1 'Name' | awk 'NR==1{print $2}' | sed 's/\.example\.com//g')
HOSTNAME=$(nslookup ${server} | grep -A1 'Name' | awk 'NR==2{print $2}')
PORT='22'
USER_SET='my_user'
KEY="/home/${USER}/.ssh/key"

echo -ne "\n# Added via SSHConfigHostBuilder.sh\nHOST ${HOST}\n   HOSTNAME ${HOSTNAME}\n   PORT ${PORT}\n   USER ${USER_SET}\n   IDENTITYFILE ${KEY}\n\n" | tee -a ${HOME}/.ssh/config
