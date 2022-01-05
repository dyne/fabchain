# execute using make from parent directory
# requires bash

R=${DATA}

OUTTMP=/tmp/dyneth_run
PYTHON=python3

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
	   geth $* --datadir /var/lib/dyneth --keystore /var/lib/dyneth/keystore/tmp 
}    
function pk() {
    conf=${1:-`find ${R}/keystore/tmp -type f`}
    cat $conf |$PYTHON -c "import json,sys;obj=json.load(sys.stdin);print(obj['address']);" 2>/dev/null
}

function check_python() {
    if ! [ -x "$(command -v $PYTHON)" ]; then
        echo 'Error: $PYTHON is not installed.' >&2
        exit 1
    fi
}
function check_zenroom() {
    if ! [ -x "$(command -v zenroom)" ]; then
        echo 'Error: zenroom is not installed.' >&2
        exit 1
    fi
}
function check_docker() {
    if ! [ -x "$(command -v docker)" ]; then
        echo 'Error: docker is not installed.' >&2
        exit 1
    fi
}
# main()
case "$1" in
    new) empty
	 	check_python
        check_docker
	 	geth account new 
	 	conf=`find ${R}/keystore/tmp -type f`
	 	addr=`pk $conf`
		if [ ! -f "$conf" ]; then
			echo "cannot find key file" 2>/dev/null
			exit 1
		fi
		if [ -z "$addr" ]; then
			echo "cannot find addr key " 2>/dev/null
			exit 1
		fi
		mv $conf ${R}/keystore/$addr
		rm -rf ${R}/keystore/tmp/
    echo "wallet saved in ${R}/keystore/$addr"
	 	;;

    address) have
	    check_zenroom
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
        check_docker
	  	geth --unlock `pk` --mine
		;;

    backup) have
	    cat ${R}/keystore/*
	    echo ; echo
	    ;;

    restore) empty
        check_python
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
