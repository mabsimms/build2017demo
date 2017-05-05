#!/bin/bash

# Force build a new dotnet image
cd SampleWebAppBaseline
dotnet clean
dotnet build
dotnet publish

# Rebuild the docker image
sudo docker build -t mabsimms/bld2017_app_0:latest . --no-cache
cd ../

# Bring up the full image set
sudo docker-compose up
