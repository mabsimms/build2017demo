#!/bin/bash

# Check for deployment settings (resource group name, etc)
if [ ! -f ../deployment-settings.sh ]; then
    echo "Could not locate deployment-settings.sh"
    exit
fi
echo "Loading deployment settings from deployment-settings.sh"
source ../deployment-settings.sh


echo "Creating k8 cluster with these settings:"
if [ -z ${DEMO_RESOURCE_GROUP+x} ]; then
    echo "Resource group is not set; exiting"
    exit
else
    echo "Resource group:  ${DEMO_RESOURCE_GROUP}"
fi

if [ -z ${DEMO_LOCATION+x} ]; then
    echo "Location is not set"
else
    echo "Location:        ${DEMO_LOCATION}"
fi

if [ -z ${DEMO_CLUSTER_NAME+x} ]; then
    echo "Cluster name is not set"
else
    echo "Cluster name:    ${DEMO_CLUSTER_NAME}"
fi

# Create the resource group
az group create --name ${DEMO_RESOURCE_GROUP} \
    --location ${DEMO_LOCATION}

# Create the private container registry
az acr create --name ${DEMO_CLUSTER_NAME}registry \
    --resource-group ${DEMO_RESOURCE_GROUP} \
    --sku Basic \
    --admin-enabled true
az acr login --name ${DEMO_CLUSTER_NAME}registry

# Create the Kubernetes cluster
az acs create --orchestrator-type kubernetes \
    --resource-group ${DEMO_RESOURCE_GROUP} \
    --name ${DEMO_CLUSTER_NAME} \
    --generate-ssh-keys

# Set up kubernetes command line and credentials
 sudo az acs kubernetes install-cli
 az acs kubernetes get-credentials \
     --resource-group=${DEMO_RESOURCE_GROUP} \
     --name=${DEMO_CLUSTER_NAME}
kubectl get nodes

