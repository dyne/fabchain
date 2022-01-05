# host machine local script
#
# Copyright (C) Dyne.org foundation
# licensed AGPLv3

pubip=`curl -s https://ifconfig.me/ip`

lanip=`ip route get 1 | awk '{print $(NF-2);exit}'`

if [ "$3" = "" ]; then
    echo "Usage: upnp.sh [open|close] port [tcp|udp]"
    exit 1
fi
port="$2"
proto="$3"

gw=`upnpc -P 2>/dev/null | awk '
BEGIN { found=0 }
/^ desc:/ { found=$2; next}
/^ st: .*InternetGatewayDevice/ { print(found); exit }
'`

case $1 in
    open)
	upnpc -u $gw -a $lanip $port $port $proto 1>/dev/null 2>/dev/null
	if [ $? = 0 ]; then echo "UPNP forwarding $port $proto to $lanip"; fi
	;;
    close)
	upnpc -u $gw -d $port $proto 1>/dev/null 2>/dev/null
	if [ $? = 0 ]; then echo "UPNP stopped port forwarding $port $proto"; fi
	;;
esac

