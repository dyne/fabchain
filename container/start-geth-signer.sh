#!/bin/bash

. /init-geth.sh $1
. ${data}/peerconf.sh

if [ "$keys_found" == "0" ]; then
    echo "Signer keys not found in ${data}/keystore"
    exit 1
fi


geth --networkid ${NETWORK_ID} \
     --ipcpath geth.ipc \
     --nat extip:${pubip} \
     --port ${P2P_PORT} \
     --syncmode "full" \
     --unlock $hexpk --mine \
     ${password_arg} ${bootnodes_arg}
