#!/bin/bash

# This script is ONLY for demonstration purposes!

# USAGE
#   > install-docker.sh CLOUD_INIT_FILE [MACADDRESS [HOSTNAME]]

# HOSTNAME=`petname`

# Constants
OSNAME=ubuntu
OSVERSION="22.04"
PROFILE=docker

# Parameters
CLOUD_INIT=$1

# Optional Parameters
MACADDRESS=$2
HOSTNAME=$3

if [ -z $CLOUD_INIT ]
then
    echo "No cloud init file provided. Don't know what to do."
    exit 1
fi

if [ ! -f $CLOUD_INIT ]
then
    echo "Cloud Init File does not exist. "
    exit 1
fi

if [ -z $HOSTNAME ]
then
    HOSTNAME=$( petname )
    echo "create new system with $HOSTNAME" 
fi

# TODO: The username and the GH names should be configurable
USERNAME=
GITHUBNAME=

IS_RUNNING=$( lxc list --format=yaml | yq ".[] | select(.name == \"${HOSTNAME}\").state.status" )

if [ "$IS_RUNNING" == "Running" ]
then
    echo "Node is already running. Avoid restarting it!"
    exit 0
fi

if [ -z $MACADDRESS ]
then
    MACADDRESS=$( printf "00-16-3e-%02X-%02X-%02X" $[RANDOM%256] $[RANDOM%256] $[RANDOM%256] )
fi

MACADDRESS=$( echo ${MACADDRESS} | sed -E s/-/:/g | sed 's/.*/\L&/' )

# echo "The new host is called '$HOSTNAME'"

# If no username is given as parameter, ask for a username
if [ -z $USERNAME ]
then
    TMPUSERNAME=$( whoami )
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
    echo "Empty passwords are forbidden"
    exit 1
fi

# Hash the password for cloud init
CRYPTPASSWD=$( echo -n $PASSWD | openssl passwd -6 -stdin )

# get the code name for the docker repos
OSVERSIONNAME=$( osinfo-query os short-id=${OSNAME}${OSVERSION} -f codename | tail -n 1 | sed -E "s/^\\s*(\\w+).*/\\L\\1/" )

export HOSTNAME=$HOSTNAME USERNAME=$USERNAME CRYPTPASSWD=$CRYPTPASSWD GITHUBNAME=$GITHUBNAME RELEASE=$OSVERSIONNAME

lxc init -p $PROFILE ${OSNAME}:$OSVERSION $HOSTNAME

echo "$(cat $CLOUD_INIT | envsubst )" | lxc config set $HOSTNAME user.user-data -

lxc config set $HOSTNAME volatile.eth0.hwaddr $MACADDRESS

# echo "Starting System $HOSTNAME"
lxc start $HOSTNAME
