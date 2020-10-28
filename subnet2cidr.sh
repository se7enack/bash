OIFS=$IFS
IFS='.'
ip=($1)
IFS=$OIFS
if [[ ${ip[0]} -le 255 && ${ip[1]} -le 255 && ${ip[2]} -le 255 && ${ip[3]} -le 255 ]]; then
  c=0 x=0$( printf '%o' ${1//./ } )
  while [ $x -gt 0 ]; do
      let c+=$((x%2)) 'x>>=1'
  done
  echo /$c
else
  echo;echo "Usage: $0 255.255.255.0";echo
fi
