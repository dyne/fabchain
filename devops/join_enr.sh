BN_FILE="bootnodes.csv"
rm -f $BN_FILE 

for f in enr-*; do
  ip=`echo $f | cut -d'-' -f2`
  enr=`cat $f | xargs`
  echo "$ip $enr" | tee -a $BN_FILE >/dev/null
done
