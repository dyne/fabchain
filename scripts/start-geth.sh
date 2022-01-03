#!/bin/sh

if [ ! -r /var/lib/dyneth/geth/LOCK ]; then
    geth init --datadir /var/lib/dyneth /etc/genesis.conf
fi

# bootnodes
# Andrea 65.108.156.126 enr:-KO4QGbWcHhS3NIXSBqKrJizqDxgqGKKJs9by6RyLM8hlA-ifUFhJk9d-0T0BKK1cmLReMyQer4qnjBqKHGWvg07knaGAX4gvUMvg2V0aMfGhPXJWWKAgmlkgnY0gmlwhEFsnH6Jc2VjcDI1NmsxoQKsFewfhKDnlvbNdaSxQ_xpE4J61u8CZXeg4uLiooVXmIRzbmFwwIN0Y3CCdl-DdWRwgnZf
# Jaromil 65.108.157.121

geth --networkid 1146703429 \
     -nat extip:$(curl -s https://ifconfig.me/ip) \
     --config /etc/geth.conf \
     --bootnodes enr:-KO4QGbWcHhS3NIXSBqKrJizqDxgqGKKJs9by6RyLM8hlA-ifUFhJk9d-0T0BKK1cmLReMyQer4qnjBqKHGWvg07knaGAX4gvUMvg2V0aMfGhPXJWWKAgmlkgnY0gmlwhEFsnH6Jc2VjcDI1NmsxoQKsFewfhKDnlvbNdaSxQ_xpE4J61u8CZXeg4uLiooVXmIRzbmFwwIN0Y3CCdl-DdWRwgnZf
