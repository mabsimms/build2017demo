dotnet clean
dotnet build

docker build -t mabsimms/bld2017_app_0:latest . --no-cache
docker push mabsimms/bld2017_app_0:latest