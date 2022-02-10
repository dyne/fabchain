#!/bin/bash

. /init-geth.sh $1
. ${data}/peerconf.sh

geth --networkid $NETWORK_ID \
     --ipcpath geth.ipc \
     --port $P2P_PORT \
     --nat extip:${pubip} \
     --syncmode "${2:-snap}" \
     --http --http.addr "0.0.0.0" \
     --http.port $API_PORT --http.vhosts '*' \
     --http.api web3,eth,net \
     ${password_arg[@]} ${bootnodes_arg[@]}
