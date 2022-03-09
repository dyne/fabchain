#!/bin/bash

# set by host makefile init
. /home/geth/.ethereum/peerconf.sh

# $1 arg is UID
. /init-geth.sh $1

if [ "$keys_found" == "0" ]; then
    echo "Signer keys not found in ${data}/keystore"
    exit 1
fi

cat <<EOF > ${data}/geth.log
geth --networkid ${NETWORK_ID} \
     --verbosity 2 \
     --ipcpath geth.ipc \
     --nat extip:${pubip} \
     --port ${P2P_PORT} \
     --syncmode "full" \
     --unlock $hexpk --mine \
     ${password_arg[@]} ${bootnodes_arg[@]}
EOF
geth --networkid ${NETWORK_ID} \
     --verbosity 2 \
     --ipcpath geth.ipc \
     --nat extip:${pubip} \
     --port ${P2P_PORT} \
     --syncmode "full" \
     --unlock $hexpk --mine \
     ${password_arg[@]} ${bootnodes_arg[@]} \
     2>> ${data}/geth.log

if [ -r ${data}/post-execution-script.sh ]; then
    . ${data}/post-execution-script.sh
fi
