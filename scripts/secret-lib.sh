#!/bin/bash

. scripts/host-lib.sh

sk=''
# On stdin/stdout there is the input/output with the user
# the secret key will be put in the global variable sk
secret_key() {
  keystore=`find ${R}/keystore/ -type f`

  tmp=`mktemp`
  echo "Extracting secret key" && echo

  echo "Type your password (will not be shown in terminal) then press [enter]:"
  stty_orig=$(stty -g) # save original terminal setting.
  stty -echo           # turn-off echoing.
  IFS= read -r passwd  # read the password
  stty "$stty_orig"    # restore terminal setting.

  cat <<EOF > $tmp
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
  sk=`cat $tmp | python`
  rm -f $tmp
}

