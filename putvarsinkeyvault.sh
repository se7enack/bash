  
#!/bin/bash
# This will create a keyvault in Azure and populate it with your key value pairs from a file.
# Usage: ./putvarsinkeyvault.sh mykeyvaluepairs.properties 

propertiesfile=${1}
subscriptionid="PUT_YOUR_AZURE_SUBSCRIPTION_ID_HERE"
location="eastus2"
keyvaultname="foobar"
pscmd=$(which pwsh)

mkdir -p ps1
echo "Set-AzContext -Subscription ${subscriptionid}" > ./ps1/${keyvaultname}.ps1
echo "New-AzureRmKeyVault -VaultName ${keyvaultname} -ResourceGroupName ${resourcegroupname} -Location ${location}" >> ./ps1/${keyvaultname}.ps1

while IFS= read -r line
do
  var="$( cut -d '=' -f 1 <<< "$line" )"
  varfix="${var//\_/-}"
  value="$( cut -d '=' -f 2- <<< $line )"
  echo "$"${var} " = ConvertTo-SecureString -String " ${value} " -AsPlainText -Force" >> ./ps1/${keyvaultname}.ps1
  echo "Set-AzureKeyVaultSecret -VaultName "${keyvaultname}" -Name "${varfix}" -SecretValue $"${var} >> ./ps1/${keyvaultname}.ps1
  echo
done < "${propertiesfile}"

${pscmd} ./ps1/${keyvaultname}.ps1
