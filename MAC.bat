@echo off
SETLOCAL ENABLEDELAYEDEXPANSION
SETLOCAL ENABLEEXTENSIONS

:: ==================== CLEAN EAC + EAC EOS ====================

taskkill /F /IM EasyAntiCheat*.exe >nul 2>&1

if exist "C:\Program Files (x86)\EasyAntiCheat_EOS\EasyAntiCheat_EOS.exe" (
    cd /d "C:\Program Files (x86)\EasyAntiCheat_EOS" >nul 2>&1
    EasyAntiCheat_EOS.exe qa-factory-reset >nul 2>&1
)

if exist "C:\Program Files (x86)\EasyAntiCheat\EasyAntiCheat.exe" (
    cd /d "C:\Program Files (x86)\EasyAntiCheat" >nul 2>&1
    EasyAntiCheat.exe qa-factory-reset >nul 2>&1
)

sc stop "EasyAntiCheat" >nul 2>&1
sc delete "EasyAntiCheat" >nul 2>&1
sc stop "EasyAntiCheat_EOS" >nul 2>&1
sc delete "EasyAntiCheat_EOS" >nul 2>&1

rd /s /q "C:\Program Files (x86)\EasyAntiCheat" >nul 2>&1
rd /s /q "C:\Program Files (x86)\EasyAntiCheat_EOS" >nul 2>&1
rd /s /q "%APPDATA%\EasyAntiCheat" >nul 2>&1
rd /s /q "%LOCALAPPDATA%\EasyAntiCheat" >nul 2>&1

:: ==================== SPOOF MAC ALÉATOIRE ====================

CALL :MAC

FOR /F "tokens=1" %%a IN ('wmic nic where physicaladapter^=true get deviceid ^| findstr [0-9]') DO (
    FOR %%b IN (0 00 000) DO (
        REG QUERY HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Class\{4D36E972-E325-11CE-BFC1-08002bE10318}\%%b%%a >nul 2>&1 && (
            REG ADD HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Class\{4D36E972-E325-11CE-BFC1-08002bE10318}\%%b%%a /v NetworkAddress /t REG_SZ /d !MAC! /f >nul 2>&1
            REG ADD HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Class\{4D36E972-E325-11CE-BFC1-08002bE10318}\%%b%%a /v PnPCapabilities /t REG_DWORD /d 24 /f >nul 2>&1
        )
    )
)

FOR /F "tokens=2 delims=, skip=2" %%a IN ('"wmic nic where (netconnectionid like '%%') get netconnectionid,netconnectionstatus /format:csv"') DO (
    netsh interface set interface name="%%a" disable >nul 2>&1
    timeout /t 1 /nobreak >nul 2>&1
    netsh interface set interface name="%%a" enable >nul 2>&1
)

exit

:MAC
SET COUNT=0
SET GEN=ABCDEF0123456789

:: Premier octet aléatoire mais valide (Local Administered)
SET FIRST=2 6 A E
SET /A IDX=!RANDOM! %% 4
FOR %%i IN (!FIRST!) DO (
    IF !IDX! EQU 0 SET MAC=%%i
    IF !IDX! EQU 1 SET MAC=%%i
    IF !IDX! EQU 2 SET MAC=%%i
    IF !IDX! EQU 3 SET MAC=%%i
)

:MACLOOP
SET /a COUNT+=1
SET /A RND=!RANDOM!%%16
SET RNDGEN=!GEN:~%RND%,1!
SET MAC=!MAC!!RNDGEN!
IF !COUNT! LEQ 10 GOTO MACLOOP
EXIT /B