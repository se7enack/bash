#!/usr/bin/env bash

encryption="aes-256-cbc"

key() {
    if [ -z "$key" ]; then
        read -e -s key
        key
    fi
}

clear
echo;echo -n "Enter your personal encryption key: "
key
echo "$key" | sed 's/./*/g';echo

PS3='Choose a valid option number: '
options=("Encrypt" "Decrypt" "Quit")
select option in "${options[@]}"; do
    case $option in
        "Encrypt")
            echo "Write message to encoded: "
            read -e msg
            echo "${option}ing...";echo
            x=$(echo ${msg} | base64 | openssl ${encryption} -a -salt -pass pass:${key}| base64)
            findeq="${x//[^\=]}"
            if [ -z "$findeq" ]; then
                numeq=0
                echo "${x}${numeq}" | rev
            else
                numeq=$(echo "${#findeq}")
                echo $x | sed "s|$findeq|$numeq|g" | rev
            fi
            echo
            exit
            ;;
        "Decrypt")
            echo "Paste in message to decode: "
            read -e gsm
            msg=$(echo $gsm | rev)
            echo "${option}ing...";echo
            numeq=${msg: -1}
            base=$(echo -n ${msg} | rev | cut -c2- | rev)
            while [  $numeq -gt 0 ]; do
                base="${base}="
                let numeq=numeq-1 
            done
            solve=$(echo ${base} | base64 -D 2> /dev/null | openssl aes-256-cbc -d -a -pass pass:${key} 2> /dev/null)
            if [ $? == 0 ]; then
                echo ${solve} | base64 -D
            else
                echo "Incorrect encryption key provided. Please try again."
            fi
            echo
            exit      
            ;;
	"Quit")
	    exit
	    ;;
        *) echo "You selected \"$REPLY\" however that is an invalid option. Please try again.";;
    esac
done
