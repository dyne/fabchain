
## parse bootnodes enr
bootnodes_csv="$HOME/.ethereum/bootnodes.csv"
bootnodes_enr=""
if [ -r "$bootnodes_csv" ]; then
    while read i; do
	if ! [ "$bootnodes_enr" == "" ]; then bootnodes_enr="${bootnodes_enr},"; fi
	bootnodes_enr="${bootnodes_enr}$(echo $i | cut -d' ' -f2)"
    done < $bootnodes_csv
fi
echo "Bootnodes: $bootnodes_enr"
echo

bootnodes_arg=""
if ! [ "$bootnodes_enr" == "" ]; then
	bootnodes_arg="--bootnodes $bootnodes_enr"
fi

## find public IP
pubip=`curl -s https://ifconfig.me/ip`

echo "Public IP: $pubip"
echo

[[ "$1" == "" ]] || {
	print "UID: $1"
	sed -e "s/1000/$1/" -i /etc/passwd
}
