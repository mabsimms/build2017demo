#!/bin/bash

# Build the haproxy image
cd haproxy
./build.sh
cd ../

# Force build a new dotnet image
cd SampleWebAppBaseline
./build.sh
cd ../

# Bring up the full image set
sudo docker-compose pull

echo "Starting containers.."
docker stack deploy --compose-file docker-compose.yml webapp1
