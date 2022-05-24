#!/bin/bash

TDIR=/home/multimico/src/multimico-cluster
CDIR=/home/multimico/src/cluster-config

HOSTNAME=$1

HYPERVISOR=$( hostname )
INTENT_HOST=$( yq ".nodes[] | select(.name == \"${HOSTNAME}\").host" "${CDIR}/nodes/hardware_macs.yaml" )

if []
then
    echo "Node is not intended for this host!"
    exit 0
fi

IS_RUNNING=$(lxc list --format=yaml | yq ".[] | select(.name == \"${HOSTNAME}\").state.status")

if [ -z $IS_RUNNING ]
then
    echo "Node is not running on this host!"
fi

lxc stop ${HOSTNAME}

echo "Stopped"