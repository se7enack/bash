x=1
echo;echo "CIDR                    SUBNET                 BLOCK";echo
for i in {32..08}
do
  cidr=$(printf %02d $i)
  s=$(( 0xffffffff ^ ((1 << (32-$i)) -1) ))
  sn=$(( (s>>24) & 0xff )).$(( (s>>16) & 0xff )).$(( (s>>8) & 0xff )).$(( s & 0xff ))
  line='                     '
  printf "%s %s %s %s \n" /$cidr "${line:${#cidr}} $sn ${line:${#sn}} $x ${line:${#x}}"
  x=$((x*2))
done | sort
echo
