#!/bin/sh

geth --networkid 1146703429 \
     -nat extip:$(curl -s https://ifconfig.me/ip) \
     --config /etc/geth.conf
