# extract ethereum's secret key from geth
# needs pip install web3

. scripts/secret-lib.sh

secret_key
res=$?
if [ ! $res = 0 ]; then
    echo && echo "Error: wrong password?" && echo
    exit 1
else
    echo && echo "Your secret key:"
    echo ${sk} && echo 
fi

