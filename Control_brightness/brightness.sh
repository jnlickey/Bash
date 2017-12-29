#!/bin/bash
# Script builds an expect script which will execute the controlling of the screen brightness.
# The script is executed by running the name of the script file: ./brightness.sh <0-12>
#
# Created by: J.Lickey
#
if [[ $1 = "" || $1 = "-h" ]];then
	echo "Usage: $0 <0-12>"
	exit
fi

function build_expect () {
	num=$1
	echo "#!/usr/bin/expect" > /home/$USER/su_root.exp
	echo "set num [lindex \$argv 0]" >> /home/$USER/su_root.exp
	echo "spawn -noecho /bin/su  - root" >> /home/$USER/su_root.exp
	echo "send \"echo \$num > /sys/class/backlight/acpi_video0/brightness\r\";" >> /home/$USER/su_root.exp
	echo "log_user 0  # Disables output from send command" >> /home/$USER/su_root.exp
	echo "send \"logout\r\"" >> /home/$USER/su_root.exp
	echo "interact" >> /home/$USER/su_root.exp
	chmod 770 /home/$USER/su_root.exp
	sudo /home/$USER/su_root.exp $num > /dev/null
}
if [[ -f /home/$USER/su_root.exp ]];then
	sudo ./su_root.exp $1 > /dev/null
else
	build_expect $1
fi
exit 0
