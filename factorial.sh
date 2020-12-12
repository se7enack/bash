#!/bin/bash

COUNTER=1
re='^[0-9]+$'

factorials() {
    if (( ${1} <= 1 )); then
        echo 1
    else
        last=$(factorials $(( ${1} - 1 )))
        echo $(( ${1} * last ))
    fi
}

if ! [[ ${1} =~ ${re} ]] || [[ ${1} > 20 ]]; then
   echo -e "\nThis excepts integers between 1 and 20 only" 
   echo -e "Example: ${0} [1-20]\n" >&2; exit 1
else
	COUNT=$(( ${1}+1 ))
fi

while [ ${COUNTER} -lt ${COUNT} ]; do
	factorials ${COUNTER}
	let COUNTER=COUNTER+1 
done
      
