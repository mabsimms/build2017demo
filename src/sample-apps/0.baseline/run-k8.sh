#!/bin/bash

# Create the SQL Server secret
kubectl create secret generic sql-server-password --from-file=./sql-password.txt
