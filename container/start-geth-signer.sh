#!/bin/bash

. /init-geth.sh $1

if [ "$keys_found" == "0" ]; then
    echo "Signer keys not found in ${data}/keystore"
    exit 1
fi


geth --networkid ${CONF_NETWORK_ID} \
     --ipcpath geth.ipc \
     --nat extip:${pubip} \
     --port ${CONF_P2P_PORT} \
     --syncmode "full" \
     --unlock $hexpk --mine \
     ${password_arg} ${bootnodes_arg}
