SET DOCKER_TLS_VERIFY=1
SET DOCKER_HOST=tcp://13.64.192.183:2376
SET DOCKER_CERT_PATH=C:\Users\masim\.docker\machine\machines\masbldhst1
SET DOCKER_MACHINE_NAME=masbldhst1
SET COMPOSE_CONVERT_WINDOWS_PATHS=true
REM Run this command to configure your shell:
@FOR /f "tokens=*" %i IN ('docker-machine env masbldhst1') DO @%i