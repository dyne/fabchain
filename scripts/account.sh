#!/bin/bash

R=${HOME}/.dyneth

function empty() {
    if [[ -r ${R}/keys ]]; then
	echo "ERROR: account already created, will not overwrite"
	echo "  see: ${R}/keys"
	echo "  try: make backup"
	echo
	exit 1
    fi
}
function have() {
    if [[ ! -r ${R}/keys ]]; then
	echo "ERROR: account not found"
	echo "  see: ${R}/keys"
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
	   --keystore /var/lib/dyneth/keys
}    
function pk() {
    conf=${1:-`find ${R}/keys/ -type f`}
    echo "print(JSON.decode(DATA).address)" | zenroom -a $conf 2> /dev/null
}

# main()
case "$1" in
    new) empty
	 geth account new
	 conf=`find ${R}/keys/ -type f`
	 addr=`pk $conf`
	 mv $conf ${R}/keys/$addr
	 ;;

    address) have
	     conf=`find ${R}/keys/ -type f`
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
	    cat ${R}/keys/*
	    echo ; echo
	    ;;

    restore) empty
	     echo "TYPE YOUR SECRET KEY:"
	     read basesk
	     tmp=`mktemp`
	     echo "$basesk" > $tmp
	     addr=`pk $tmp`
	     mkdir -p ${R}/keys/
	     echo $basesk > ${R}/keys/${addr}
	     echo "KEY RESTORED: $addr"
	     ls -l ${R}/keys/${addr}
	     rm -f $tmp
	     echo
	    ;;	    
esac
