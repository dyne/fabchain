#!/bin/sh

data=/home/geth/.ethereum

found=0
if [ -r ${data}/keystore ]; then
    kpath=`find ${data}/keystore -type f`
    if [ ! "x$kpath" = "x" ]; then
      if [ -r "$kpath" ]; then
          found=1
      fi
    fi
fi
if [ $found = 0 ]; then
    echo "Signer keys not found in ${data}/keystore"
    exit 1
fi

eval hexpk=`cat $kpath | awk -F: '/address/ {print $2}' RS=,`
echo "Public address: $hexpk" >&2
echo

. /init-geth.sh $1

geth --networkid ${CONF_NETWORK_ID} \
     --ipcpath geth.ipc \
     --nat extip:${pubip} \
     --port ${CONF_P2P_PORT} --nodiscover \
     --syncmode "full" \
     --unlock $hexpk --mine \
     --bootnodes ${andrea_enr},${jaromil_enr},${puria_enr}
