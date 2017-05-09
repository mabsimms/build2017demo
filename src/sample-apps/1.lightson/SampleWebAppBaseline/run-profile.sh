#!/bin/bash

sudo docker run -d --privileged \
    -e SQL_DATASOURCE=localhost \
    -e SQL_USER=sa \
    -e SQL_PASSWORD=test \
    -v /tmp/perfdata:/perfdata \
    --name=dtest \
    -it mabsimms/dtest:latest \

sudo docker exec -it dtest /bin/bash


