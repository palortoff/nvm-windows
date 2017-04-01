@echo off

echo setting up nvm-windows

SET NVM_HOME_WITH_TRAILING_BACKSLASH="%~dp0WITHTRAILINGBACKSLASH"
SET NVM_HOME=%NVM_HOME_WITH_TRAILING_BACKSLASH:\WITHTRAILINGBACKSLASH=%
SET NVM_SYMLINK="C:\Program Files\nodejs"

:setupSystemWide
setx /M NVM_HOME %NVM_HOME% > NUL 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo.
    echo could not set environment for system. setting environment for user
    echo.
    goto :userOnly
)
setx /M NVM_SYMLINK %NVM_SYMLINK% > NUL
call :setSystemPath
goto :writeConfig

:userOnly
setx NVM_HOME %NVM_HOME% > NUL
setx NVM_SYMLINK %NVM_SYMLINK% > NUL
call :setUserPath
goto :writeConfig

:writeConfig
set NVM_CONFIG_FILE=%NVM_HOME%\settings.txt
if exist "%SYSTEMDRIVE%\Program Files (x86)\" (
set SYS_ARCH=64
) else (
set SYS_ARCH=32
)
(echo root: %NVM_HOME:"=% && echo path: %NVM_SYMLINK:"=% && echo arch: %SYS_ARCH% && echo proxy: none) > %NVM_CONFIG_FILE%

echo config written to ^"%NVM_CONFIG_FILE:"=%^"
echo.
goto :eof

:setSystemPath
SET Key="HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Environment"
FOR /F "usebackq tokens=2*" %%A IN (`REG QUERY %Key% /v PATH`) DO Set CurrPath=%%B
ECHO %CurrPath% > %TEMP%\system_path_bak.txt
SETX /M PATH "%CurrPath%;%NVM_HOME:"=%;%NVM_SYMLINK:"=%" > NUL
goto :eof

:setUserPath
SET Key="HKCU\Environment"
FOR /F "usebackq tokens=2*" %%A IN (`REG QUERY %Key% /v PATH`) DO Set CurrPath=%%B
ECHO %CurrPath% > %TEMP%\user_path_bak.txt
SETX PATH "%CurrPath%;%NVM_HOME:"=%;%NVM_SYMLINK:"=%" > NUL
goto :eof
