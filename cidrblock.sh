#!/bin/bash

# Stephen Burke - 10/28/2020 - https://github.com/se7enack
clear
x=1
echo;echo "CIDR                    SUBNET                 WILDCARD               BLOCK                 INCREMENT              CLASS";echo
for i in {32..08}
do
  if [[ $i -ge 24 ]]; then
  	class="C"
  elif [[ $i -ge 16 ]]; then
  	class="B"
  else
  	class="A"
  fi
  cidr=$(printf %02d $i)
  s=$(( 0xffffffff ^ ((1 << (32-$i)) -1) ))
  sn=$(( (s>>24) & 0xff )).$(( (s>>16) & 0xff )).$(( (s>>8) & 0xff )).$(( s & 0xff ))
  wc=$(echo  $sn  | awk -F'.' '{print 255-$1 "." 255-$2 "." 255-$3 "." 255-$4}')
  math=$(echo $sn  | sed 's/\.0//' | sed 's/\.0//'  | sed 's/\.0//' | awk -F '.' '{print $(NF)}')
  inc=$((256-$math))
  line='                     '
  printf "%s %s %s %s %s %s\n" "/$cidr" "${line:${#cidr}} $sn ${line:${#sn}} $wc ${line:${#wc}} $x ${line:${#x}} $inc ${line:${#inc}} $class ${line:${#class}}"
  x=$((x*2))
  z=$(())
done | sort 
echo

