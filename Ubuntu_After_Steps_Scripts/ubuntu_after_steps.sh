#!/bin/bash
# After Steps for Ubuntu
# This script is used to set Ubuntu as the default boot option. It then
# configures the hostname of the machine based off of the DNS name for
# the machine. It then migrates over a copy of the modified /etc/sudoers
# file.
# Created by jnlickey 20160315

grub-set-default 1
update-grub
ip="$(ifconfig | awk '/<ip_address_or_subnet_to_find>/ {print $2}' | cut -d ":" -f 2)"
name="$(nslookup $ip | awk '/name/ {print $4}'| cut -d "." -f 1)"
echo $name > /etc/hostname
mv /etc/sudoers /etc/sudoers.orig
rsync -a <user>@<workstation_name>:/etc/sudoers /etc/.
echo -e "Ubuntu after steps are complete for $name with address of $ip.\n"
