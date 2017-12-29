#!/bin/bash
# Sets up Centos7 after a fresh install
#
# Created by: J.Lickey
#
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
function build_start-eth0 () {
	echo "#!/bin/bash" > /etc/rc3.d/start-eth0.sh
	echo "/etc/sysconfig/network-scripts/ifup ifcfg-enp0s3" >> /etc/rc3.d/start-eth0.sh
	echo "/etc/sysconfig/network-scripts/ifup-wireless" >> /etc/rc3.d/start-eth0.sh
	chmod +x /etc/rc3.d/start-eth0.sh
}
function build_Pool_16-active () {
	echo "#!/bin/bash" > /home/$USER/Desktop/Pool_16-active.sh
	echo "xdotool search Pool_16 click 1" >> /home/$USER/Desktop/Pool_16-active.sh
}
build_start-eth0
yum install epel-release -y 
yum check-update -y

OS_bits=$(uname -r | cut -d . -f 7)
if [ "OS_bits" == "x86_64" ];then
	yum install libgudev1.$OS_bits net-tools.$OS_bits libgudev1-devel.$OS_bits libffi.$OS_bits libffi-devel.$OS_bits
	cd /usr/lib64
	ln -s libudev.so.1.6.2 libudev.so.0
	ln -s /usr/lib64/libffi.so.6 /usr/lib64/libffi.so.5
fi
if [ "OS_bits" == "i686" ];then
	yum install libgudev1.$OS_bits net-tools.$OS_bits libgudev1-devel.$OS_bits libffi.$OS_bits libffi-devel.$OS_bits
	cd /usr/lib
	ln -s libudev.so.1.6.2 libudev.so.0
	ln -s /usr/lib/libffi.so.6 /usr/lib/libffi.so.5
fi

yum install xdotool wget mlocate tigervnc gnome-disk-utility libpng12 nmap -y
build_Pool_16-active
updatedb
yum groupinstall "X Window system" -y
yum groupinstall "MATE Desktop" -y
systemctl set-default graphical.target
rm '/etc/systemd/system/default.target'
ln -s '/usr/lib/systemd/system/graphical.target' '/etc/systemd/system/default.target'
#wget https://download3.vmware.com/software/view/viewclients/CART16Q4/VMware-Horizon-Client-4.3.0-4710754.x64.bundle
wget --progress=bar:force https://download3.vmware.com/software/view/viewclients/CART17Q2/VMware-Horizon-Client-4.5.0-5650368.x64.bundle 2>&1 | progressfilt
chmod +x VMware-Horizon-Client-4.3.0-4710754.x64.bundle
shutdown -r now
