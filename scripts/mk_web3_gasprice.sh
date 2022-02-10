cat <<EOF
from web3 import Web3, HTTPProvider
import json
from hexbytes import HexBytes

w3 = Web3(HTTPProvider('http://127.0.0.1:8545'))

print(w3.eth.gasPrice)
EOF
