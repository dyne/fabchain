#!/bin/sh

if [ ! -r /var/lib/dyneth/geth/LOCK ]; then
    geth init --datadir /var/lib/dyneth /etc/genesis.conf
fi

geth --networkid 1146703429 \
     -nat extip:$(curl -s https://ifconfig.me/ip) \
     --config /etc/geth.conf
