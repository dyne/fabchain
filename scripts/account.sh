#!/bin/bash

R=${DATA}

function empty() {
    if [[ -r ${R}/keystore ]]; then
	echo "ERROR: account already created, will not overwrite"
	echo "  see: ${R}/keystore"
	echo "  try: make backup"
	echo
	exit 1
    fi
}
function have() {
    if [[ ! -r ${R}/keystore ]]; then
	echo "ERROR: account not found"
	echo "  see: ${R}/keystore"
	echo "  try: make account"
	exit 1
    fi
}
function blink() {
    printf "\033[5m${1}\033[0m\n"
}
function geth() {
    docker run -it \
	   --mount type=bind,source=${R},destination=/var/lib/dyneth \
	   dyne/dyneth \
	   setuidgid dyneth geth $* \
	   --datadir /var/lib/dyneth \
	   --keystore /var/lib/dyneth/keystore
}    
function pk() {
    conf=${1:-`find ${R}/keystore/ -type f`}
    echo "print(JSON.decode(DATA).address)" | zenroom -a $conf 2> /dev/null
}

# main()
case "$1" in
    new) empty
	 geth account new
	 conf=`find ${R}/keystore/ -type f`
	 addr=`pk $conf`
	 mv $conf ${R}/keystore/$addr
	 ;;

    address) have
	     conf=`find ${R}/keystore/ -type f`
	     cat <<EOF | zenroom -a $conf 2> /dev/null
conf=JSON.decode(DATA)
print('PUBLIC ADDRESS:')
print(' 0x'..conf.address)
print('Genesis extradata:')
print('0x'..O.zero(32):hex()..conf.address..O.zero(65):hex())
EOF
	     ;;

    mine) have
	  geth --unlock `pk` --mine
	  ;;

    backup) have
	    cat ${R}/keystore/*
	    echo ; echo
	    ;;

    restore) empty
	     echo "TYPE YOUR SECRET KEY:"
	     read basesk
	     tmp=`mktemp`
	     echo "$basesk" > $tmp
	     addr=`pk $tmp`
	     mkdir -p ${R}/keystore/
	     echo $basesk > ${R}/keystore/${addr}
	     echo "KEY RESTORED: $addr"
	     ls -l ${R}/keystore/${addr}
	     rm -f $tmp
	     echo
	    ;;	    
esac
