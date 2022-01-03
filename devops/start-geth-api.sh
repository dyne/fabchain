#!/bin/sh

. /init-geth.sh

geth --networkid 1146703429 \
     --datadir /var/lib/dyneth \
     --ipcpath geth.ipc \
     --nat extip:${pubip} \
     --syncmode "snap" \
     --http --http.vhosts '*' --http.api web3,eth \
     --bootnodes ${andrea_enr},${jaromil_enr},${puria_enr}
