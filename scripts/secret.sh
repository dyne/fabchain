# extract ethereum's secret key from geth
# needs pip install web3

. scripts/host-lib.sh

sk=`secret_key`
echo && echo "Your secret key:"
echo ${sk} && echo

