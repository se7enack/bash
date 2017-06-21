#!/bin/bash

#Folder in ~ for Blink auth/cred files to be saved
BLINKKEYSTORE=".blink"
URL="prod.immedia-semi.com"

preReq () {
	if ! [ -x "$(command -v jq)" ]; then
		clear
		echo
		echo "Error: jq package not detected..."
		echo
		echo "     Please install the jq package for your system:"
		echo "           https://stedolan.github.io/jq/ " 
		echo
		exit
	fi
}

mkStore () {
	mkdir ~/${BLINKKEYSTORE}
	echo null > ~/${BLINKKEYSTORE}/authcode
	echo
	echo "Enter your username <email>:"
	read email
	echo $email > ~/${BLINKKEYSTORE}/creds
	echo 
	echo "Enter your password:"
	read password
	echo ${PASSWORD} >> ~/${BLINKKEYSTORE}/creds
	echo
	echo "Creds Saved to ~/${BLINKKEYSTORE}/"
}

getStore () {
	EMAIL=$(sed -n '1p' ~/${BLINKKEYSTORE}/creds)
	PASSWORD=$(sed -n '2p' ~/${BLINKKEYSTORE}/creds)
	AUTHCODE=$(cat ~/${BLINKKEYSTORE}/authcode)
	AUTHTEST=$(curl -s -H "Host: ${URL}" -H "TOKEN_AUTH: ${AUTHCODE}" --compressed https://${URL}/homescreen | grep -o '\"message\":\".\{0,12\}' | cut -c12-)
	if [ "${AUTHTEST}" == "Unauthorized" ]; then 
		curl -s -H "Host: ${URL}" -H "Content-Type: application/json" --data-binary '{ "password" : "'"${password}"'", "client_specifier" : "iPhone 9.2 | 2.2 | 222", "email" : "'"${email}"'" }' --compressed https://${URL}/login | grep -o '\"authtoken\":\".\{0,22\}' | cut -c14-  > ~/${BLINKKEYSTORE}/authcode
		authcode=$(cat ~/${BLINKKEYSTORE}/authcode)
	if [ "${AUTHCODE}" == "" ]; then
		echo "No Authcode received, please check credentials"
		exit
	fi
	fi
	NETWORKID=$(curl -s -H "Host: ${URL}" -H "TOKEN_AUTH: ${AUTHCODE}" --compressed https://${URL}/networks | grep -o '\"summary\":{\".\{0,6\}' | cut -c13-)
}


helpMe () {
	echo "Options currently are: { unwatched, armedstatus, cameras }"
}


preReq
if [ ! -d ~/${BLINKKEYSTORE} ]; then
	mkStore
else
	getStore
fi
if [ "$1" == "armedstatus" ]; then
	curl -s -H "Host: ${URL}" -H "TOKEN_AUTH: ${AUTHCODE}" --compressed https://${URL}/homescreen | grep  -oh armed\":"\w*" | cut -c8- | head -1
	exit
elif [ "$1" == "cameras" ]; then
	curl -s -H "Host: ${URL}" -H "TOKEN_AUTH: ${AUTHCODE}" --compressed https://${URL}/network/${NETWORKID}/cameras | jq -C 
	exit
elif [ "$1" == "unwatched" ]; then
	curl -s -H "Host: ${URL}" -H "TOKEN_AUTH: ${AUTHCODE}" --compressed https://${URL}/api/v2/videos/unwatched | jq -C 
	exit
else
helpMe
fi
