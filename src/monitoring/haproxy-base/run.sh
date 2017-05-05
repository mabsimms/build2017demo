#!/bin/bash

sudo docker build -t haproxy_base:latest .
sudo docker run --net host -d -p 8005:80 --name haproxy -it haproxy_base:latest
