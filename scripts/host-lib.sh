R=${DATA}
tag=$(cat ${R}/hash.tag)
DOCKER_IMAGE=$(cat ${R}/version)
umask 077

function empty() {
    if [[ "$(ls -A ${R}/keystore 2>/dev/null)" ]]; then
	echo "ERROR: account already created, will not overwrite"
	echo "  see: ${R}/keystore"
	echo "  try: make backup"
	echo
	exit 1
    fi
}
function have() {
    if ! [[ "$(ls -A ${R}/keystore 2>/dev/null)" ]]; then
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
	   ${DOCKER_IMAGE} \
	   geth $*
}    
function python() {
    docker run -i \
	   --mount type=bind,source=${R},destination=/home/geth/.ethereum \
	   --mount type=bind,source=${CONTRACTS},destination=/contracts \
	   ${DOCKER_IMAGE} \
           python3 $*
}
function pk() {
    conf=${1:-`find ${R}/keystore/ -type f`}
    echo "print(JSON.decode(DATA).address)" | zenroom -a $conf 2> /dev/null
}

secret_key() {
  keystore=`find ${R}/keystore/ -type f`
  passwd=`cat ${R}/passfile`

  cat <<EOF | python
from web3.auto import w3
import os

# Find the first file in the keystore
path = "/home/geth/.ethereum/keystore"
keyfile_path = None
for file in os.listdir(path):
  file = os.path.join(path, file)
  if os.path.isfile(file):
    keyfile_path = file
    break

with open(keyfile_path) as keyfile:
    encrypted_key = keyfile.read()
    private_key = w3.eth.account.decrypt(encrypted_key, '${passwd}')
    print(private_key.hex())
EOF
}
function public_key() {
  # cut used to remove 0x and the first byte of the public key
  echo "print(ECDH.pubgen(O.from_hex(\"`secret_key | cut -c 3-`\")):hex())" | zenroom 2>/dev/null | cut -c 3-
}
