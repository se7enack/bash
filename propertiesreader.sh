#!/bin/bash
instance=${1}
echo ${instance}
dc="US"
input="keys_"${instance}".properties"
tmpfile=$(mktemp /tmp/${instance}_keyvault_XXX)
mkdir -p ps1
touch -a ${input}
echo "Set-AzContext -Subscription '{AZURE_SUBSCRIPTION}'" > ./ps1/${instance}.ps1
cat ${input} | grep -v '^#' | sed "s/\${instance_NAME}/$instance/" | sed "s/\${DATACENTER}/$dc/"> ${tmpfile}
while IFS= read -r line
do
  var="$( cut -d '=' -f 1 <<< "$line" )"
  varfix="${var//\_/-}"
  value="$( cut -d '=' -f 2- <<< $line )"
  echo "$"${var} " = ConvertTo-SecureString -String " ${value} " -AsPlainText -Force" >> ./ps1/${instance}.ps1
  echo "Set-AzureKeyVaultSecret -VaultName "${instance}-secrets" -Name "${varfix}" -SecretValue $"${var} >> ./ps1/${instance}.ps1
  echo
done < "${tmpfile}"
rm ${tmpfile}
