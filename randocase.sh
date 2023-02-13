#!/bin/bash

flipmode(){
    foo=$(echo $1)
    #foo=$(uuidgen | awk -F '-' '{print $4$5}')
    for (( i=0; i<${#foo}; i++ )); do
    flip=$(($RANDOM % 2))
    x=${foo:$i:1}
    if [[ $x == ' ' ]]
    then
        echo $x
    elif [ $flip == 1 ] 
    then
        x=$(echo $x | tr '[:lower:]' '[:upper:]')
    else
        x=$(echo $x | tr '[:upper:]' '[:lower:]')
    fi
    echo -n "$x"
    done
    echo
}

flipmode ${1}
