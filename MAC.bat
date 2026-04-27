@echo off
SETLOCAL ENABLEDELAYEDEXPANSION
SETLOCAL ENABLEEXTENSIONS

SET COUNT=0
SET GEN=0123456789ABCDEF
SET GEN2=26AE
SET MAC=

:MACLOOP
SET /a COUNT+=1
SET /a RND=!RANDOM! %% 16
SET RNDGEN=!GEN:~%RND%,1!
SET /a RND2=!RANDOM! %% 4
SET RNDGEN2=!GEN2:~%RND2%,1!

IF "!COUNT!" EQU "2" (
    SET MAC=!MAC!!RNDGEN2!
) ELSE (
    SET MAC=!MAC!!RNDGEN!
)
IF !COUNT! LEQ 11 GOTO MACLOOP

FOR /F "tokens=1" %%a IN ('wmic nic where physicaladapter^=true get deviceid ^| findstr [0-9]') DO (
    FOR %%b IN (0 00 000) DO (
        REG QUERY "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Class\{4D36E972-E325-11CE-BFC1-08002bE10318}\%%b%%a" >NUL 2>NUL && (
            REG ADD "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Class\{4D36E972-E325-11CE-BFC1-08002bE10318}\%%b%%a" /v NetworkAddress /t REG_SZ /d !MAC! /f >NUL 2>NUL
            REG ADD "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Class\{4D36E972-E325-11CE-BFC1-08002bE10318}\%%b%%a" /v PnPCapabilities /t REG_DWORD /d 24 /f >NUL 2>NUL
        )
    )
)

FOR /F "tokens=2 delims=, skip=2" %%a IN ('"wmic nic where (netconnectionid like '%%') get netconnectionid,netconnectionstatus /format:csv"') DO (
    netsh interface set interface name="%%a" disable >NUL 2>NUL
    timeout /t 1 /nobreak >NUL 2>NUL
    netsh interface set interface name="%%a" enable >NUL 2>NUL
)

GOTO :EOF