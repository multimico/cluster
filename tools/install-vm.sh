#!/bin/bash

# USAGE
#   > install-system.sh MY_USER_NAME MY_GH_NAME
# 
# The Username and Github Name are optional 
#

# CONSTANTS NOT TO CUSTOMISE
# DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
TDIR=/home/multimico/src/multimico-cluster
CDIR=/home/multimico/src/cluster-config/

HOSTNAME=`petname`

# Variables
# TODO: We want to customise the image
UBUNTUVERSION="22.04"
# TODO: We my want to customise the cloud_init file.
CLOUD_INIT=$TDIR/vms/cloud_init.cfg

# Parameters
HOSTNAME=$1
USERNAME=$2

GITHUBNAME=$3

MACADDRESS=$( yq ".nodes[] | select(name == \"${HOSTNAME}\").macaddress" "${CDIR}/nodes/hardware_macs.yaml" )
PROFILE=$( yq ".nodes[] | select(name == \"${HOSTNAME}\").profile" "${CDIR}/nodes/hardware_macs.yaml" )

if [ -z $PROFILE ]
then
    PROFILE=default
fi

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

# Ask for a default password
read -s -p "Enter password:" PASSWD

# Hash the password for cloud init
CRYPTPASSWD=`echo -n $PASSWD | openssl passwd -6 -stdin`

echo "init $HOSTNAME"
lxc init -p $PROFILE ubuntu:$UBUNTUVERSION $HOSTNAME


echo "inject cloud init user-data"
export HOSTNAME=$HOSTNAME USERNAME=$USERNAME CRYPTPASSWD=$CRYPTPASSWD GITHUBNAME=$GITHUBNAME

cat $CLOUD_INIT | \
    envsubst | \
    lxc config set $HOSTNAME user.user-data -

lxc config set $HOSTNAME volatile.eth0.hwaddr $MACADDRESS

# echo "Starting System $HOSTNAME"
lxc start $HOSTNAME
