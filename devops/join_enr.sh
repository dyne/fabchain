BN_FILE="bootnodes.csv"
rm -f $BN_FILE 
touch $BN_FILE
for f in enr-*; do
  ip=`echo $f | cut -d'-' -f2`
  enr=`cat $f | xargs`
  echo "$ip $enr" >> $BN_FILE
done
