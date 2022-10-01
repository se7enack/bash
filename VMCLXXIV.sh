#!/usr/bin/env zsh

if ! [ -z ${1+x} ]; then
    varname=${1}
else
    echo "Enter a four digit number (just no numbers with repeating digits): "
    read varname
fi
if  ! [[ ${#varname} == 4 ]] || ! [[ ${varname} =~ ^[0-9]+$ ]]; then
    echo "Sorry, "$varname" is not a four digit number. Try again."
    exit
fi
echo "____________________"

magic(){
    sleep 1
    var=$(echo $varname | sed -e 's/\(.\)/\1 /g')
    rm -f .num
    set $(echo ${var})
    for item in "$@"; do
        echo "$item " >> .num
    done
    rpdcheck=$(cat .num | uniq | tr '\n' ' ' | sed 's/ //g')
    if [[ ${#rpdcheck} < 2 ]]; then
        echo "Sorry, no repeating digits allowed. Try again."
        exit
    fi
    num=$(cat .num | tr '\n' ' ' | sed 's/ //g')
    min=$(cat .num | sort | tr '\n' ' ' | sed 's/ //g')
    max=$(cat .num | sort | tr '\n' ' ' | rev | sed 's/ //g')
    varname=$(($max - 10#$min))
    echo $num
    echo "$max - $min = $varname"
    echo "____________________"
    if [[ $varname == 6174 ]]; then
        echo "------> 6174 <------"
        echo "Kaprekar's Constant!";echo
        exit
    else
    magic  
    fi      
}

magic 
