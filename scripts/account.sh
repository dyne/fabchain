#!/bin/bash

bash ./scripts/motd

R=${HOME}/.dyneth
mkdir -p ${R}
umask 022

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
    docker run -it --mount \
	   type=bind,source=${HOME}/.dyneth,destination=/var/lib/dyneth \
	   dyne/dyneth:latest \
	   setuidgid dyneth geth account $* \
	   --datadir /var/lib/dyneth \
	   --keystore /var/lib/dyneth/keys
}    
case "$1" in
    new) empty
	 geth new
	 ;;

    backup) have
	    eval hexsk=`cat ${R}/keys/* | awk -F: '/ciphertext/ {print $2}' RS=,`
	    basesk=`echo "print(O.from_hex(trimq('$hexsk')):base58())" | zenroom 2>/dev/null`
	    printf "YOUR SECRET KEY:\n \033[5m$basesk\033[0m"
	    echo
	    if command -v qrencode >/dev/null; then
		echo
		echo $basesk | qrencode -t ANSI256
	    fi
	    ;;

    restore) have
	     echo "TYPE YOUR SECRET KEY:"
	     read basesk
	     if [[ "$basesk" == "" ]]; then
		 echo "ERROR: EMPTY KEY"
		 exit 1
	     fi
	     err=`mktemp`
	     lua=`mktemp`
	     cat <<EOF > $lua
sk = O.from_base58(trim('${basesk}'))
if #sk ~= 32 then
   error("invalid key length: ".. #sk .. "bytes")
end
EOF
	    sk=`zenroom $lua 2>$err`
	    if [[ $? == 1 ]]; then
		cat $err
		rm -f $err $lua
		echo
		exit 1
	    else
		echo
		echo "SECRET KEY RECOGNIZED:"
		echo " $sk"
	    fi
	    echo "$sk" > $R/keys/.sk
	    geth import  /var/lib/dyneth/keys/.sk
	    rm -f        $R/keys/.sk
	    echo
	    ;;	    
esac
