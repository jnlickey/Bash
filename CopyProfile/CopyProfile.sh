#!/bin/bash
#
# This script will copy your .bashrc profile to remote servers using Ansible
#
# Created by: J.Lickey
#
if [[ $1 = "" || $1 = "-h" ]];then
	printf "*** NOTE: Make sure that your .bashrc is setup on <ansible_server>. ***\n This script will copy <ansible_server>:/home/<e-id|c-id>/.bashrc to\nremote_server:/home/<e-id|c-id>/.bashrc\n"
	echo ""
	echo "Usage: $0 <e-idt|c-idt> -s [default:All|<servername>,<servername>]"
	echo ""
	exit
fi
function buildServerList () {
	echo "[myservers]"  > /home/$id/ServerList.txt
	echo $servers | sed 's/\,/\n/g'  >> /home/$id/ServerList.txt	
}
function buildYAML () {
	echo "#"  > /home/$id/CopyProfile.yml
	echo "# Auto-generated -- Copy profile YAML file"  >> /home/$id/CopyProfile.yml
	echo "#" >> /home/$id/CopyProfile.yml
	echo "# Created by: J.Lickey" >> /home/$id/CopyProfile.yml
	echo "#" >> /home/$id/CopyProfile.yml
	echo "---" >> /home/$id/CopyProfile.yml
	echo "- hosts: all" >> /home/$id/CopyProfile.yml
	echo "  become: yes" >> /home/$id/CopyProfile.yml
	echo "" >> /home/$id/CopyProfile.yml
	echo "  tasks:" >> /home/$id/CopyProfile.yml
	echo "  - name: Copy Profile" >> /home/$id/CopyProfile.yml
	echo "    copy:" >> /home/$id/CopyProfile.yml
	echo "       src=\"{{path}}\"" >> /home/$id/CopyProfile.yml
	echo "       dest=\"{{path}}\"" >> /home/$id/CopyProfile.yml
	echo "       owner=\"{{id}}\"" >> /home/$id/CopyProfile.yml
	echo "       group=\"{{id}}\"" >> /home/$id/CopyProfile.yml
	echo "       mode=0640" >> /home/$id/CopyProfile.yml
	echo "       backup=yes" >> /home/$id/CopyProfile.yml
}
function runAnsible () {
	server=`echo ${server}| sed 's/\,/\|/g'`
        echo "[myserverlist]" > /home/$id/serverlist
	echo $server | sed 's/\|/\n/g' >> /home/$id/serverlist
	if [[ ${server} =~ (all)|(ALL)|(All) ]];then
		echo "Running the following command:"
		echo "ansible -b -m copy -a 'src=/home/$id/.bashrc dest=/home/$id/.bashrc owner=$id group=$id mode=0640' all"
		ansible-playbook -l /home/$id/serverlist -e "id=${id} path=/home/${id}/.bashrc" CopyProfile.yml
		exit
	elif [[ ${server} =~ "|" ]];then
		echo "Running the following command:"
                echo "ansible -b -m copy -a 'src=/home/${id}/.bashrc dest=/home/${id}/.bashrc owner=${id} group=${id} mode=0640' ~'${servers}'"
		ansible-playbook -i /home/$id/ServerList.txt -e "id=${id} path=/home/${id}/.bashrc" CopyProfile.yml
		exit
	else
		echo "Running the following command:" 
                echo "ansible -b -m copy -e 'id=${id} server=${server}' -a 'src=/home/id/.bashrc dest=/home/${id}/.bashrc owner=${id} group=${id} mode=0640' ${server}"
		ansible-playbook -l ${server} -e "id=${id} path=/home/${id}/.bashrc" CopyProfile.yml
		exit
	fi
}
function checkNumServers () {
	num=`echo ${servers} | sed 's/,/\n/g' | wc -l`
	if [[ $num = "1" ]];then
		server=${servers}
		runAnsible ${server}
		exit
	else
		server=${servers}
		checkServers ${server}
	fi	
}
function checkServers (){
	if [[ $server =~ (All)|(all)|(All) ]];then
		echo "checkServers..."
		server="${s/$server/all/p}"
		runAnsible $server
	elif [[ $server = "" ]];then
		echo 'You forgot to add "-s all" or "-s <server>,<server>,..."'
		exit
	else 
		servers=`echo $server | sed 's/\,/\|/g'`
		runAnsible ${servers}
                exit
	fi
	
}
function checkforid () {
	if [[ $1 =~ ^e|^c ]];then
		printf ""
		id=$1
	else
		echo "Forgot to enter a valid e-id or c-id!"
		exit
	fi
}
servers=$3
checkforid $1
buildServerList $servers $id
if [[ -e "/home/$id/CopyProfile.yml" ]];then
	printf ""
else
	buildYAML $id
fi
if [[ $2 = "-s" ]];then
	checkNumServers ${servers}
	exit
else
	runAnsible ${servers}
fi
exit 0
