#!/bin/bash
# Created by: jnlickey
# 20170618

progressfilt ()
{
    local flag=false c count cr=$'\r' nl=$'\n'
    while IFS='' read -d '' -rn 1 c
    do
        if $flag
        then
            printf '%c' "$c"
        else
            if [[ $c != $cr && $c != $nl ]]
            then
                count=0
            else
                ((count++))
                if ((count > 1))
                then
                    flag=true
                fi
            fi
        fi
    done
}

year=$(date +"%y")
month=$(date +"%m")
fexists=$(ls /home/$USER/Desktop | grep VMware-Horizon-Client)

case $month in
01|02|03)
	q=1
	;;
04|05|06)
	q=2
	;;
07|08|09)
	q=3
	;;
10|11|12)
	q=4
	;;
*) echo "Invalid Input..."
	;;
esac

curl -s -o /tmp/test https://my.vmware.com/web/vmware/details?downloadGroup=CART${year}Q${q}_LIN64_450\&productId=578\&rPId=16683 2>&1 && url=$(egrep 'VMware-Horizon-Client' /tmp/test | awk 'NR==1{print $2}' | sed 's/href="//g' | sed 's/"//g') && file=$(egrep 'VMware-Horizon-Client' /tmp/test | awk 'NR==1{print $2}' | sed 's/href="//g' | sed 's/"//g' | cut -d / -f 8)

if [ "${fexists}" == "${file}" ];then
	printf "\n"
	printf "$fexists already exists!\n"
	printf "\n"
else
	printf "Downloading VMware Horizon Client...\n" && rm -rf /tmp/test
	printf "File Named: ${file}\n"
	printf "\n" 
	wget -nc --progress=bar:force $url 2>&1 | progressfilt
	chmod +x $file
fi
