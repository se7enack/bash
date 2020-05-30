#!/bin/bash

TEMPLATE=".master.tmpl"
CLUSTER="k8sClusterName"
DC="datacenterName"
SERVICES=( idm services management reporting usermanagement )
THINSTANCES=( onedevops )
DCUPPER=$(echo $DC | tr '[:lower:]' '[:upper:]')

rm -f .${CLUSTER}.yaml .setvaults.sh

printf '''
apiVersion: "aadpodidentity.k8s.io/v1"
kind: AzureIdentityBinding
metadata:
  name: {{CLUSTER}}-{{SERVICE}}-identity
spec:
  AzureIdentity: {{CLUSTER}}-{{SERVICE}}-identity
  Selector: {{CLUSTER}}-{{SERVICE}}-identity
---
apiVersion: "aadpodidentity.k8s.io/v1"
kind: AzureIdentity
metadata:
  name: {{CLUSTER}}-{{SERVICE}}-identity
spec:
  type: 0
  ResourceID: {{RID}}
  ClientID: {{CID}}
---
''' | sed '1d' > ${TEMPLATE}

az ad group show --group SECGRP-${DCUPPER}-MI
if [ $? -eq 0 ]; then
	echo "SECGRP-${DCUPPER}-MI already exists, skipping create"
else
	echo "Creating SECGRP-${DCUPPER}-MI"
	az ad group create  --display-name SECGRP-${DCUPPER}-MI --mail-nickname SECGRP-${DCUPPER}-MI
fi
OBID=$(az ad group show --group SECGRP-${DCUPPER}-MI --query objectId)

for SERVICE in "${SERVICES[@]}"
do
	az identity create -g ${CLUSTER} -n ${CLUSTER}-${SERVICE}-identity && sleep 10 &&\
	az ad group member add --group SECGRP-${DCUPPER}-MI --member-id $(az identity show --query principalId -otsv -n ${CLUSTER}-${SERVICE}-identity --resource-group ${CLUSTER})
	CID=$(az identity show --query clientId -otsv -n ${CLUSTER}-${SERVICE}-identity --resource-group ${CLUSTER})
	RID=$(az identity show -g ${CLUSTER} -n  ${CLUSTER}-${SERVICE}-identity  --query id -otsv)
	cat ${TEMPLATE} | sed "s/{{CLUSTER}}/$CLUSTER/g" | sed "s/{{SERVICE}}/$SERVICE/g" | sed "s#{{RID}}#$RID#g" | sed "s/{{CID}}/$CID/g"  >> ".${CLUSTER}.yaml"
done

kubectl apply -f .${CLUSTER}.yaml

for THINSTANCE in "${THINSTANCES[@]}"
do
	echo "az keyvault set-policy -n ${THINSTANCE}-secrets --secret-permissions get list set delete --key-permissions create decrypt delete encrypt get list unwrapKey wrapKey --object-id $(echo \"$OBID\")" >> .setvaults.sh
done	
bash .setvaults.sh


