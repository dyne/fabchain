TXID=$1
cat <<EOF
from web3 import Web3, HTTPProvider
import json
from hexbytes import HexBytes

w3 = Web3(HTTPProvider('http://127.0.0.1:8545'))

try:
  tx = dict(w3.eth.getTransactionReceipt("$TXID"))
  tx = { k: v if type(v) != HexBytes else v.hex() for k, v in tx.items() }
  tx = json.dumps(tx, indent=2)
  print("Transaction recipe")
  print(tx)
except Exception as e:
  print("Could not read transaction. Make sure the transaction hash is correct, "+
        "otherwise the transaction hasn't been accepted yet")
  print("Error: {}".format(e))
EOF
