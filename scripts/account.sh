# execute using make from parent directory
# requires bash

. scripts/host-lib.sh

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
