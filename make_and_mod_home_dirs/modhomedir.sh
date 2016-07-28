#!/bin/bash
# This script sets user home directory permissions
# when it is first created.
#
# Created by: nlickey
# 05/28/2015
if [ -e /export/$2/$1 ]; then
        chown -R $1:group_name /export/$2/$1
        chmod 711 /export/$2/$1
        chmod 711 /export/$2/$1/.linux
        chmod 711 /export/$2/$1/public_html
        chmod 711 /export/$2/$1/local_html
        chmod 711 /export/$2/$1/.linux/public_html
        chmod 711 /export/$2/$1/.linux/local_html
fi
exit 0
