#!/bin/bash

# create-hwmac creates a number of mac addresses to be used for VM network devices.
#
# Synopsis
#    create-hwmac [n_addresses [vendor_prefix]]
#
# - The first Parameter is the number of addresses to generate 
# - The second parameter is the vendor-prefix for the addresses in 0X-0X-0X format


N_ADDRESSES=$1

# The default prefix is the linux XEN vendor format as it is used also by 
#    linux for virtual hardware
MAC_PREFIX='00-16-3e'

if [ "x$N_ADDRESSES" = "x" ]
then
    N_ADDRESSES=1
fi

# If a second parameter is passed, then use it as MAC-prefix
if [ "x$2" != "x" ]
then
    MAC_PREFIX=$2
fi

MACTEMPLATE="$MAC_PREFIX-%02X-%02X-%02X\n"

for X in `seq 1 $N_ADDRESSES`
do
    printf "  - macaddress: $MACTEMPLATE $[RANDOM%256] $[RANDOM%256] $[RANDOM%256]"
done