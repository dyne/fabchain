#!/bin/bash
# wrapper to start geth node

. /init-geth.sh "$1"
. ${data}/peerconf.sh
IFS=' '
read -a args <<< "$2"

## translate the chainID from numeric to string
chain_name=`echo "print(BIG.from_decimal('$NETWORK_ID'):octet():string())" | zenroom`

echo >&2 "Starting geth for chainID: $chain_name ($NETWORK_ID)"
echo >&2 "advertising public ip: $pubip"
echo >&2 "args: ${args[@]}"

if [ -r ${data}/pre-execution-script.sh ]; then
    . ${data}/pre-execution-script.sh
fi

geth --networkid $NETWORK_ID \
     --ipcpath geth.ipc \
     --port $P2P_PORT \
     --nat extip:${pubip} \
     --http --http.addr "0.0.0.0" \
     --http.port $API_PORT --http.vhosts '*' \
     --http.api personal,web3,eth,net \
     ${password_arg[@]} ${bootnodes_arg[@]} \
     ${args[@]}

if [ -r ${data}/post-execution-script.sh ]; then
    . ${data}/post-execution-script.sh
fi
