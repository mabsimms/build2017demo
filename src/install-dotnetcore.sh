#!/bin/bash

# Register Microsoft product key as trusted
curl https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > microsoft.gpg
sudo mv microsoft.gpg /etc/apt/trusted.gpg.d/microsoft.gpg

# Register the package source
sudo sh -c 'echo "deb [arch=amd64] https://packages.microsoft.com/repos/microsoft-ubuntu-xenial-prod xenial main" \
    > /etc/apt/sources.list.d/dotnetdev.list'
sudo apt-get update

# Install .NET Core 2.0
sudo apt-get install dotnet-sdk-2.0.0