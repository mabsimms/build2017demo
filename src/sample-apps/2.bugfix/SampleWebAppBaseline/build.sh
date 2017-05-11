#!/bin/bash

dotnet clean
dotnet build
dotnet publish

sudo docker build -t mabsimms/bld2017_app_bugfix:latest . --no-cache
sudo docker push mabsimms/bld2017_app_bugfix:latest
