x=1
echo;echo "CIDR   BLOCK";echo
for i in {32..08}
do
 echo "/$(printf %02d $i)    $x"
 x=$((x*2))
done | sort
echo
