#!/bin/bash
#########################################################################################
#
# Script created to export computers from Univention LDAP
#
# Created by: J.Lickey
# 20210916
#
#########################################################################################

sudo samba-tool computer list | sed 's/\$//g' | tr '[A-Z]' '[a-z]';echo | tee ExportedLDAPComputers.txt

exit 0
