#!/bin/bash

source ./deployment-settings.sh

echo "Retrieving Kubernetes credentials"
az acs kubernetes get-credentials \
    --resource-group=${DEMO_RESOURCE_GROUP} \
    --name=${DEMO_CLUSTER_NAME}
