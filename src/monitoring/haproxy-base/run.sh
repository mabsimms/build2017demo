#!/bin/bash

sudo docker build -t haproxy-base:latest .
sudo docker run --net host -d -p 8005:80 --name haproxy-base -it haproxy-base:latest
sudo docker exec -it haproxy-base /bin/bash
sudo docker kill haproxy-base
sudo docker rm haproxy-base
