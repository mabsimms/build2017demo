#!/bin/bash

# Force build a new dotnet image
cd webapp
echo "Running dotnet clean.."
dotnet clean
echo "Running dotnet build.."
dotnet build
echo "Running dotnet publish.."
dotnet publish

# Import our demo configuration and pull the registry server information
source ../../../deployment-settings.sh
REGISTRY_SERVER=`az acr list --resource-group ${DEMO_RESOURCE_GROUP} \
    --query "[].{acrLoginServer:loginServer}" --output table | tail -1`
echo "Using registry server:           ${REGISTRY_SERVER}"

# Build the local image and push to the registry
#sudo docker build -t ${REGISTRY_SERVER}/mabsimms/bld2017_app_0:latest . --no-cache
#sudo docker push ${REGISTRY_SERVER}/mabsimms/bld2017_app_0:latest

sudo docker build -t mabsimms/bld2017_app_0:latest . --no-cache
sudo docker push mabsimms/bld2017_app_0:latest

sudo docker build -t mabsimms/bld2017_app_efupdate:latest -f Dockerfile-efupdate --no-cache .
sudo docker push mabsimms/bld2017_app_efupdate:latest

cd ../
