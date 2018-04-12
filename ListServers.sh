#!/bin/bash
#
# Created by J.Lickey 20180407
# Modified: 20180412
#
# This script connects to a remote server
# and runs an ansbile command to get back 
# a list of servers. It then modifies the
# output of that list into the following 
# format: 
#
# servernameXXX/XXX/XXX/XXX
#
if [[ $1 = "" || $1 = "-h" ]];then
        echo "Usage: $0 <server>"
        exit
fi

# Grabs server name to search on
srv="${1}"

# Grabs current user to use to ssh into remote server
usr=`whoami`

# Cleans numlist
>numlist

# Excludes last 3 characters from string
srv2=${srv::${srv}-3}

# SSH's into remote server, runs ansible command, and
# stores output into variable.
RESULTS=$(ssh ${usr}@<remote_server_name> "ansible -m ping ~'${srv2}.*' | egrep \"\|\" | sort | egrep -v \"\.|\,\"")

# Cleans up output from RESULTS above
SRVRESULTS=$(echo $RESULTS | sed 's/ | SUCCESS => { /\n/g;s/ | SUCCESS => {$//g')

# Loops through list of results to grab last 3 characters
# of the name. It then stores those characters in numlist
for i in $SRVRESULTS;do
        if [[ $i =~ $srv2 ]];then
                # Grab last 3 characters from a string
                num=${i: -3}
                echo $num | tr '\n' '/' >> numlist
        fi
done

# Outputs servername and appends the list of characters
# stored in numlist so that the output is in the format:
#
# servernameXXX/XXX/XXX
echo -ne "${srv2}`cat numlist | sed 's/\/$//g'`\n"
