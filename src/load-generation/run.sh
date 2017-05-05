#!/bin/bash

sudo docker run -it --rm --net=host \
    -v /home/masimms/code/build2017demo/src/load-generation/conf:/opt/gatling/conf \
    -v /home/masimms/code/build2017demo/src/load-generation/user-files:/opt/gatling/user-files \
    -v /home/masimms/code/build2017demo/src/load-generation/results:/opt/gatling/results \
    denvazh/gatling
