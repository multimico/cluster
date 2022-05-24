#!/bin/bash

# USAGE
#   > install-system.sh MY_USER_NAME MY_GH_NAME
# 
# The Username and Github Name are optional 
#

# CONSTANTS NOT TO CUSTOMISE
# DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
TDIR=/home/multimico/src/multimico-cluster
CDIR=/home/multimico/src/cluster-config

HYPERVISOR=$( hostname )

# HOSTNAME=`petname`

# Variables
# TODO: We want to customise the image
OSNAME=ubuntu
OSVERSION="22.04"

# get the code name for the docker repos
OSVERSIONNAME=$(osinfo-query os short-id=${OSNAME}${OSVERSION} -f codename | tail -n 1 | sed -E "s/^\\s*(\\w+).*/\\L\\1/")
# TODO: We my want to customise the cloud_init file.
CLOUD_INIT=${CDIR}/profiles/cloud_init.cfg

# Parameters
HOSTNAME=$1

# TODO: The username and the GH names should be configurable
USERNAME=$2
GITHUBNAME=$3

MACADDRESS=$( yq ".nodes[] | select(.name == \"${HOSTNAME}\").macaddress" "${CDIR}/nodes/hardware_macs.yaml" )
PROFILE=$( yq ".nodes[] | select(.name == \"${HOSTNAME}\").profile" "${CDIR}/nodes/hardware_macs.yaml" )
INTENT_HOST=$( yq ".nodes[] | select(.name == \"${HOSTNAME}\").host" "${CDIR}/nodes/hardware_macs.yaml" )

if [ $HYPERVISOR != $INTENT_HOST ]
then
    echo "Node is not intendend for this host"
    exit 0
fi

IS_RUNNING=$(lxc list --format=yaml | yq ".[] | select(.name == \"${HOSTNAME}\").state.status")

if [ $IS_RUNNING == "Running" ]
then
    echo "Node is already running. Avoid restarting it!"
    exit 0
fi

MACADDRESS=$(echo $MACADDRESS | sed -E s/-/:/g | sed 's/.*/\L&/' )

if [ -z $PROFILE ]
then
    PROFILE=default
fi

if [ $PROFILE != "default" ]
then
    CLOUD_INIT=${CLOUD_INIT}_${PROFILE}
fi

# echo "The new host is called '$HOSTNAME'"

# If no username is given as parameter, ask for a username
if [ -z $USERNAME ]
then
    TMPUSERNAME=`whoami`
    read -p "System User Name [default $TMPUSERNAME]: " USERNAME

    if [ -z $USERNAME ]
    then
        USERNAME=$TMPUSERNAME
    fi

    read -p "Provide GitHub User for SSH Keys [default $TMPUSERNAME]: " GITHUBNAME

    if [ -z $GITHUBNAME ]
    then
        GITHUBNAME=$TMPUSERNAME
    fi
fi

# Always ask for a default password
read -s -p "Enter password: " PASSWD

# Hash the password for cloud init
CRYPTPASSWD=`echo -n $PASSWD | openssl passwd -6 -stdin`

# echo "init $HOSTNAME"

# echo "inject cloud init user-data"
export HOSTNAME=$HOSTNAME USERNAME=$USERNAME CRYPTPASSWD=$CRYPTPASSWD GITHUBNAME=$GITHUBNAME RELEASE=$OSVERSIONNAME

CIDATA=$(cat $CLOUD_INIT | envsubst | yq ".users[].ssh_import_id = (load(\"${CDIR}/nodes/hardware_macs.yaml\").nodes[] | select(.name == \"${HOSTNAME}\" ).ssh-ids)" )

lxc init -p $PROFILE ${OSNAME}:$OSVERSION $HOSTNAME
echo "${CIDATA}" | lxc config set $HOSTNAME user.user-data -
lxc config set $HOSTNAME volatile.eth0.hwaddr $MACADDRESS

# echo "Starting System $HOSTNAME"
lxc start $HOSTNAME
