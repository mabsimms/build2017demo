
setlocal ENABLEDELAYEDEXPANSION ENABLEEXTENSIONS
set SQL_DATASOURCE=tcp:127.0.0.1,1401
set SQL_USER=sa
set SQL_PASSWORD="<YourStrong!Passw0rd>"

call :unquote SQL_PASSWORD %SQL_PASSWORD%


dotnet ef database update --verbose

:unquote
  set %1=%~2
  goto :EOF