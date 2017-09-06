FROM microsoft/aspnetcore:2.0
ARG source
WORKDIR /app
EXPOSE 80

# Override the core dump configuration
ENV COMPlus_PerfMapEnabled 1

# Copy in binary package
COPY ./bin/Debug/netcoreapp2.0/publish .

# Execute the main application
ENTRYPOINT ["dotnet", "webapp.dll"]
