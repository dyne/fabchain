#!/bin/sh

found=0
if [ -r /var/lib/dyneth/keys ]; then
    kpath=`find /var/lib/dyneth/keys -type f`
    if [ ! "x$kpath" = "x" ]; then
	if [ -r "$kpath" ]; then
	    found=1
	fi
    fi
fi
if [ $found = 0 ]; then
    echo "Signer keys not found in /var/lib/dyneth/keys"
    exit 1
fi

eval hexpk=`cat $kpath | awk -F: '/address/ {print $2}' RS=,`
echo "Public address: $hexpk" >&2
echo
. /init-geth.sh

geth --networkid 1146703429 \
     --datadir /var/lib/dyneth \
     --ipcpath geth.ipc \
     --nat extip:${pubip} \
     --syncmode "full" \
     --unlock $hexpk --mine \
     --bootnodes ${andrea_enr},${jaromil_enr},${puria_enr}
