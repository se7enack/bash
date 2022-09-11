#!/usr/bin/env bash

clear
echo;echo -n "Enter your personal encryption key: "
read -e -s key
clear
PS3='Choose a valid option number: '
options=("Encrypt" "Decrypt" "Quit")
select option in "${options[@]}"; do
    case $option in
        "Encrypt")
            echo "Write message to encoded: "
            read -e msg
            echo "${option}ing...";echo
            echo ${msg} | base64 | openssl aes-256-cbc -a -salt -pass pass:${key}| base64;echo
            exit
            ;;
        "Decrypt")
            echo "Paste in message to decode: "
            read -e msg
            echo "${option}ing...";echo
            solve=$(echo ${msg} | base64 -D 2> /dev/null | openssl aes-256-cbc -d -a -pass pass:${key} 2> /dev/null)
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
