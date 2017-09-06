#!/bin/bash

export SQL_DATASOURCE=tcp:127.0.0.1,1433
export SQL_USER=sa
export SQL_PASSWORD='ThisIsMyAwesomePassword!@#'

kubectl port-forward sqlserver-0 1433:1433 &
dotnet ef database update --verbose
