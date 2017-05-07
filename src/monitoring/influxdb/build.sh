#!/bin/bash

sudo docker build -t mabsimms/mas_influxdb:latest .
sudo docker push mabsimms/mas_influxdb:latest
