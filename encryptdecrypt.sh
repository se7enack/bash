#!/bin/bash

KEYS="~/.keys"
MASTERKEY="~/.ssh/.master.key"
mkdir -p ${KEYS}

if ! [[ -f ${MASTERKEY} ]]
then
	echo
	echo "This has not been run before. Generating key: ${MASTERKEY}"
	openssl genrsa -out ${MASTERKEY} 2048 &> /dev/null && echo 'Complete!'
	echo
fi

if [ -z "$1" ] || [ -z "$2" ] 
then
	echo
	echo "Encrypt usage:" 
	echo "$0 {THING_PW_IS_FOR} {USERNAME} '{PASSWORD}'"
	echo "$0 EU2ASA sburke 'p@ssword'" 
	echo "* make sure you wrap password in single quotes"
	echo
	echo "Decrypt usage:"
	echo "$0 {THING_PW_IS_FOR} {USERNAME}"
	echo "$0 EU2ASA sburke"
	echo
	exit
fi

if [ -z "$3" ]
then
	ls -l ${KEYS}/ | grep '^d' | awk  '{ print $9 }' | grep -w ${1} &> /dev/null
	if ! [ $? -eq 0 ]
	then
		echo
		echo "${1} is not a known thing!"
		echo
		echo "Here is the list of things stored:"
		echo
		ls -l ${KEYS}/ | grep '^d' | awk  '{ print $9 }'
		echo
		exit
	elif ls -l ${KEYS}/${1} | awk '{ print $9 }' | grep -w ${2} &> /dev/null
	then	
		DECRYPT=$(openssl rsautl -inkey ${MASTERKEY} -decrypt 2>/dev/null <${KEYS}/${1}/${2})
		if ! [ $? -eq 0 ]
		then
			THINGS=$(ls -l ${KEYS} | grep '^d' | awk  '{ print $9 }')
			for THING in $THINGS
			do
				subthings=$(ls -l ${KEYS}/${thing} | awk  '{ print $9 }')
			    echo $subthings
			done		
			exit
		fi
		echo
		echo Password Decrypted!
		echo
		echo ${DECRYPT}
		echo
	else
		echo
		echo "${2} is not a known key for ${1}"
		echo
		echo "Here is the list of usernames stored for ${1}:"
		ls -l ${KEYS}/${1} | awk  '{ print $9 }'
		echo
		exit
	fi
else	
	mkdir -p ${KEYS}/${1}
	echo "${3}" | openssl rsautl -inkey ${MASTERKEY} -encrypt 2>/dev/null >${KEYS}/${1}/${2}
	if ! [ $? -eq 0 ]
	then
		THINGS=$(ls -l ${KEYS} | grep '^d' | awk  '{ print $9 }')
		echo ${THINGS}
		exit
	fi
	echo
	echo Password Encrypted!
	echo
fi
