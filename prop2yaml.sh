#!/bin/bash
if [ -z "$1" ]
then
  printf "\nYou'll need to specify a instance name.\n"
  printf "Usage: $0 instanceX\n\n"
  exit 1
else
  if ! [[ -f "${1}.properties" ]]; then
      printf "\nCould not read from source file... \n${1}.properties does not exist in this directory.\n\n"
      exit 1
  fi
  OUTPUT="${1}-secrets.yaml"
  echo "apiVersion: v1" > ${OUTPUT}
  echo "kind: Secret" >> ${OUTPUT}
  echo "metadata:" >> ${OUTPUT}
  echo "  name: ${1}-secrets" >> ${OUTPUT}
  echo "  namespace: {{NAMESPACE}}" >> ${OUTPUT}
  echo "type: Opaque" >> ${OUTPUT}
  echo "stringData:" >> ${OUTPUT}
  while IFS= read -r line
  do
    KEY="$( cut -d '=' -f 1  <<< "$line" )"
    VALUE="$( cut -d '=' -f 2- <<< $line )" 
    VALUEFIX=$(echo $VALUE | sed 's|${DATACENTER}|{{DATACENTER}}|g' | sed 's|${INSTANCE_NAME}|{{INSTANCE_NAME}}|g')
    echo "  ${KEY}: ${VALUEFIX}" | grep -v '^ *#' >> ${OUTPUT}
  done < "${1}.properties"
fi
printf "\n${OUTPUT} has been created\n\n"
