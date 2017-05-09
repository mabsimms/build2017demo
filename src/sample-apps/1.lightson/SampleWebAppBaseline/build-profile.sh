#!/bin/bash

dotnet clean
dotnet build
dotnet publish

sudo docker build -t mabsimms/dtest:latest . -f Dockerfile-trace --no-cache
sudo docker push mabsimms/dtest:latest
