#!/bin/bash

DNS_PREFIX=masbld2
AGENT_COUNT=8
USERNAME=masimms
RESOURCE_GROUP=${DNS_PREFIX}-rg
LOCATION=westus
DEPLOYMENT_NAME=demo2

# Leave blank to auto-generate an SSH public key
SSH_PUBLIC_KEY_FILE=${HOME}/.ssh/swarm_rsa.pub
SSH_PRIVATE_KEY_FILE=${HOME}/.ssh/swarm_rsa
KEYVAULT_RG=sharedkv-rg
KEYVAULT_NAME=sharedkv
 
# Create an SSH key for connecting to the cluster
if [ -f ${SSH_PUBLIC_KEY_FILE} ]; then
    echo "Using SSH public key from ${SSH_PUBLIC_KEY_FILE}"
    SSH_PUBLIC_KEY=`cat ${SSH_PUBLIC_KEY_FILE}`
else
    echo "No ssh public key file specified; generating new file"
    ssh-keygen -f ${SSH_PRIVATE_KEY_FILE}
    SSH_PUBLIC_KEY=`cat ${SSH_PUBLIC_KEY_FILE}`
fi

# Store the SSH public/private key pair in Azure Keyvault
# TODO - fix this, the check isn't working properly after porting over from CLI 1.0 
# echo -n "Checking for keyvault ${KEYVAULT_NAME}"
# KV_EXISTS=`az keyvault show ${KEYVAULT_NAME} 2>&1 | grep error | wc -l`
# if [ $KV_EXISTS -gt 0 ]; then
#     echo " does not exist"
#     echo "Keyvault ${KEYVAULT_NAME} does not exist; creating"
#     az group create --name ${KEYVAULT_RG} --location ${LOCATION}
#     az keyvault create --name ${KEYVAULT_NAME} --resource-group ${KEYVAULT_RG} \
#         --location "${LOCATION}" --sku standard --enabled-for-template-deployment true \
#         --enabled-for-deployment true --output table
# else
#         echo " exists"
# fi

# # Upload to key vault
# echo "Uploading SSH keys to keyvault"
# az keyvault secret set --vault-name ${KEYVAULT_NAME} --encoding base64 \
#     --name ${DNS_PREFIX}-key-private --file "${SSH_PRIVATE_KEY_FILE}" 
# az keyvault secret set --vault-name ${KEYVAULT_NAME} --encoding base64 \
#     --name ${DNS_PREFIX}-key-public --file "${SSH_PUBLIC_KEY_FILE}" 

# # Update the acs-engine template parameters based on the settings above
# # https://github.com/Azure/acs-engine/blob/master/README.md#deployment-usage
PARAMETERS_FILE=deploy-${DNS_PREFIX}.json
echo "Creating deployment parameters file ${PARAMETERS_FILE}"
cp swarm-mode-template.json ${PARAMETERS_FILE} 
sed -i'' -e "s/##DNS_PREFIX##/${DNS_PREFIX}/" $PARAMETERS_FILE
sed -i'' -e "s/##USERNAME##/${USERNAME}/" $PARAMETERS_FILE
sed -i'' -e "s/##AGENT_COUNT##/${AGENT_COUNT}/" $PARAMETERS_FILE
sed -i'' -e "s|##SSH_PUBLIC_KEY##|${SSH_PUBLIC_KEY}|" $PARAMETERS_FILE

echo "Deploying resource group ${RESOURCE_GROUP} to region ${LOCATION}"
az group create --name "${RESOURCE_GROUP}" --location "${LOCATION}"

# Create the ARM template via acs-engine
rm -rf ./_output/
../../tools/acs-engine $PARAMETERS_FILE

# Deploy the cluster 
echo "Deploying ACS cluster into resource group ${RESOURCE_GROUP}"
DIRECTORY=`ls _output`
az group deployment create \
    --name "${DEPLOYMENT_NAME}" \
    --resource-group "${RESOURCE_GROUP}" \
    --template-file "./_output/${DIRECTORY}/azuredeploy.json" \
    --parameters "@./_output/${DIRECTORY}/azuredeploy.parameters.json"
echo "ACS cluster deployment complete"

# Create the environment-masbld.sh file
echo "" > environment-${DNS_PREFIX}.sh
FULLPATH=`realpath environment-${DNS_PREFIX}.sh`

echo "export DEMO_ENV_PATH=${FULLPATH}" >> $FULLPATH
echo "export DEMO_RESOURCE_GROUP=${RESOURCE_GROUP}" >> $FULLPATH
echo "export DEMO_RESOURCE_GROUP=${RESOURCE_GROUP}" >> $FULLPATH
echo "export DEMO_LOCATION=${LOCATION}" >> $FULLPATH
echo "export DEMO_DEPLOYMENT_NAME=${DEPLOYMENT_NAME}" >> $FULLPATH
echo "export DEMO_DNS_PREFIX=${DNS_PREFIX}" >> $FULLPATH
echo "export DEMO_SSH_PUBLIC_KEY_FILE=${SSH_PUBLIC_KEY_FILE}" >> $FULLPATH
echo "export DEMO_SSH_PRIVATE_KEY_FILE=${SSH_PRIVATE_KEY_FILE}" >> $FULLPATH
echo "export DEMO_KEYVAULT_NAME=${KEYVAULT_NAME}" >> $FULLPATH

echo "source $FULLPATH" >> ~/.bashrc
source $FULLPATH
