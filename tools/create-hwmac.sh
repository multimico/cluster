#!/bin/bash

# create-hwmac creates a number of mac addresses to be used for VM network devices.
#
# Synopsis
#    create-hwmac [n_addresses [vendor_prefix]]
#
# - The first Parameter is the number of addresses to generate 
# - The second parameter is the vendor-prefix for the addresses in 0X-0X-0X format

# ask for user input and store it in a variable
read -p 'How many mac-addresses shall be generated: ' N_ADDRESSES

# regular expression the user input is tested against
re='^([[:digit:]]{0,2})$'

# comparing the user input to regex
# if true start the calculation of mac addresses 
if [[ $N_ADDRESSES =~ $re ]]
then 
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
        printf "  - macaddress: $MACTEMPLATE" $[RANDOM%256] $[RANDOM%256] $[RANDOM%256]
    done
# if the user input is invalid print a comment
else
    echo "Please enter a number ..."
fi
