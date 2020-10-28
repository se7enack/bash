x=1
echo;echo "CIDR                    SUBNET                 BLOCK                 INCREMENT";echo
for i in {32..08}
do
  cidr=$(printf %02d $i)
  s=$(( 0xffffffff ^ ((1 << (32-$i)) -1) ))
  sn=$(( (s>>24) & 0xff )).$(( (s>>16) & 0xff )).$(( (s>>8) & 0xff )).$(( s & 0xff ))
  math=$(echo $sn  | sed 's/\.0//' | sed 's/\.0//'  | sed 's/\.0//' | awk -F '.' '{print $(NF)}')
  inc=$((256-$math))
  line='                     '
  printf "%s %s %s %s %s\n" "/$cidr" "${line:${#cidr}} $sn ${line:${#sn}} $x ${line:${#x}} $inc ${line:${#inc}}"
  x=$((x*2))
done | sort 
echo
