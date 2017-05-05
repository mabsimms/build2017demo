#!/bin/bash

sudo docker build -t mabsimms/telegraf-host:latest .
sudo docker push mabsimms/telegraf-host:latest
