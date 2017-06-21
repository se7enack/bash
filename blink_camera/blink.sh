#!/bin/bash

#Folder in ~ for Blink auth/cred files to be saved
BLINKKEYSTORE=".blink"
URL="prod.immedia-semi.com"

if [ ! -d ~/${BLINKKEYSTORE} ]; then
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
else
	EMAIL=$(sed -n '1p' ~/${BLINKKEYSTORE}/creds)
	PASSWORD=$(sed -n '2p' ~/${BLINKKEYSTORE}/creds)
	AUTHCODE=$(cat ~/${BLINKKEYSTORE}/authcode)

	currentauthtest=$(curl -s -H "Host: ${URL}" -H "TOKEN_AUTH: ${AUTHCODE}" --compressed https://${URL}/homescreen | grep -o '\"message\":\".\{0,12\}' | cut -c12-)
	if [ "$currentauthtest" == "Unauthorized" ]; then 
		curl -s -H "Host: ${URL}" -H "Content-Type: application/json" --data-binary '{ "password" : "'"${password}"'", "client_specifier" : "iPhone 9.2 | 2.2 | 222", "email" : "'"${email}"'" }' --compressed https://${URL}/login | grep -o '\"authtoken\":\".\{0,22\}' | cut -c14-  > ~/${BLINKKEYSTORE}/authcode
		authcode=$(cat ~/${BLINKKEYSTORE}/authcode)
	if [ "${AUTHCODE}" == "" ]; then
		echo "No Authcode received, please check credentials"
		exit
	fi
	fi

	NETWORKID=$(curl -s -H "Host: ${URL}" -H "TOKEN_AUTH: ${AUTHCODE}" --compressed https://${URL}/networks | grep -o '\"summary\":{\".\{0,4\}' | cut -c13-)

	if [ "$1" == "armedstatus" ]; then
		curl -s -H "Host: ${URL}" -H "TOKEN_AUTH: ${AUTHCODE}" --compressed https://${URL}/homescreen | grep  -oh armed\":"\w*" | cut -c8- | head -1
		exit
	elif [ "$1" == "unwatched" ]; then
		curl -s -H "Host: ${URL}" -H "TOKEN_AUTH: ${AUTHCODE}" --compressed https://${URL}/api/v2/videos/unwatched | jq -C 
		exit
	else
	echo "Options currently are: { unwatched, armedstatus }"
	fi
fi
