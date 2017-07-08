#!/bin/bash

docker build . -t masdev.azurecr.io/haproxy-base:latest
docker push masdev.azurecr.io/haproxy-base:latest
