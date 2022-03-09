#!/bin/bash

data=/home/geth/.ethereum

function info() { echo >&2 "$1"; }

if [ -r ${data}/pre-execution-script.sh ]; then
    . ${data}/pre-execution-script.sh
fi

keys_found=0
if [ -r ${data}/keystore ]; then
    kpath=`find ${data}/keystore -type f`
    if [ ! "x$kpath" = "x" ]; then
      if [ -r "$kpath" ]; then
          keys_found=1
      fi
    fi
fi
eval hexpk=`cat $kpath | awk -F: '/address/ {print $2}' RS=,`
info "Public address: $hexpk"

## parse bootnodes enr
bootnodes_csv="$HOME/.ethereum/bootnodes.csv"
bootnodes_enr=""
if [ -r "$bootnodes_csv" ]; then
    while read i; do
	if ! [ "$bootnodes_enr" == "" ]; then bootnodes_enr="${bootnodes_enr},"; fi
	bootnodes_enr="${bootnodes_enr}$(echo $i | cut -d' ' -f2)"
    done < $bootnodes_csv
fi
info "Bootnodes: $bootnodes_enr"

bootnodes_arg=()
if ! [ "$bootnodes_enr" == "" ]; then
	bootnodes_arg=(--bootnodes $bootnodes_enr)
fi

password_arg=()
if [ -r "${data}/passfile" ]; then
    password_arg=(--password ${data}/passfile)
fi

## find public IP
pubip=`curl -s https://ifconfig.me/ip`

info "Public IP: $pubip"


[[ "$1" == "" ]] || {
	info "UID: $1"
	sed -e "s/1000/$1/" -i /etc/passwd
}

if [ -r ${data}/genesis.json ]; then
    NETWORK_ID=$(awk '/"chainId":/{sub(/,/,"");print $2}' ${data}/genesis.json | sed 's/ //g')
    ## translate the chainID from numeric to string
    chain_name=`echo "print(BIG.from_decimal('$NETWORK_ID'):octet():string())" | zenroom`
    info "Starting geth for chainID: $chain_name ($NETWORK_ID)"
    # geth init ${data}/genesis.json
else
    info "Missing genesis file"
fi
