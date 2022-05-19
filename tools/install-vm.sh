#!/bin/bash

# USAGE
#   > install-system.sh MY_USER_NAME MY_GH_NAME
# 
# The Username and Github Name are optional 
#

# CONSTANTS NOT TO CUSTOMISE
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
TDIR=`dirname $DIR`

HOSTNAME=`petname`

# Variables
# TODO: We want to customise the image
UBUNTUVERSION="22.04"
# TODO: We my want to customise the cloud_init file.
CLOUD_INIT=$TDIR/vms/cloud_init.cfg
# TODO: Add Customizable CPU and Memory Limits

# Parameters
USERNAME=$1
GITHUBNAME=$2

echo "The new host is called '$HOSTNAME'"

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


echo "inject cloud init user-data"
export HOSTNAME=$HOSTNAME USERNAME=$USERNAME CRYPTPASSWD=$CRYPTPASSWD GITHUBNAME=$GITHUBNAME

cat $CLOUD_INIT | \
    envsubst | \
    lxc config set $HOSTNAME user.user-data -

lxc config set $HOSTNAME volatile.eth0.hwaddr $MACADDRESS

# echo "Starting System $HOSTNAME"
lxc start $HOSTNAME
