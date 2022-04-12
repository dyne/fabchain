#!/bin/bash

# set by host makefile init
. /home/geth/.ethereum/peerconf.sh

# $1 arg is UID
. /init-geth.sh $1

shift 1
IFS=' '
read -a args <<< "$*"

geth --verbosity 2 \
     --nat extip:${pubip} \
     --config ${data}/api.toml \
     ${password_arg[@]} dumpconfig \
     > ${data}/newapi.toml

geth --verbosity 2 \
     --nat extip:${pubip} \
     --config ${data}/api.toml \
     ${password_arg[@]} \
     2>> ${data}/geth.log

if [ -r ${data}/post-execution-script.sh ]; then
    . ${data}/post-execution-script.sh
fi
