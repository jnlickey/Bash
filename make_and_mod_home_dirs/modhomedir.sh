#!/bin/bash
# This script sets user home directory permissions
# when it is first created.
if [ -e /export/$2/$1 ]; then
        chown -R $1:cse_users /export/$2/$1
        chmod 711 /export/$2/$1
        chmod 711 /export/$2/$1/.linux
        chmod 711 /export/$2/$1/public_html
        chmod 711 /export/$2/$1/local_html
        chmod 711 /export/$2/$1/.linux/public_html
        chmod 711 /export/$2/$1/.linux/local_html
fi
exit 0