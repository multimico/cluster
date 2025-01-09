#!/bin/bash
#
# Generate a password for cloud-init

# USAGE
#   > init-password.sh [$PASSWORD]

PASSWD=$1

if [ -z $PASSWD ]
then
  # Always ask for a default password
  read -sp "Enter password: " PASSWD
  # extra newline because read suppresses the new line
  echo
fi

PWSALT=$(echo $RANDOM | md5sum | head -c 10)

CRYPTPASSWD=$(echo -n $PASSWD | mkpasswd -m sha-512 -R 4096 -S $PWSALT -s)

echo $CRYPTPASSWD
