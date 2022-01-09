R=${DATA}
V=$(awk '/^VERSION/ {print $3}' config.mk)
D=$(awk '/^DOCKER/ {print $3}' config.mk)
umask 077

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
	   --mount type=bind,source=${R},destination=/home/geth/.ethereum \
	   ${D}:${V} \
	   geth $*
#	   --datadir /home/geth/.ethereum --keystore /home/geth/.ethereum/keystore
}    
function pk() {
    conf=${1:-`find ${R}/keystore/ -type f`}
    echo "print(JSON.decode(DATA).address)" | zenroom -a $conf 2> /dev/null
}