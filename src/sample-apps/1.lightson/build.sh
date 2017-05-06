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
sudo docker-compose build
sudo docker-compose up
