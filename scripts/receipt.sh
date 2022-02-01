echo "Write the transaction hash"
read TXID

tmp=`mktemp`
cat <<EOF >$tmp
from web3 import Web3, HTTPProvider
import json
from hexbytes import HexBytes

w3 = Web3(HTTPProvider('http://85.93.88.149:8545'))

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

python $tmp


rm -rf $tmp
