#!/bin/bash

# set by host makefile init
. /home/geth/.ethereum/peerconf.sh

# $1 arg is UID
. /init-geth.sh $1

shift 1
IFS=' '
read -a args <<< "$*"

cat <<EOF > ${data}/geth.log
geth --networkid $NETWORK_ID \
     --verbosity 2 \
     --ipcpath geth.ipc \
     --port $P2P_PORT \
     --nat extip:${pubip} \
     --http --http.addr "0.0.0.0" \
     --http.port $API_PORT --http.vhosts '*' \
     --http.api personal,web3,eth,net \
     ${password_arg[@]} ${bootnodes_arg[@]} ${args[@]}
EOF
geth --networkid $NETWORK_ID \
     --verbosity 2 \
     --ipcpath geth.ipc \
     --port $P2P_PORT \
     --nat extip:${pubip} \
     --http --http.addr "0.0.0.0" \
     --http.port $API_PORT --http.vhosts '*' \
     --http.api personal,web3,eth,net \
     ${password_arg[@]} ${bootnodes_arg[@]} ${args[@]} \
     2>> ${data}/geth.log

if [ -r ${data}/post-execution-script.sh ]; then
    . ${data}/post-execution-script.sh
fi
