#!/bin/bash
# This script creates a users home directory on linux
# Created by: nlickey
# 08/24/2015
if [ ! -e /home/DOMAIN/$2/$1 ]; then
        mkdir /home/DOMAIN/$2/$1
        cp -R /etc/skel/ /home/DOMAIN/$2/$1/.linux
        mkdir /home/DOMAIN/$2/$1/.linux/public_html
        mkdir /home/DOMAIN/$2/$1/.linux/local_html
        cd /home/DOMAIN/$2/$1/.linux
        ln -s .linux/public_html/ ../public_html
        ln -s .linux/local_html/ ../local_html
        sleep 1
        /usr/local/sbin/modhomedir.sh $1 $2
else
        read -p "Home already exists, copy skel to location?" yn
        case $yn in
                [yY]* )
                echo "yes"
                ;;
                [nN]* )
                echo "no"
                ;;
        esac
fi
exit 0