#!/bin/sh

# Note - the SQL container has to be running for this to work
export SQL_DATASOURCE='tcp:localhost,1401'
export SQL_USER='sa'
export SQL_PASSWORD='Abc123Abc__'

dotnet ef database update

# Add the sample data
