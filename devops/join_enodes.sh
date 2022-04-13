BN_FILE="bootnodes.csv"
rm -f $BN_FILE 
touch $BN_FILE
for f in enode-*; do
  enode=`cat $f | xargs`
  echo "$enode" >> $BN_FILE
done
