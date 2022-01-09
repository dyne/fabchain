#!/bin/sh

found=0
if [ -r /var/lib/dyneth/keystore ]; then
    kpath=`find /var/lib/dyneth/keystore -type f`
    if [ ! "x$kpath" = "x" ]; then
	if [ -r "$kpath" ]; then
	    found=1
	fi
    fi
fi
if [ $found = 0 ]; then
    echo "Signer keys not found in /var/lib/dyneth/keystore"
    exit 1
fi

eval hexpk=`cat $kpath | awk -F: '/address/ {print $2}' RS=,`
echo "Public address: $hexpk" >&2
echo

. /init-geth.sh $1

geth --networkid ${CONF_NETWORK_ID} \
     --datadir /var/lib/dyneth \
     --ipcpath geth.ipc \
     --nat extip:${pubip} \
     --port ${CONF_P2P_PORT} --nodiscover \
     --syncmode "full" \
     --unlock $hexpk --mine \
     --bootnodes ${andrea_enr},${jaromil_enr},${puria_enr}
