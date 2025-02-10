#!/bin/bash

# USAGE
#   > install-vm.sh HOSTNAME MY_USER_NAME MY_GH_NAME
# 
# The Username and Github Name are optional 
#

# CONSTANTS NOT TO CUSTOMISE
# DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
# TDIR=/home/multimico/src/multimico-cluster
# CDIR=/home/multimico/src/cluster-config

# HYPERVISOR=$( hostname )

HOSTNAME=$(petname)

# Parameters

TARGET=$3

# TODO: The username and the GH names should be configurable
USERNAME=$1
GITHUBNAME=$2

# MACADDRESS=$( yq ".nodes[] | select(.name == \"${HOSTNAME}\").macaddress" "${CDIR}/nodes/hardware_macs.yaml" )
# PROFILE=$( yq ".nodes[] | select(.name == \"${HOSTNAME}\").profile" "${CDIR}/nodes/hardware_macs.yaml" )
# INTENT_HOST=$( yq ".nodes[] | select(.name == \"${HOSTNAME}\").host" "${CDIR}/nodes/hardware_macs.yaml" )

# if [ $HYPERVISOR != $INTENT_HOST ]
# then
#     echo "Node is not intendend for this host"
#     exit 0
# fi

# IS_RUNNING=$(lxc list --format=yaml | yq ".[] | select(.name == \"${HOSTNAME}\").state.status")

# if [ "$IS_RUNNING" == "Running" ]
# then
#     echo "Node is already running. Avoid restarting it!"
#     exit 0
# fi

# MACADDRESS=$(echo $MACADDRESS | sed -E s/-/:/g | sed 's/.*/\L&/' )

read -p "which profile you want to use (use incus profile list for available profiles): " PROFILE
echo


if [ -z $PROFILE ]
then
    PROFILE=default
fi

# if [ $PROFILE != "default" ]
# then
#     CLOUD_INIT=${CLOUD_INIT}_${PROFILE}
# fi

# echo "The new host is called '$HOSTNAME'"

# If no username is given as parameter, ask for a username
if [ -z $USERNAME ]
then
    TMPUSERNAME=$(whoami)
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
# extra newline
echo

if [ -z $PASSWD ]
then
    PASSWD=$USERNAME
fi 

# ask for CPU limit
# read -p "CPU Limit (empty for no limit): " CPULIMIT
# echo

# read -p "Memory Limit in GB (empty for no limit): " MEMLIMIT
# echo

# Hash the password for cloud init
PWSALT=$(echo $RANDOM | md5sum | head -c 10)

CRYPTPASSWD=$(echo -n $PASSWD | mkpasswd -m sha-512 -R 4096 -S $PWSALT -s)

# echo "init $HOSTNAME"

# echo "inject cloud init user-data"
export HOSTNAME=$HOSTNAME USERNAME=$USERNAME CRYPTPASSWD=$CRYPTPASSWD GITHUBNAME=$GITHUBNAME TARGET=$TARGET PROFILE=$PROFILE

./setup-instance.sh

# echo "Starting System $HOSTNAME"
# incus start $HOSTNAME
