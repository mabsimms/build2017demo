FROM microsoft/aspnetcore:1.1
ARG source
WORKDIR /app
EXPOSE 80
COPY ./bin/Debug/netcoreapp1.1/publish .
#RUN dotnet restore
#ENTRYPOINT ["dotnet", "run"]
ENTRYPOINT ["dotnet", "SampleWebAppBaseline.dll"]
