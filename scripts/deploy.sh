set -e
# Deploy a contract given the solidity script on a network

. scripts/secret-lib.sh

echo "Write the name of the contract (without the extension .sol)"
read contract

# TODO: improved parameters input
echo "Write parameters for the contructor"
read params

# run solc in the container, the solidity script is in the shared
# directory "contracts"
docker exec -it ${container} sh -c "cd /contracts && solc --overwrite --bin --abi \"${contract}.sol\" -o build"

secret_key

tmp=`mktemp`
cat <<EOF >$tmp
from web3 import Web3, HTTPProvider

abi = None
bin = None

with open('/contracts/build/$contract.abi') as file:
  abi = file.read()

with open('/contracts/build/$contract.bin') as file:
  bin = file.read()

if not abi or not bin:
  print("Error while reading abi or bin")
  exit(-1)

sk = "$sk"

w3 = Web3(HTTPProvider('http://localhost:8545'))
account = w3.eth.account.privateKeyToAccount(sk)

my_contract = w3.eth.contract(abi=abi, bytecode=bin)
construct_txn = my_contract.constructor($params).buildTransaction({
    'from': account.address,
    'nonce': w3.eth.getTransactionCount(account.address),
    'gas': 8000000,
    'gasPrice': w3.toWei('100', 'gwei')})

signed = account.signTransaction(construct_txn)

txid=w3.eth.sendRawTransaction(signed.rawTransaction).hex()

print("Transaction id: {}".format(txid))
EOF

cat $tmp | docker exec -i ${container} python3


rm -rf $tmp
