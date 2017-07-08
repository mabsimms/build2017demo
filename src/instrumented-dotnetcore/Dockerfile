####################################################
# Docker image for performance testing of .NET Core.
####################################################
FROM ubuntu:16.04

# Install curl so that we can download dependencies.
RUN apt-get -y update && apt-get install -y curl 
RUN apt-get -y update && apt-get -y install libunwind8 gettext libicu55 libuuid1 libcurl3 libssl1.0.0 zlib1g liblttng-ust0 

RUN mkdir dotnet_cli && cd dotnet_cli && \
    curl -O https://download.microsoft.com/download/1/1/4/114223DE-0AD6-4B8A-A8FB-164E5862AF6E/dotnet-dev-ubuntu.16.04-x64.1.0.3.tar.gz && \
    tar -xzvf dotnet-dev-ubuntu.16.04-x64.1.0.3.tar.gz && \
    mkdir /perf && cd /perf && curl -OL https://aka.ms/perfcollect && chmod +x perfcollect && \
    apt-get -y install linux-tools-common linux-tools-`uname -r` linux-cloud-tools-`uname -r` lttng-tools lttng-modules-dkms liblttng-ust0 zip
ENV PATH="${PATH}:/dotnet_cli"

# Set tracing environment variables.
ENV COMPlus_PerfMapEnabled 1
ENV COMPlus_EnableEventLog 1

# Run the app.
CMD cd /hw && /dotnet_cli/dotnet run -c Release
