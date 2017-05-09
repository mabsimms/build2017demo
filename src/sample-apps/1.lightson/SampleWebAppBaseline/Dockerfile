FROM microsoft/aspnetcore:1.1
ARG source
WORKDIR /app
EXPOSE 80

# Override the core dump configuration
ENV COMPlus_PerfMapEnabled 1

# Copy in binary package
COPY ./bin/Debug/netcoreapp1.1/publish .

# Execute the main application
ENTRYPOINT ["dotnet", "SampleWebAppBaseline.dll"]
