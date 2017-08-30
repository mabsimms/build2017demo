#!/bin/bash

# Force build a new dotnet image
cd SampleWebAppBaseline
dotnet clean
dotnet build
dotnet publish

# Import our demo configuration and pull the registry server information
source ../../deployment-settings.sh
REGISTRY_SERVER=`az acr list --resource-group ${DEMO_RESOURCE_GROUP} \
    --query "[].{acrLoginServer:loginServer}" --output table | tail -1`
echo "Using registry server:           ${REGISTRY_SERVER}"

# Build the local image
sudo docker build -t mabsimms/bld2017_app_0:latest . --no-cache
