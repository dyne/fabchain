# extract ethereum's secret key from geth
# needs pip install web3

. scripts/secret-lib.sh

secret_key
echo && echo "Your secret key:"
echo ${sk} && echo 

