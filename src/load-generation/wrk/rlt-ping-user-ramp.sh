#!/bin/bash

ENDPOINT="http://masbldagent.eastus2.cloudapp.azure.com/api/ping"
RPS=(10 100 500 1000 )
echo "Testing endpoint ${ENDPOINT}"
curl -v ${ENDPOINT}
echo

for i in "${RPS[@]}"
do
    echo "Invoking $i rps for 1 minute"
    wrk -c 100 -d 1m -t 100 --rate $i ${ENDPOINT}
done

