#!/bin/sh

. /init-geth.sh $1

setuidgid geth geth --networkid $CONF_NETWORK_ID \
     --datadir /home/geth/.ethereum \
     --ipcpath geth.ipc \
     --port $CONF_P2P_PORT --nodiscover \
     --nat extip:${pubip} \
     --syncmode "snap" \
     --http --http.port $CONF_API_PORT --http.vhosts '*' --http.api web3,eth \
     --bootnodes ${andrea_enr},${jaromil_enr},${puria_enr}
