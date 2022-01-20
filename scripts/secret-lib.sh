#!/bin/bash

. scripts/host-lib.sh

sk=''
# In the output, the last line is the secret key
secret_key() {
  keystore=`find ${R}/keystore/ -type f`

  tmp=`mktemp`
  cat <<EOF > $tmp
from web3.auto import w3
EOF
  python3 $tmp
  if [ ! $? = 0 ]; then
      echo "Error: web3 python libs not installed: pip install web3"
      return 1
  else
      echo "Extracting secret key" && echo
  fi

  echo "Type your password (will not be shown in terminal) then press [enter]:"
  stty_orig=$(stty -g) # save original terminal setting.
  stty -echo           # turn-off echoing.
  IFS= read -r passwd  # read the password
  stty "$stty_orig"    # restore terminal setting.

  cat <<EOF > $tmp
from web3.auto import w3
with open('${keystore}') as keyfile:
    encrypted_key = keyfile.read()
    private_key = w3.eth.account.decrypt(encrypted_key, '${passwd}')
    print(private_key.hex())
EOF
  sk=`python3 $tmp`
  res=$?
  rm -f $tmp
  return $res
}

