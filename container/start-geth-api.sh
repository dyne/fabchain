#!/bin/sh

. /init-geth.sh $1

geth --networkid $CONF_NETWORK_ID \
     --ipcpath geth.ipc \
     --port $CONF_P2P_PORT --nodiscover \
     --nat extip:${pubip} \
     --syncmode "snap" \
     --http --http.addr "0.0.0.0" --http.port $CONF_API_PORT --http.vhosts '*' --http.api web3,eth \
     --bootnodes ${bootnodes_enr}
