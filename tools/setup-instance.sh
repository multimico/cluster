#!/bin/bash

# USAGE
#   > setup-instance.sh
# 
# The Username and Github Name are optional 
# 
# Requies the following variables to be set:
# export HOSTNAME=$HOSTNAME USERNAME=$USERNAME CRYPTPASSWD=$CRYPTPASSWD GITHUBNAME=$GITHUBNAME RELEASE=$OSVERSIONNAME
#

# HYPERVISOR=$( hostname )

# Variables
# TODO: We want to customise the image
OSNAME=ubuntu
OSVERSION="24.04"

OSVERSIONNAME=$(osinfo-query os short-id=${OSNAME}${OSVERSION} -f codename | tail -n 1 | sed -E "s/^\\s*(\\w+).*/\\L\\1/")

CLOUD_INIT=~/tools/cluster-config/profiles/cloud_init.cfg

if [ -z $PROFILE ]
then
    PROFILE=default
fi
# echo "init $HOSTNAME"

# echo "inject cloud init user-data"
export HOSTNAME=$HOSTNAME USERNAME=$USERNAME CRYPTPASSWD=$CRYPTPASSWD GITHUBNAME=$GITHUBNAME RELEASE=$OSVERSIONNAME

# CIDATA=$(cat $CLOUD_INIT | envsubst | yq ".users[].ssh_import_id = (load(\"${CDIR}/nodes/hardware_macs.yaml\").nodes[] | select(.name == \"${HOSTNAME}\" ).ssh-ids)" )

CIDATA=$(cat $CLOUD_INIT | envsubst )

# TODO extend CIDATA based on the profile

if [ -z "$TARGET" ]
then
    incus init -p $PROFILE images:${OSNAME}/${OSVERSION}/cloud $HOSTNAME
else 
    incus init -p $PROFILE images:${OSNAME}/${OSVERSION}/cloud $HOSTNAME --target $TARGET
fi

echo "${CIDATA}" | incus config set $HOSTNAME cloud-init.user-data -
cat ~/tools/cluster-config/profiles/network_init.cfg | incus config set $HOSTNAME cloud-init.network-config -
