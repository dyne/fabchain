#!/bin/bash
# wrapper to start geth node

. /init-geth.sh "$1"
. ${data}/peerconf.sh
IFS=' '
read -a args <<< "$2"

geth --networkid $NETWORK_ID \
     --verbosity 2 \
     --ipcpath geth.ipc \
     --port $P2P_PORT \
     --nat extip:${pubip} \
     --http --http.addr "0.0.0.0" \
     --http.port $API_PORT --http.vhosts '*' \
     --http.api personal,web3,eth,net \
     ${password_arg[@]} ${bootnodes_arg[@]} \
     ${args[@]} 2> /home/geth/.ethereum/geth.log

if [ -r ${data}/post-execution-script.sh ]; then
    . ${data}/post-execution-script.sh
fi
