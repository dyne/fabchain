#!/bin/bash

if [ "$1" = "" ]; then
    echo >&2 "Usage: $0 dest_address eth_amount "
    exit 1
fi

destaddr=$1
echo >&2 "API Address to fund: $destaddr"

eth_amount=$2
wei_amount=`echo "$1 * 10^18" | bc -l`
echo >&2 "Amount to fund: $wei_amount"

make command \
     CMD="eth.sendTransaction({from: eth.accounts[0], to: \"${destaddr}\", value: \"${wei_amount}\"})"
