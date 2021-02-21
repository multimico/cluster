#!/bin/bash

# USAGE
#   > install-system.sh MY_USER_NAME MY_GH_NAME
# 
# The Username and Github Name are optional 
#

# TODO: We want to customise the image
UBUNTUVERSION="20.10"
HOSTNAME=`petname`

USERNAME=$1
GITHUBNAME=$2

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
TDIR=`dirname $DIR`

echo "The new host is called $HOSTNAME"

if [ "x$USERNAME" == "x" ]
then
    TMPUSERNAME=`whoami`
    read -p "System User Name [default $TMPUSERNAME]:" USERNAME

    if [ "x$USERNAME" == "x" ]
    then
        USERNAME=$TMPUSERNAME
    fi
fi

if [ "x$GITHUBNAME" == "x" ] 
then
    TMPGITHUBNAME=`whoami`
    read -p "GitHub User Name [default $TMPGITHUBNAME]:" GITHUBNAME

    if [ "x$GITHUBNAME" == "x" ] 
    then
        GITHUBNAME=$TMPGITHUBNAME
    fi
fi

# Ask for a default password
read -s -p "Enter password:" PASSWD

# Hash the password for cloud init
CRYPTPASSWD=`echo -n $PASSWD | openssl passwd -6 -stdin`

echo "init $HOSTNAME"
lxc init ubuntu:$UBUNTUVERSION $HOSTNAME

# TODO We my want to customise the cloud_init file.
CLOUD_INIT=$TDIR/vms/cloud_init.cfg

echo "inject cloud init user-data"
cat $CLOUD_INIT | \
    sed -e "s/HOSTNAME/$HOSTNAME/" \
        -e "s/USERNAME/$USERNAME/" \
        -e "s/PASSWORD/$CRYPTPASSWD/" \
        -e "s/GH_ID/$GITHUBNAME/" | \
    lxc config set $HOSTNAME user.user-data -

echo "Starting System $HOSTNAME"
lxc start $HOSTNAME
