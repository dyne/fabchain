#!/bin/bash

# set by host makefile init
. /home/geth/.ethereum/peerconf.sh

# $1 arg is UID
. /init-geth.sh $1

if [ "$keys_found" == "0" ]; then
    echo "Signer keys not found in ${data}/keystore"
    exit 1
fi

geth --verbosity 2 \
     --nat extip:${pubip} \
     --config ${data}/sign.toml \
     --unlock $hexpk --mine \
     ${password_arg[@]} dumpconfig \
     > ${data}/currentsign.toml
geth --verbosity 2 \
     --nat extip:${pubip} \
     --config ${data}/sign.toml \
     --unlock $hexpk --mine \
     ${password_arg[@]} \
     2>> ${data}/geth.log

if [ -r ${data}/post-execution-script.sh ]; then
    . ${data}/post-execution-script.sh
fi
