#!/bin/sh

# if [ ! -r /var/lib/dyneth/geth/LOCK ]; then
#     geth init --datadir /var/lib/dyneth /etc/genesis.conf
# fi

# bootnodes
andrea_ip="65.108.156.126"
andrea_enr="enr:-KO4QGbWcHhS3NIXSBqKrJizqDxgqGKKJs9by6RyLM8hlA-ifUFhJk9d-0T0BKK1cmLReMyQer4qnjBqKHGWvg07knaGAX4gvUMvg2V0aMfGhPXJWWKAgmlkgnY0gmlwhEFsnH6Jc2VjcDI1NmsxoQKsFewfhKDnlvbNdaSxQ_xpE4J61u8CZXeg4uLiooVXmIRzbmFwwIN0Y3CCdl-DdWRwgnZf"

jaromil_ip="65.108.157.121"
jaromil_enr="enr:-KO4QAUZfSPdt4k60kfdLmTtBjb2oq1xHb3StF_Vnsl7nx_ndWocmvgpYB93flEofHBZvIf3myD6r2KSA00PovQHtKmGAX4g0Qk6g2V0aMfGhPXJWWKAgmlkgnY0gmlwhEFsnXmJc2VjcDI1NmsxoQII8n1As5lvMVt8xEZNFjSFzq5QBaLmfCQvM49RVU5usIRzbmFwwIN0Y3CCdl-DdWRwgnZf"

puria_ip="65.21.184.16"
puria_enr="enr:-KO4QM73KhJg7FIoILVvCc2pgBategeHDaBuH3uah9jAmP_va3WNsWvcsLE7Kv36jqzkjSSIzptaP9N1i-rJdPPo_EuGAX4g0Ctkg2V0aMfGhPXJWWKAgmlkgnY0gmlwhEEVuBCJc2VjcDI1NmsxoQL3pEu27fEvOJfNUUqxVkninXJ-gw6MS4YvIrKDtptmsYRzbmFwwIN0Y3CCdl-DdWRwgnZf"

pubip=`curl -s https://ifconfig.me/ip`

echo "Public IP: $pubip"
echo

[[ "$1" == "" ]] || {
	print "UID: $1"
	sed -e "s/1000/$1/" -i /etc/passwd
}
