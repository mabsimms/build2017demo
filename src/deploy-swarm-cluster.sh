#!/bin/bash

RESOURCE_GROUP=mas-bld-rg
LOCATION=eastus2
DEPLOYMENT_NAME=demo

# Deploy DC/OS 
TEMPLATE_URI="https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/101-acs-swarm/azuredeploy.json"

echo "Deploying resource group"
az group create --name "${RESOURCE_GROUP}" --location "${LOCATION}"

echo "Deploying ACS cluster"
az group deployment create -g ${RESOURCE_GROUP} -n ${DEPLOYMENT_NAME} \
    --template-uri ${TEMPLATE_URI} \
     --parameters @azuredeploy.parameters.json

# TODO - set up the username/password for the monitoring tools, add to environment
# TODO - get public IP FQDN for the agent pool

# Create the environment-masbld.sh file
echo "RESOURCE_GROUP=${RESOURCE_GROUP}" >> environment-masbld.sh
echo "LOCATION=${LOCATION}" >> environment-masbld.sh
echo "DEPLOYMENT_NAME=${DEPLOYMENT_NAME}" >> environment-masbld.sh

