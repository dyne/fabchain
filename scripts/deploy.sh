contract="Storage"
docker exec -it ${container} sh -c "cd /contracts && solc --overwrite --bin --abi \"${contract}.sol\" -o build"
exit
tmp=`mktemp`
cat <<EOF >$tmp
from web3 import Web3, HTTPProvider

abi = None
bin = None

with open('contracts/build/Storage.abi') as file:
  abi = file.read()

with open('contracts/build/Storage.bin') as file:
  bin = file.read()

if not abi or not bin:
  print("Error while reading abi or bin")
  exit(-1)

sk = "..."

w3 = Web3(HTTPProvider('http://localhost:8545'))
account = w3.eth.account.privateKeyToAccount(sk)

my_contract = w3.eth.contract(abi=abi, bytecode=bin)
construct_txn = my_contract.constructor().buildTransaction({
    'from': account.address,
    'nonce': w3.eth.getTransactionCount(account.address),
    'gas': 300000,
    'gasPrice': w3.toWei('100', 'gwei')})

signed = account.signTransaction(construct_txn)

print(w3.eth.sendRawTransaction(signed.rawTransaction).hex())

EOF

python $tmp
