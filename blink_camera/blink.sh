#!/bin/bash

#Folder in ~ for Blink auth/cred files to be saved
BLINKDIR=".blink"
#API endpoint
URL="prod.immedia-semi.com"
#Output directory for videos
OUTPUTDIR="."

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

helpMe () {
	echo Options are currently limited to: { cameras, unwatched, homescreen, events, newvideos, allvideos }
}

credGet () {
	if [ ! -d ~/${BLINKDIR} ]; then
		mkdir ~/${BLINKDIR}
		echo null > ~/${BLINKDIR}/authcode
		echo Enter your username \(email\):
		read EMAIL
		echo ${EMAIL} > ~/${BLINKDIR}/creds
		echo
		echo Enter your password:
		read PASSWORD
		echo ${PASSWORD} >> ~/${BLINKDIR}/creds
	fi
	EMAIL=$(sed -n '1p' ~/${BLINKDIR}/creds)
	PASSWORD=$(sed -n '2p' ~/${BLINKDIR}/creds)
	AUTHCODE=$(cat ~/${BLINKDIR}/authcode)
	AUTHTEST=$(curl -s -H "Host: ${URL}" -H "TOKEN_AUTH: ${AUTHCODE}" --compressed https://${URL}/homescreen | grep -o '\"message\":\".\{0,12\}' | cut -c12-)
	if [ "${AUTHTEST}" == "Unauthorized" ]; then 
		curl -s -H "Host: ${URL}" -H "Content-Type: application/json" --data-binary '{ "password" : "'"${PASSWORD}"'", "client_specifier" : "iPhone 9.2 | 2.2 | 222", "email" : "'"${EMAIL}"'" }' --compressed https://${URL}/login | grep -o '\"authtoken\":\".\{0,22\}' | cut -c14-  > ~/${BLINKDIR}/authcode
		AUTHCODE=$(cat ~/${BLINKDIR}/authcode)
	if [ "${AUTHCODE}" == "" ]; then
		echo "No Authcode received, please check credentials"
		exit
	fi
	fi
	NETWORKID=$(curl -s -H "Host: ${URL}" -H "TOKEN_AUTH: ${AUTHCODE}" --compressed https://${URL}/networks | grep -o '\"summary\":{\".\{0,6\}' | cut -c13-)
}

preReq;credGet
if [ "$1" == "cameras" ]; then
	curl -s -H "Host: ${URL}" -H "TOKEN_AUTH: ${AUTHCODE}" --compressed https://${URL}/network/${NETWORKID}/cameras | jq -C 
	exit
elif [ "$1" == "unwatched" ]; then
	curl -s -H "Host: ${URL}" -H "TOKEN_AUTH: ${AUTHCODE}" --compressed https://${URL}/api/v2/videos/unwatched  | jq -C
	exit
elif [ "$1" == "homescreen" ]; then
	curl -s -H "Host: ${URL}" -H "TOKEN_AUTH: ${AUTHCODE}" --compressed https://${URL}/homescreen | jq -C
	exit
elif [ "$1" == "events" ]; then
	curl -s -H "Host: ${URL}" -H "TOKEN_AUTH: ${AUTHCODE}" --compressed https://${URL}/events/network/${NETWORKID} | jq -C
	exit
elif [ "$1" == "newvideos" ]; then
	for ADDRESS in $( curl -s -H "Host: ${URL}" -H "TOKEN_AUTH: ${AUTHCODE}" --compressed https://${URL}/api/v2/videos/unwatched | jq '.' | grep address | cut -d \" -f4 ); do
    NAME=$(awk -F/ '{print $NF}' <<< ${ADDRESS})
    curl -s -H "Host: ${URL}" -H "TOKEN_AUTH: ${AUTHCODE}" --compressed https://${URL}/${ADDRESS} > ${OUTPUTDIR}/${NAME}
	done
	exit
elif [ "$1" == "allvideos" ]; then
	for ADDRESS in $( curl -s -H "Host: ${URL}" -H "TOKEN_AUTH: ${AUTHCODE}" --compressed https://${URL}/events/network/${NETWORKID} | jq '.' | grep video_url | cut -d \" -f4 ); do
	    NAME=$(awk -F/ '{print $NF}' <<< ${ADDRESS})
	    curl -s -H "Host: ${URL}" -H "TOKEN_AUTH: ${AUTHCODE}" --compressed https://${URL}/${ADDRESS} > ${OUTPUTDIR}/${NAME}
	done
	exit
else
	helpMe
fi
