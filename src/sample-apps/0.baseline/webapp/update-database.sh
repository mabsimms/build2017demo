#!/bin/sh

# Note - the SQL container has to be running for this to work
export SQL_DATASOURCE='tcp:localhost,1433'
export SQL_USER='sa'
export SQL_PASSWORD='S_PerSt!rongPW123'

dotnet ef database update

# Add the sample data
