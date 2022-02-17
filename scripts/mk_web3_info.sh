TXID=$1
cat <<EOF
from web3 import Web3, HTTPProvider
import json

w3 = Web3(HTTPProvider('http://127.0.0.1:8545'))

def toDict(dictToParse):
  # convert any 'AttributeDict' type found to 'dict'
  parsedDict = dict(dictToParse)
  for key, val in parsedDict.items():
    if 'list' in str(type(val)):
      parsedDict[key] = [_parseValue(x) for x in val]
    else:
      parsedDict[key] = _parseValue(val)
  return parsedDict

def _parseValue(val):
  # check for nested dict structures to iterate through
  if 'dict' in str(type(val)).lower():
    return toDict(val)
  # convert 'HexBytes' type to 'str'
  elif 'HexBytes' in str(type(val)):
    return val.hex()
  else:
    return val

try:
  tx = w3.eth.getTransactionReceipt("$TXID")
  tx = toDict(tx)
  tx = json.dumps(tx, indent=2)
  print("Transaction recipe")
  print(tx)
except Exception as e:
  print("Could not read transaction. Make sure the transaction hash is correct, "+
        "otherwise the transaction hasn't been accepted yet")
  print("Error: {}".format(e))
EOF
