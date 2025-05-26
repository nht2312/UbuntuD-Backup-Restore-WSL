@echo off
setlocal enabledelayedexpansion

:: Config
set DISTRO=UbuntuD
set INSTALL_DIR_BASE=D:\WSL\ubuntu
set BACKUP_DIR=D:\WSL\backup
set SOURCE_DIR=D:\WSL

:main_menu
cls
echo ----------------------------------------
echo        UbuntuD - Backup Tool
echo ----------------------------------------
echo.
echo [1] Backup distro %DISTRO%
echo [2] Restore distro tu ban backup
echo [3] Xoa file backup
echo [4] Xoa distro (Unregister %DISTRO%)
echo [5] Tao distro moi tu file .tar hoac .tar.gz
echo [0] Thoat
echo.

set /p choice="Nhap lua chon cua ban (0-5): "

if "%choice%"=="1" goto backup
if "%choice%"=="2" goto restore
if "%choice%"=="3" goto delete_backup
if "%choice%"=="4" goto unregister
if "%choice%"=="5" goto create
if "%choice%"=="0" exit

echo Lua chon khong hop le.
pause
goto main_menu

:backup
if not exist "%BACKUP_DIR%" (
    mkdir "%BACKUP_DIR%"
)

for /f %%i in ('powershell -command "Get-Date -Format yyyy-MM-dd_HH-mm-ss"') do set DATETIME=%%i
set BACKUP_FILE=%BACKUP_DIR%\%DISTRO%-backup-%DATETIME%.tar

echo.
echo Dang backup vao: %BACKUP_FILE%
echo.
wsl --export %DISTRO% "%BACKUP_FILE%"
echo Backup thanh cong!
pause
goto main_menu

:restore
cls
echo Danh sach backup co san:
echo ----------------------------------------
set index=0
for %%f in ("%BACKUP_DIR%\*.tar") do (
    set /a index+=1
    set "file_!index!=%%~nxf"
    echo !index!. %%~nxf
)

if %index%==0 (
    echo Khong tim thay backup nao.
    pause
    goto main_menu
)

echo.
set /p pick="Nhap so thu tu backup de khoi phuc: "
set "chosen_file=!file_%pick%!"

if not defined chosen_file (
    echo So khong hop le.
    pause
    goto main_menu
)

echo.
set /p confirm="Ban chac chan muon khoi phuc? (y/n): "
if /i not "%confirm%"=="y" (
    echo Da huy thao tac.
    pause
    goto main_menu
)

echo Dang xoa distro cu...
wsl --unregister %DISTRO%

echo Dang khoi phuc tu file: %chosen_file%
wsl --import %DISTRO% "%INSTALL_DIR_BASE%" "%BACKUP_DIR%\%chosen_file%" --version 2

echo Khoi phuc thanh cong!
pause
goto main_menu

:delete_backup
cls
echo Danh sach file backup:
echo ----------------------------------------
set index=0
for %%f in ("%BACKUP_DIR%\*.tar") do (
    set /a index+=1
    set "file_!index!=%%~nxf"
    echo !index!. %%~nxf
)

if %index%==0 (
    echo Khong co file backup nao.
    pause
    goto main_menu
)

echo.
set /p pick="Nhap so thu tu file muon xoa: "
set "chosen_file=!file_%pick%!"

if not defined chosen_file (
    echo So khong hop le.
    pause
    goto main_menu
)

del "%BACKUP_DIR%\%chosen_file%"
echo File da duoc xoa: %chosen_file%
pause
goto main_menu

:unregister
cls
echo Ban chac chan muon xoa distro %DISTRO%? (y/n):
set /p confirm="Lua chon: "
if /i not "%confirm%"=="y" (
    echo Da huy thao tac.
    pause
    goto main_menu
)

wsl --unregister %DISTRO%
echo Da xoa distro: %DISTRO%
pause
goto main_menu

:create
cls
echo Chon loai file de tao distro moi:
echo [1] File backup (.tar)
echo [2] File rootfs (.tar.gz)
set /p type="Nhap lua chon cua ban (1-2): "

if "%type%"=="1" (
    set "FILE_EXT=tar"
) else if "%type%"=="2" (
    set "FILE_EXT=tar.gz"
) else (
    echo Lua chon khong hop le.
    pause
    goto main_menu
)

cls
echo Danh sach file co san:
echo ----------------------------------------
set index=0
for %%f in ("%SOURCE_DIR%\*.%FILE_EXT%") do (
    set /a index+=1
    set "file_!index!=%%~nxf"
    echo !index!. %%~nxf
)

if %index%==0 (
    echo Khong tim thay file nao.
    pause
    goto main_menu
)

echo.
set /p pick="Nhap so thu tu file muon dung: "
set "chosen_file=!file_%pick%!"

if not defined chosen_file (
    echo So khong hop le.
    pause
    goto main_menu
)

set /p new_name="Nhap ten moi cho distro: "
if "%new_name%"=="" (
    echo Ten khong hop le.
    pause
    goto main_menu
)

set INSTALL_DIR_NEW=%INSTALL_DIR_BASE%\%new_name%

echo.
echo Dang tao distro moi: %new_name%
echo Thu muc: %INSTALL_DIR_NEW%
echo File nguon: %chosen_file%
echo.

wsl --import %new_name% "%INSTALL_DIR_NEW%" "%SOURCE_DIR%\%chosen_file%" --version 2
echo Distro moi da duoc tao: %new_name%
pause
goto main_menu
